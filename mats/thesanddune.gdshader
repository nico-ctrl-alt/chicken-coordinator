shader_type spatial;
render_mode unshaded, cull_disabled, depth_prepass_alpha, alpha_to_coverage_and_one;
uniform vec4 color;
uniform float IOR;
uniform float multiplier;
uniform float additive;
uniform float expo;
varying vec4 criddles;

float fresnel(float amount, vec3 normal, vec3 view)
{
	return pow((1.0 - clamp(dot(normalize(normal), normalize(view)), 0.0, 1.0 )), amount);
}

void vertex() {
	// Called for every vertex the material is visible on.
	criddles = clamp(COLOR, 0.0, 1.0);
}

void fragment() {
	// Called for every pixel the material is visible on.
	
	vec3 crossp = NORMAL;
	ALBEDO = color.xyz * criddles.xyz * min(pow(IOR-fresnel(multiplier, crossp, VIEW)+additive, expo), 1.0);
	ALPHA = color.a * criddles.a * min(pow(IOR-fresnel(multiplier, crossp, VIEW)+additive, expo), 1.0);
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
