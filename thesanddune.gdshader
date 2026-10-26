shader_type particles;

uniform float scale = .1;

void start() {
	// Called when a particle is spawned.
	TRANSFORM[0].x = scale;
	TRANSFORM[1].y = scale;
	TRANSFORM[2].z = scale;
}

void process() {
	// Called every frame on existing particles (according to the Fixed FPS property)
	TRANSFORM[3].xy = EMISSION_TRANSFORM[3].xy + vec2(sin(float(INDEX) + TIME), cos(float(INDEX) + TIME)) * 80.0;
	TRANSFORM[0].x = sin(float(INDEX) + TIME) * scale;
	TRANSFORM[1].y = sin(float(INDEX) + TIME) * scale;
	TRANSFORM[2].z = sin(float(INDEX) + TIME) * scale;
}
