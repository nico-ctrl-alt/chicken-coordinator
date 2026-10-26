shader_type sky;

uniform float starness;
uniform vec4 color : source_color;
uniform float speed;

vec3 random3(vec3 c) {
    float j = 4096.0*sin(dot(c,vec3(17.0, 59.4, 15.0)));
    vec3 r;
    r.z = fract(512.0*j);
    j *= .125;
    r.x = fract(512.0*j);
    j *= .125;
    r.y = fract(512.0*j);
    return r-0.5;
}

const float F3 =  0.3333333;
const float G3 =  0.1666667;
float snoise(vec3 p) {

    vec3 s = floor(p + dot(p, vec3(F3)));
    vec3 x = p - s + dot(s, vec3(G3));
	
    vec3 e = step(vec3(0.0), x - x.yzx);
    vec3 i1 = e*(1.0 - e.zxy);
    vec3 i2 = 1.0 - e.zxy*(1.0 - e);

    vec3 x1 = x - i1 + G3;
    vec3 x2 = x - i2 + 2.0*G3;
    vec3 x3 = x - 1.0 + 3.0*G3;

    vec4 w, d;

    w.x = dot(x, x);
    w.y = dot(x1, x1);
    w.z = dot(x2, x2);
    w.w = dot(x3, x3);

    w = max(0.6 - w, 0.0);

    d.x = dot(random3(s), x);
    d.y = dot(random3(s + i1), x1);
    d.z = dot(random3(s + i2), x2);
    d.w = dot(random3(s + 1.0), x3);

    w *= w;
    w *= w;
    d *= w;

    return dot(d, vec4(52.0));
}

/* const matrices for 3d rotation */
const mat3 rot1 = mat3(vec3(-0.37, 0.36, 0.85),vec3(-0.14,-0.93, 0.34),vec3(0.92, 0.01,0.4));
const mat3 rot2 = mat3(vec3(-0.55,-0.39, 0.74), vec3(0.33,-0.91,-0.24),vec3(0.77, 0.12,0.63));
const mat3 rot3 = mat3(vec3(-0.71, 0.52,-0.47),vec3(-0.08,-0.72,-0.68),vec3(-0.7,-0.45,0.56));

/* directional artifacts can be reduced by rotating each octave */
float sfnoise(vec3 m) {
    return   0.5333333*snoise(m*rot1)
			+0.2666667*snoise(2.0*m*rot2)
			+0.1333333*snoise(4.0*m*rot3)
			+0.0666667*snoise(8.0*m);
}
vec2 random2( vec2 p ) {
    return fract(sin(vec2(dot(p,vec2(127.1,311.7)),dot(p,vec2(269.5,183.3))))*43758.5453);
}

float voronoi(vec2 st)
{
	vec2 i_st = floor(st);
	vec2 f_st = fract(st);

	float m_dist = 1.;
	float time = TIME * speed;

	for(int y = -1; y <= 1; y++) {
		for (int x = -1; x <= 1; x++) {
			vec2 neighbor = vec2(float(x),float(y));
			vec2 point = random2(i_st + neighbor);
			point = 0.5 + 0.5*(sin(time + 6.2831*point) + sin(time/5.0)) + sin(point);
			vec2 diff = neighbor + point - f_st;
			float dist = length(diff);
			m_dist = min(m_dist,dist);
		}
	}
	return m_dist;
}

void sky() {
	// Called for every visible pixel in the sky background, as well as all pixels
	// in the radiance cubemap.
	float time = TIME/800.0;
	float octave1 = clamp(sfnoise(vec3(SKY_COORDS.x+time, SKY_COORDS.y-time, (POSITION.z/7000.0)+time)*100.0 )/2.0,0.0,1.0)/2.0;
	float octave2 = 1.0-clamp(sfnoise(vec3(sin(SKY_COORDS.x-time+100.0), SKY_COORDS.y+time-50.0, (POSITION.z/70000.0)-time+80.0)*10.0 )*2.0,0.0,1.0);
	float octave3 = clamp(sfnoise(vec3(sin(SKY_COORDS.x-time+100.001), SKY_COORDS.y+time-50.0, (POSITION.z/70000.0)-time+80.0)*10.0 )*1.0,0.0,1.0);
	COLOR = color.xyz + clamp(mix((1.0-(octave3+octave2+octave1/10.0))*5.0, 1.0-voronoi(SKY_COORDS.xy*100.0) * 100.0, starness),0.0,1.0);
}
