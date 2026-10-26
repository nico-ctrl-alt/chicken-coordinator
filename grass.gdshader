shader_type spatial;
render_mode unshaded, depth_prepass_alpha, blend_mix;

uniform sampler2D _maintex : filter_nearest;
uniform vec4 chroma : source_color;
uniform float moreless = 10.0;
uniform vec4 color1: source_color;
uniform vec4 color2: source_color;
instance uniform int shellid;
uniform float shell_space = .001;
uniform float amp;
uniform float freq;
uniform sampler2D depth_tex : hint_depth_texture;

const float pi = 3.1415926535;

vec2 random2( vec2 p ) {
    return fract(sin(vec2(dot(p,vec2(127.1,311.7)),dot(p,vec2(269.5,183.3))))*43758.5453);
}

float voronoi(vec2 st)
{
	vec2 i_st = floor(st);
	vec2 f_st = fract(st);

	float m_dist = 1.;

	for(int y = -1; y <= 1; y++) {
		for (int x = -1; x <= 1; x++) {
			vec2 neighbor = vec2(float(x),float(y));
			vec2 point = random2(i_st + neighbor);
			point = 0.5 + 0.5*((sin(TIME + 6.2831*point + float(shellid)/10.0) + sin(TIME/5.0))*float(shellid)/10.0) + sin(point);
			vec2 diff = neighbor + point - f_st;
			float dist = length(diff);
			m_dist = min(m_dist,dist);
		}
	}
	return m_dist;
}
varying vec3 world_pos;
void vertex() {
	// Called for every vertex the material is visible on.
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	VERTEX.xyz += vec3(0.0,0.0,(float(shellid)/1000.0)*shell_space);
}

void fragment() {
	//float depth = texture(depth_tex, SCREEN_UV).r;
	//vec3 ndc = vec3(SCREEN_UV, depth) * 2.0 - 1.0;
	//vec4 world = INV_VIEW_MATRIX * INV_PROJECTION_MATRIX * vec4(ndc, 1.0);
	//vec3 world_pos = world.xyz / world.w;
	// Called for every pixel the material is visible on.
	vec4 tex =  texture(_maintex, UV);
	float v =  voronoi(world_pos.xz*freq)*amp;
	ALBEDO = tex.xyz * mix(color1.xyz, color2.xyz, clamp(float(shellid)/1000.0 + v + distance(CAMERA_POSITION_WORLD, world_pos)/100.0, 0.0, 1.0));
	float mask = 1.0-length(tex - chroma) + moreless;
	ALPHA = clamp((mix(color1.a,color2.a,v) * mask) + distance(CAMERA_POSITION_WORLD, world_pos)/100.0 , 0.0, 1.0);
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
