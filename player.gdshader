shader_type canvas_item;

uniform vec2 mouse = vec2(0.0);
uniform float fft = 0.0; // remplace iChannel0

#define NUM_LAYERS 4.0

float S(float a, float b, float t){
    return smoothstep(a, b, t);
}

float N21(vec2 p) {
    vec3 a = fract(vec3(p.xyx) * vec3(213.897, 653.453, 253.098));
    a += dot(a, a.yzx + 79.76);
    return fract((a.x + a.y) * a.z);
}

vec2 GetPos(vec2 id, vec2 offs, float t) {
    float n = N21(id+offs);
    float n1 = fract(n*10.0);
    float n2 = fract(n*100.0);
    float a = t+n;
    return offs + vec2(sin(a*n1), cos(a*n2))*0.4;
}

float df_line(vec2 a, vec2 b, vec2 p){
    vec2 pa = p - a;
    vec2 ba = b - a;
    float h = clamp(dot(pa,ba) / dot(ba,ba), 0.0, 1.0);	
    return length(pa - ba * h);
}

float line(vec2 a, vec2 b, vec2 uv) {
    float r1 = 0.04;
    float r2 = 0.01;
    
    float d = df_line(a, b, uv);
    float d2 = length(a-b);
    float fade = S(1.5, 0.5, d2);
    
    fade += S(0.05, 0.02, abs(d2-0.75));
    return S(r1, r2, d)*fade;
}

float NetLayer(vec2 st, float n, float t) {
    vec2 id = floor(st)+n;
    st = fract(st)-0.5;
   
    vec2 p[9];
    int i = 0;

    for(int y=-1; y<=1; y++) {
        for(int x=-1; x<=1; x++) {
            p[i++] = GetPos(id, vec2(float(x), float(y)), t);
        }
    }
    
    float m = 0.0;
    float sparkle = 0.0;
    
    for(int i=0; i<9; i++) {
        m += line(p[4], p[i], st);

        float d = length(st-p[i]);

        float s = (0.005/(d*d));
        s *= S(1.0, 0.7, d);

        float pulse = sin((fract(p[i].x)+fract(p[i].y)+t)*5.0)*0.4+0.6;
        pulse = pow(pulse, 20.0);

        s *= pulse;
        sparkle += s;
    }
    
    m += line(p[1], p[3], st);
    m += line(p[1], p[5], st);
    m += line(p[7], p[5], st);
    m += line(p[7], p[3], st);
    
    float sPhase = (sin(t+n)+sin(t*0.1))*0.25+0.5;
    sPhase += pow(sin(t*0.1)*0.5+0.5, 50.0)*5.0;

    m += sparkle*sPhase;
    
    return m;
}

void fragment() {
    vec2 resolution = 1.0 / SCREEN_PIXEL_SIZE;
    vec2 uv = (FRAGCOORD.xy - resolution*0.5) / resolution.y;

    vec2 M = mouse / resolution - 0.5;

    float t = TIME * 0.1;
    
    float s = sin(t);
    float c = cos(t);
	mat2 rot = mat2(vec2(c, s), vec2(-s, c));

    vec2 st = uv * rot;
    M *= rot * 2.0;
    
    float m = 0.0;

    for(float i=0.0; i<1.0; i+=1.0/NUM_LAYERS) {
        float z = fract(t+i);
        float size = mix(15.0, 1.0, z);
        float fade = S(0.0, 0.6, z)*S(1.0, 0.8, z);
        
        m += fade * NetLayer(st*size - M*z, i, TIME);
    }
    
    float glow = -uv.y * fft * 2.0;
   
    vec3 baseCol = vec3(s, cos(t*0.4), -sin(t*0.24))*0.4+0.6;
    vec3 col = baseCol*m;
    col += baseCol*glow;

    col *= 1.0 - dot(uv,uv);

    float tt = mod(TIME, 230.0);
    col *= S(0.0, 20.0, tt) * S(224.0, 200.0, tt);

    COLOR = vec4(col,1.0);
}