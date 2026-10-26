extends Squiggle

class_name Pennant

@export var speed = 5.0
@export var j_vel = 3.0
@onready var Player = get_tree().current_scene.get_node("kami")
var bite = 0.0;
var source = null;
var dir;
var timer1= 0.0
var t_pos = Vector3(100,100,100);



func _ready() -> void:
	squig_ready()
	frequency = randf_range(0, PI*2)
	time += frequency

	dir = Vector3(1,0,0)
	pass

	
	



func _process(delta: float) -> void:
	var dist = Player.global_position.distance_to(global_position) 
	
	lod_skin(dist > 20)
	
	render_healthbar(delta)
	
	timer1 = lerp(timer1, 0.0, delta * 2.0)
	
	if timer1 < .1 :
		t_pos = Vector3(randf()-.5,.3, randf()-.5)*1000.0
		timer1 = 5.0
	
	var t_dir = global_position.direction_to(t_pos)
	
	g = t_dir.y
	
	global_rotation = lerp(global_rotation, e_lookrot(Vector3.UP, t_dir, Vector3(0,-PI/2,0)), delta * 5.0)
	velocity = (-basis.z.normalized() * speed * tmp_speed) + g*Vector3.UP

	velocity += bounce_vel

	move_and_slide()
	if is_vis() && dist < 30 :
		for i in get_slide_collision_count():
			var collision = get_slide_collision(i)
			if collision.get_collider() is Kami :
				bite = 1.0
				collision.get_collider().smanish(25, 4.0, t_dir+Vector3.UP, collision.get_position())
				bounce_vel -= t_dir
