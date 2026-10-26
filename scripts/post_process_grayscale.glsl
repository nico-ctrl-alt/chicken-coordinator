#[compute]
#version 450

// Invocations in the (x, y, z) dimension
layout(local_size_x = 8, local_size_y = 8, local_size_z = 1) in;

layout(rgba16f, set = 0, binding = 0) uniform image2D color_image;

// Our push constant
layout(push_constant, std430) uniform Params {
	vec2 raster_size;
	vec2 reserved;
	float time;
	float pixel_size;
	float sinsize;
	float cutoff;
} params;

// The code we want to execute in each invocation
void main() {
	ivec2 uv = ivec2(gl_GlobalInvocationID.xy);
	vec2 rv = gl_GlobalInvocationID.xy/params.raster_size;
	vec2 xv = gl_GlobalInvocationID.xy/params.raster_size;
	ivec2 size = ivec2(params.raster_size);

	// Prevent reading/writing out of bounds.
	if (uv.x >= size.x || uv.y >= size.y) {
		return;
	}

	// Read from our color buffer.

	rv += sin(rv.y * 10.0 + params.time)*params.sinsize;
	vec2 uv2 = vec2(fract(vec2(rv) * vec2(params.pixel_size,params.pixel_size)));
	//xv += length(rv-vec2(.5));
	//uv2 += length(rv-vec2(.5));
	vec4 color = imageLoad(color_image, ivec2(xv*params.raster_size));
	// Apply our changes.
	vec3 rgb = vec3(step(uv2.x, .3), step(uv2.x, .7)-step(uv2.x, .35), step(1.0-uv2.x, .3));
	rgb = mix(rgb, vec3(0.0), step(uv2.y, .05)) + .2;
	float r = rgb.r * color.r;
	float g = rgb.g * color.g;
	float b = rgb.b * color.b;
	color.rgb = vec3(r,g,b*1.2) * 3.0;

	// Write back to our color buffer.
	imageStore(color_image, uv, color);
}
