class_name Lobsta

extends Squiggle

@export var speed = 5.0
@export var j_vel = 3.0
@export var Player : Kami

var bite = 0.0;


func _ready() -> void:
	Player = get_tree().current_scene.get_node("kami") as Squiggle
	copy_GI(Player)
	squig_ready()
	frequency = randf_range(0, PI*2)
	time += frequency
	bones = { 
		"abdominiumbus" : get_node("./lobsta"),
		"abdominium" : get_node("./lobsta/Cube_083"),
		"abdomin" : get_node("./lobsta/Cube_083/Cube_084"),  
		"abdom" : get_node("./lobsta/Cube_083/Cube_084/Cube_085"),
		"abdo" : get_node("./lobsta/Cube_083/Cube_084/Cube_085/Cube_086"),
		"ab" : get_node("./lobsta/Cube_083/Cube_084/Cube_085/Cube_086/Cube_087"), 
		"r_leg" : get_node("./lobsta/Cylinder_036"),
		"r_calf" : get_node("./lobsta/Cylinder_036/Cylinder_037"),
		"r_le" : get_node("./lobsta/Cylinder_025"),
		"r_ca" : get_node("./lobsta/Cylinder_025/Cylinder_033"),
		"r_l" : get_node("./lobsta/Cylinder_034"),
		"r_c" : get_node("./lobsta/Cylinder_034/Cylinder_035"),
		"l_leg" : get_node("./lobsta/Cylinder_042"),
		"l_calf" : get_node("./lobsta/Cylinder_042/Cylinder_043"),
		"l_le" : get_node("./lobsta/Cylinder_038"),
		"l_ca" : get_node("./lobsta/Cylinder_038/Cylinder_039"),
		"l_l" : get_node("./lobsta/Cylinder_040"),
		"l_c" : get_node("./lobsta/Cylinder_040/Cylinder_041"),
		"mouth" : get_node("./lobsta/Cube_066/Cube_062"),
		"head" : get_node("./lobsta/Cube_066")}
	set_bones()
	pass

func walk_anim(animspeed : float, delta : float, amp : float) -> void :
	cur_anim = "s"
	var atime = time * animspeed
	set_rot("head", atime, Vector3(0,0,sin(atime-.2)/10), amp)
	set_rot("abdominium", atime, Vector3(0,0,sin(atime+.1)/5), amp)
	set_rot("abdomin", atime, Vector3(0,0,sin(atime+.2)/5), amp)
	set_rot("abdom", atime, Vector3(0,0,sin(atime+.3)/5), amp)
	set_rot("abdo", atime, Vector3(0,0,sin(atime+.4)/5), amp)
	set_rot("ab", atime, Vector3(0,0,sin(atime+.5)/5), amp)
	set_rot("r_leg", atime, Vector3(sin(atime),sin(atime)/2,sin(atime+PI/2)/2), amp/7.0)
	set_rot("r_calf", atime, Vector3(sin(atime+PI/2),sin(atime+PI/2)/2,sin(atime+PI/2)/2), amp/7.0)
	set_rot("r_le", atime, Vector3(sin(atime+PI/3),sin(atime+PI/3)/2,sin(atime+PI/3+PI/2)/2), amp/7.0)
	set_rot("r_ca", atime, Vector3(sin(atime+PI/3+PI/2),sin(atime+PI/3+PI/2)/2,sin(atime+PI/3+PI/2)/2), amp/7.0)
	set_rot("r_l", atime, Vector3(sin(atime+(2*PI)/3),sin(atime+(2*PI)/3)/2,sin(atime+(2*PI)/3+PI/2)/2), amp/7.0)
	set_rot("r_c", atime, Vector3(sin(atime+(2*PI)/3+PI/2),sin(atime+(2*PI)/3+PI/2)/2,sin(atime+(2*PI)/3+PI/2)/2), amp/7.0)
	set_rot("l_leg", atime, Vector3(cos(atime),cos(atime)/2,cos(atime+PI/2)/2), amp/7.0)
	set_rot("l_calf", atime, Vector3(cos(atime+PI/2),cos(atime+PI/2)/2,cos(atime+PI/2)/2), amp/7.0)
	set_rot("l_le", atime, Vector3(cos(atime+PI/3),cos(atime+PI/3)/2,cos(atime+PI/3+PI/2)/2), amp/7.0)
	set_rot("l_ca", atime, Vector3(cos(atime+PI/3+PI/2),cos(atime+PI/3+PI/2)/2,cos(atime+PI/3+PI/2)/2), amp/7.0)
	set_rot("l_l", atime, Vector3(cos(atime+(2*PI)/3),cos(atime+(2*PI)/3)/2,cos(atime+(2*PI)/3+PI/2)/2), amp/7.0)
	set_rot("l_c", atime, Vector3(cos(atime+(2*PI)/3+PI/2),cos(atime+(2*PI)/3+PI/2)/2,cos(atime+(2*PI)/3+PI/2)/2), amp/7.0)
	
	if abs(sin(atime+PI/2)) < .1  || abs(sin(atime+PI/3 + PI/2)) < .1 || abs(sin(atime+(2*PI)/3)) < .1 :
		play_mod_sound($dev, 1.0, 2.0, 10-global_position.distance_to(Player.global_position), .1)
	
	#set_rot("abdominiumbus", atime, e_lookrot(Vector3.UP, Player.global_position - global_position), amp)
	
	
func bite_anim(animspeed : float, delta : float, amp : float) -> void :
	cur_anim = "s"
	var atime = time * animspeed
	set_rot("head", atime, Vector3(atime,0,0/10), amp)
	


func _process(delta: float) -> void:
	# Add the gravity.
	walk_anim(10.0, delta, -velocity.length()/6.5)
	
	process_fall()
	
	render_healthbar(delta)
	
	bite = lerp(bite, 0.0, delta)
	
	if bite > 0.1 : 
		bite_anim(5.0, delta, bite)
		
		
	time += delta
	if not is_on_floor():
		g = lerp(g, -fall, delta)
	else :
		g = 0.0
		
	bounce_vel = lerp(bounce_vel, Vector3.ZERO, delta)
	
	# Handle jump.

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = (Player.global_position-global_position).normalized()*speed*tmp_speed
	
	global_rotation = e_lookrot(Vector3.UP, Vector3(direction.x,0,direction.z), Vector3(0,PI/2,0))
	if (direction.y > 2.0) && is_on_floor():
		g = j_vel * clamp(direction.y, 0, 8)
		bounce_vel += direction/2
	velocity = Vector3(direction.x, g, direction.z)

	velocity += bounce_vel

	move_and_slide()
	if is_vis() :
		for i in get_slide_collision_count():
			var collision = get_slide_collision(i)
			if collision.get_collider() is Kami :
				bite = 1.0
				collision.get_collider().smanish(25, 4.0, direction+Vector3.UP, collision.get_position())
				bounce_vel -= direction
