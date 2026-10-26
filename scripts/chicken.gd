class_name Chicken
extends Squiggle


@export var speed = 5.0
@export var j_vel = 3.0
@export var Player : Kami
var bite = 0.0;
var source = null;
var dir;
var timer1= 0.0
var t_pos;

func walk_anim(animspeed : float, amp : float) -> void :
	cur_anim = "w"
	var atime = time * animspeed
	set_rot_skele("chest", atime, Vector3(sin(atime)/4,0,0), amp)
	set_rot_skele("neck", atime, Vector3(0,sin(atime/2 + PI)/4,0), amp)
	set_rot_skele("l_leg", atime, Vector3(0,0,sin(-atime)/2),amp)
	set_rot_skele("l_foot", atime, Vector3(0,0,sin(atime+PI/2)+.5),amp)
	set_rot_skele("r_leg", atime, Vector3(0,0,sin(-atime+PI)/2),amp)
	set_rot_skele("r_foot", atime, Vector3(0,0,sin(atime-PI/2)+.5),amp)
	pass



func _ready() -> void:
	squig_ready()
	Player = get_tree().current_scene.get_node("kami") as Squiggle
	copy_GI(Player)
	frequency = randf_range(0, PI*2)
	time += frequency
	bones = {
		"root" : skele.find_bone("Bone"),
		"chest" : skele.find_bone("Bone.021"),
		"neck" : skele.find_bone("Bone.022"),
		"head" : skele.find_bone("Bone.023"),
		"jaw_low" : skele.find_bone("Bone.025"),
		"giblet1" : skele.find_bone("Bone.026"),
		"giblet2" : skele.find_bone("Bone.027"),
		"jaw_high" : skele.find_bone("Bone.024"),
		"l_hip" : skele.find_bone("Bone.020"),
		"l_leg" : skele.find_bone("Bone.012"),
		"l_foot" : skele.find_bone("Bone.013"),
		"r_hip" : skele.find_bone("Bone.003"),
		"r_leg" : skele.find_bone("Bone.004"),
		"r_foot" : skele.find_bone("Bone.005"),
	}
	dir = Vector3(1,0,0)
	set_bones_skele()
	pass

	
	
func bite_anim(animspeed : float, delta : float, amp : float) -> void :
	cur_anim = "s"
	var atime = time * animspeed
	set_rot_skele("head", atime, Vector3(atime,0,0/10), amp)
	


func _process(delta: float) -> void:
	# Add the gravity.
	walk_anim(25.0, 1.0)
	
	process_fall()
	
	render_healthbar(delta)
	
	
	bite = lerp(bite, 0.0, delta)
	
	if bite > 0.1 : 
		bite_anim(5.0, delta, bite)
		
		
	d_time = lerp(d_time, 0.0, delta * 10.0)
	time += delta
	if not is_on_floor():
		g = lerp(g, -fall, delta)
	else :
		g = 0.0
		
	bounce_vel = lerp(bounce_vel, Vector3.ZERO, delta)
	
	source = ecosys._smell_closest(self, 20.0)
	
	timer1 = lerp(timer1, 0.0, delta * 2.0)
	
	if timer1 < .1 :
		t_pos = Vector3(randf(),0, randf())*100.0
		timer1 = 15.0
	
	var t_dir = (source.global_position-global_position).normalized() if source else (t_pos-global_position).normalized()
	var direction =t_dir *speed*tmp_speed
	
	global_rotation = lerp(global_rotation, e_lookrot(Vector3.UP, Vector3(direction.x,0,direction.z), Vector3(0,0,0)), delta * 5.0)
	if (direction.y > 2.0) && is_on_floor():
		g = j_vel * clamp(direction.y, 0, 8)
		bounce_vel += direction/2
	velocity = (-basis.z.normalized() * speed * tmp_speed) + g*Vector3.UP

	velocity += bounce_vel

	move_and_slide()
	if is_vis() :
		for i in get_slide_collision_count():
			var collision = get_slide_collision(i)
			if collision.get_collider() is Kami :
				bite = 1.0
				collision.get_collider().smanish(25, 4.0, direction+Vector3.UP, collision.get_position())
				bounce_vel -= direction
