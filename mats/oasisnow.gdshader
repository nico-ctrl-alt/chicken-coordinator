shader_type spatial;
render_mode cull_back, depth_prepass_alpha;
uniform sampler2D tex2D : filter_nearest;
uniform vec3 color;
uniform float metallic;
uniform float roughness = 1.0;
uniform sampler2D mirror_tex2D : filter_nearest;
uniform sampler2D bump;
uniform float height = 1.0;
uniform float n_scale = 1.0;
uniform float multiplier;
uniform float additive;
uniform float c_speed = 10.0;
uniform float displace = 0.0;
uniform sampler2D x_GI;
uniform sampler2D y_GI;
uniform sampler2D z_GI;
uniform sampler2D depth_tex : hint_depth_texture;
uniform sampler2D x_depth: source_color;
uniform sampler2D y_depth: source_color;
uniform sampler2D z_depth : source_color;
uniform float GI_size = 1200.0;
uniform vec3 x_offset;
uniform vec3 y_offset;
uniform vec3 z_offset;
uniform float reflectiveness;
uniform sampler2D step_color : source_color;

const float pi = 3.1415926535;

vec2 generate_matcap_uv(vec3 _normal, vec3 _node_position_view) {
	vec3 cross_space = cross(normalize(_node_position_view), _normal); // cross products the normal with it's base position
	vec2 mat_space = vec2(cross_space.y * 1.0, cross_space.x); // converts to a Vec2 UV, having to switch x and y
	mat_space *= vec2(-0.5, -0.5); // modifies the mat space's size to fit into uv coords, & flips it
	mat_space += vec2(0.5, 0.5); // transforms the mat space into uv coords
	return mat_space; // export the final uv's
}

float rand_from_seed(inout uint seed)
{
	int k;
	int s = int(seed);
	if(s==0)
	s = 5329529570;
	k = s/1234152155;
	s = 123525 * (s-k*1234152155)- 2036 * k;
	if(s< 0)
		s += 2030285989;
	seed = uint(s);
	return float(seed % uint(24525))/12515.0;
}

vec3 rand3(uint seed, vec3 uv)
{
	uint seedx = (uint(uv.x+ sin(TIME*c_speed))+seed);
	uint seedy = (uint(uv.y + sin(TIME*c_speed))+seed);
	uint seedz = (uint(uv.z + sin(TIME*c_speed))+seed);
	float x = rand_from_seed(seedx);
	float y = rand_from_seed(seedy);
	float z = rand_from_seed(seedz);

	return vec3(x,y,z)/(1.0 + float(seed));
}
varying vec3 world_pos;
void vertex() {
	// Called for every vertex the material is visible on.
	world_pos = ((MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz/GI_size) + vec3(.555,.52,.533);
	VERTEX.xyz += (rand3(0, VERTEX.xyz*100.0)/5000.0)*displace;
}

varying vec3 x;
varying vec3 y;
varying vec3 z;
//varying vec3 x_d;
//varying vec3 y_d;
varying vec3 z_d;

// Rotation matrix around the X axis.
mat3 rotateX(float theta) {
    float c = cos(theta);
    float s = sin(theta);
    return mat3(
        vec3(1, 0, 0),
        vec3(0, c, -s),
        vec3(0, s, c)
    );
}

// Rotation matrix around the Y axis.
mat3 rotateY(float theta) {
    float c = cos(theta);
    float s = sin(theta);
    return mat3(
        vec3(c, 0, s),
        vec3(0, 1, 0),
        vec3(-s, 0, c)
    );
}

// Rotation matrix around the Z axis.
mat3 rotateZ(float theta) {
    float c = cos(theta);
    float s = sin(theta);
    return mat3(
        vec3(c, -s, 0),
        vec3(s, c, 0),
        vec3(0, 0, 1)
    );
}

const int samples = 12;
const float sigma = float(samples) * 0.25;

float pow2(float v) {return (v * v);}

float gaussian(vec2 i) {
    return 1.0 / (2.0 * pi * pow2(sigma)) * exp(-((pow2(i.x) + pow2(i.y)) / (2.0 * pow2(sigma))));
}

vec3 blur(sampler2D sp, vec2 uv, vec2 scale) {
    vec3 col = vec3(0.0);
    float accum = 0.0;
    float weight;
    vec2 offset;

    for (int i = -samples / 2; i < samples / 2; ++i) {
        for (int j = -samples / 2; j < samples / 2; ++j) {
            offset = vec2(float(i), float(j));
            weight = gaussian(offset);
            col += texture(sp, uv + scale * offset).rgb * weight;
            accum += weight;
        }
    }

    return col / accum;
}

void fragment() {
	// Called for every pixel the material is visible on.
	vec3 x_pos =(rotateY(pi/2.0) * (world_pos.xyz+vec3(.11, -0.096, -0.03)+x_offset));
	vec3 y_pos = (rotateX(pi/2.0) * world_pos.xyz)+y_offset;
	vec3 z_pos = (world_pos.xyz + vec3(0.0,-0.096, -0.03))+z_offset;

	x = texture(x_GI, vec2(x_pos.x, -x_pos.y)).xyz;
	y = texture(y_GI, y_pos.xy).xyz;
	z = texture(z_GI, vec2(z_pos.x, -z_pos.y)).xyz;
	//x_d = texture(x_depth, vec2(x_pos.x, -x_pos.y)).xyz;
	//y_d = texture(y_depth, y_pos.xy).xyz;
	z_d = texture(z_depth, vec2(z_pos.x, -z_pos.y)).xyz;
	NORMAL *= texture(bump, UV*n_scale).rgb*height;
	ALBEDO = color * mix(mix(texture(tex2D, UV).xyz, texture(mirror_tex2D, generate_matcap_uv(NORMAL, NODE_POSITION_VIEW)).xyz, metallic), min(min(x,z),y), reflectiveness);
	//ALBEDO = z_d * color;
	//ALBEDO = clamp(y,0.0,1.0);
}

float oren_nayar(vec3 ld, vec3 vd, vec3 n, float r, float rho)
{
float LdotV = dot(ld, vd);
float NdotL = dot(ld, n);
float NdotV = dot(n, vd);

float s = LdotV - NdotL * NdotV;
float sigma2 = r * r;
float a = 1./(pi + ((pi/2.) -((2./3.) * r)));
float b = r/(pi + ((pi/2.) -((2./3.) * r)));

float ga = dot(vd-n*NdotV,n-n*NdotL);

return max(0., NdotL) * (a + b * max(0., ga) * sqrt(max((1.0-NdotV*NdotV)*(1.0-NdotL*NdotL), 0.)) / max(NdotL, NdotV));
}

void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
	//vec2 sp = (vec2(1.0)/FRAGCOORD.xy);
	vec3 gi = (clamp(y,0.0,10.0));
	float orennayar = oren_nayar(LIGHT, VIEW, NORMAL, roughness * 7.0, 1.0);
	DIFFUSE_LIGHT += clamp(orennayar*LIGHT_COLOR,.0,1.) * (ATTENUATION+gi/4.0);
	//DIFFUSE_LIGHT *= ATTENUATION+LIGHT_COLOR;
	//vec3 d = blur(depth_tex, SCREEN_UV, sp).xyz+vec3(.2);
}
