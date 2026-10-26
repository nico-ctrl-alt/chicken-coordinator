shader_type spatial;
render_mode unshaded, blend_add, cull_disabled;

varying float seed;
uniform vec3 color;

void vertex() {
	// Called for every vertex the material is visible on.
	seed = COLOR.r;
}

void fragment() {
	// Called for every pixel the material is visible on.
	float time = seed + TIME;
	
	mat2 matrix = mat2(vec2(cos(time), -sin(time)), vec2( sin(time), cos(time)));
	mat2 matrix1 = mat2(vec2(cos(time*2.), -sin(time*2.)), vec2( sin(time*2.), cos(time*2.)));
	
	vec2 uv = UV + vec2(-.5,-.5);
	float ball = 1.-dot(uv,uv);
	vec2 luv1 = ((UV + vec2(-.5,-.5)) * 10. + (1.-ball)) * matrix1;
	vec2 luv2 = ((UV + vec2(-.5,-.5)) * 10. + (1.-ball)) * matrix;
	float line1 = 1.-smoothstep(((luv1.x)+(fract(time/2.)*30.)) + sin(((luv1.y) + time*3.) * 4.)/10., .9,1.);
	float line2 = 1.-smoothstep(((luv2.y)+(fract(-time+PI)*30.)) + cos(((luv2.x) + (-time+PI)*5.) * 3.)/4., .9,1.);
	ALBEDO =  color.xyz * (line1+line2)*pow(ball,50.);
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
