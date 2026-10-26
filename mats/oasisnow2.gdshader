shader_type spatial;
render_mode cull_back;
uniform sampler2D tex2D;
uniform vec3 color;
uniform float metallic;
uniform sampler2D mirror_tex2D;
uniform float multiplier;
uniform float additive;
uniform float clouds;
uniform float c_speed;
uniform uint seed1;
uniform float size;

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
	uint seedx = (uint(uv.x+ fract(TIME/c_speed)*c_speed)+seed);
	uint seedy = (uint(uv.y + fract(TIME/c_speed)*c_speed)+seed);
	uint seedz = (uint(uv.z + fract(TIME/c_speed)*c_speed)+seed);
	float x = rand_from_seed(seedx);
	float y = rand_from_seed(seedy);
	float z = rand_from_seed(seedz);	
	
	return vec3(x,y,z)/(1.0 + float(seed)); 
}
void vertex() {
	// Called for every vertex the material is visible on.
	VERTEX.xyz += rand3(242049, VERTEX.xyz) * 100.0;
}

void fragment() {
	// Called for every pixel the material is visible on.
	ALBEDO = mix(color * mix(texture(tex2D, UV).xyz, texture(mirror_tex2D, generate_matcap_uv(NORMAL , NODE_POSITION_VIEW)).xyz, metallic), (rand3(seed1, vec3(UV.x * size,UV.y* size,UV.x* size))*color), clouds);;
}





void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
	 DIFFUSE_LIGHT += clamp(dot(NORMAL, LIGHT),.0,1.) * ALBEDO;
}
