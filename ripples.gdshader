shader_type spatial;
render_mode unshaded, blend_add, cull_disabled;
uniform vec4 color;
uniform float colors = 64.0;
uniform float rings = 3.0;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec2 uv = sin((UV + vec2(-.5)));
	vec3 ripple = vec3(1.0,1.0,1.0) * sin(length(abs(uv*rings))*10.0) * (1.0-length(UV+vec2(-.5))*1.0);
	ALBEDO = ripple * COLOR.rgb + 1.0/(1.0-ripple);
	ALPHA = floor(clamp(ALBEDO.g*(1.0-length(UV+vec2(-.5))*2.0),0.,1.)/10.0 * COLOR.a* colors)/colors  ;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
