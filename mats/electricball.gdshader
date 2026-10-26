shader_type particles;

void start() {
	// Called when a particle is spawned.
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

void process() {
	// Called every frame on existing particles (according to the Fixed FPS property).
	float dist = 10.;
	uint seed = NUMBER+RANDOM_SEED;
	float speed = .0001 * DELTA;
	COLOR = vec4(rand_from_seed(seed),0.,0.,.0);
	VELOCITY = -normalize(TRANSFORM[3].xyz-EMISSION_TRANSFORM[3].xyz) * speed;
}
