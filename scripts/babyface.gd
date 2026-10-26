class_name BabyFace

extends Squiggle

@export var speed = 15.0;
@export var rawspeed = 2.0;
@export var jump = 100.0;
@export var dash = 100.0;

var target_velocity = Vector3.ZERO
@export var circle_range = 1
var strategy = ""
var lefthandball;
var righthandball;
var strategies = ["smack", "ball", "collab", "defense"]
@export var headpermutations = []
@export var bodypermutations = []
var iwanttojump = false
var isgrounded = false;
var teammate;
var pickupanim = 0.0;
var timetothrow = 0.0;
var delaytoswitch = 1.0;
var link = 0.0
var way = 1.0;

var wait = 0
var cur_radian = 0;

@export var player : Squiggle

func stalk_anim(animspeed: float, delta: float) -> void:
	cur_anim = "st"
	
	var atime = time * animspeed;
	
	if abs(sin(atime)) < .1 :
		play_mod_sound($skate,1,2.0, .5+sin(cur_radian),.4,cos(cur_radian),.3)
	
	set_rot("r_leg", atime, Vector3(cos((atime+PI)/2)/2, sin(atime), 0))
	set_rot("l_leg", atime, Vector3(cos((atime+PI)/2)/2, sin(atime+PI), 0))
	set_rot("chest", atime, Vector3(sin(atime/2)/2,cos(atime/2)/2,0))
	set_rot("head", atime, Vector3(cos((atime+PI)/2)/2,0,0))
	set_rot("l_arm", atime, Vector3(cos((atime)/2)/2,0,0))
	set_rot("r_arm", atime, Vector3(cos((atime)/2)/2,0,0))
	pass
	
func smack_anim(animspeed: float, delta: float) -> void:
	cur_anim = "s"
	var atime = (time-timestarted) * animspeed;
	set_rot("chest", atime, Vector3(0,atime * 3.0,0))
	set_rot("l_arm", atime, Vector3(sin((atime)) * 3,cos((atime)) * 3,PI/2))
	set_rot("r_arm", atime, Vector3(cos((atime)) * 3,sin((atime)) * 3,PI/2))
	pass
	
func pickup_anim(animspeed: float, delta: float, timestarted : float) -> void:
	if health <= 0 : 
		return
	cur_anim = "p"
	var atime = (time-timestarted) * animspeed;
	set_rot("chest", atime, Vector3(sin(atime/2)/2,cos(atime/2)/2,0))
	bones["head"].look_at_from_position(bones["head"].global_position, (bones["head"].global_position-player.global_position));
	bones["head"].rotate(Vector3.UP - Vector3.FORWARD, PI)
	set_rot("l_arm", atime, Vector3(0,cos((atime)) * 3,0))
	set_rot("r_arm", atime, Vector3(0,sin((atime)) * 3,0))
	set_rot("r_leg", atime, Vector3(cos((atime+PI)/2)/2, sin(atime), 0))
	set_rot("l_leg", atime, Vector3(cos((atime+PI)/2)/2, sin(atime+PI), 0))
	pass
	

	
func throw_anim(animspeed: float, delta: float) -> void:
	pass
	
func link_anim(animspeed: float, delta: float) -> void:
	cur_anim = "l"
	var atime = (time-timestarted) * animspeed;
	set_rot("chest", atime, Vector3(0,atime * 3.0,0))
	pass
	
func air_anim(animspeed: float, delta: float) -> void:
	cur_anim = "l"
	var atime = (time) * animspeed;
	set_rot("chest", atime, Vector3(atime,0,0))
	pass

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	player = get_tree().current_scene.get_node("kami") as CharacterBody3D
	copy_GI(player)
	squig_ready()
	frequency = randf_range(0, PI*2)
	time += frequency
	var head = randi_range(0, len(headpermutations)-1)
	var body = randi_range(0, len(bodypermutations)-1)
	
	var shoulder_cam = randi_range(0, 1) > 0
	
	for i in headpermutations :
		var head_vis = get_node("./babyface/Cube_001/Cylinder/Cube/" + i)
		head_vis.visible =  headpermutations[head] == i
	
	for i in bodypermutations :
		var body_vis = get_node("./babyface/Cube_001/" + i)
		body_vis.visible =  bodypermutations[body] == i
		
	var shoulder_cam_vis = get_node("./babyface/Cube_001/Cube_007")
	shoulder_cam_vis.visible = shoulder_cam;
	
	bones = {
		"chest" : get_node("./babyface/Cube_001"),  
		"gear" : get_node("./babyface/Cube_001/Circle"),
		"r_leg" : get_node("./babyface/Cube_001/Cylinder_003"),
		"r_calf" : get_node("./babyface/Cube_001/Cylinder_003/Cylinder_004"),
		"l_leg" : get_node("./babyface/Cube_001/Cylinder_001"),
		"l_calf" : get_node("./babyface/Cube_001/Cylinder_001/Cylinder_002"),
		"l_arm" : get_node("./babyface/Cube_001/Cylinder_005"),
		"l_forearm" : get_node("./babyface/Cube_001/Cylinder_005/Cube_002"),
		"l_palm" : get_node("./babyface/Cube_001/Cylinder_005/Cube_002/Cylinder_006"),
		"r_arm" : get_node("./babyface/Cube_001/Cylinder_007"),
		"r_forearm" : get_node("./babyface/Cube_001/Cylinder_007/Cube_003"),
		"r_palm" : get_node("./babyface/Cube_001/Cylinder_007/Cube_003/Cylinder_008"),
		"neck" : get_node("./babyface/Cube_001/Cylinder"),
		"head" : get_node("./babyface/Cube_001/Cylinder/Cube"),
		"shoulder_cam" : get_node("./babyface/Cube_001/Cube_007")}
	set_bones()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.d
func _process(delta: float) -> void:
	
	var interestdir = Vector3.ZERO
	if len(interests) > 0 :
		interestdir = (interests.keys()[0].global_position - global_position).normalized()*2
		interests[interests.keys()[0]] -= delta
		if interests[interests.keys()[0]] <= 0 :
			interests.erase(interests.keys()[0])
	
	time += delta
	
	timetothrow = lerp(timetothrow, 0.0, delta * 2.0);
	smack = lerp(smack, 0.0, delta * 2.0);
	link = lerp(link, 0.0, delta * 2.0);
	pickupanim = lerp(pickupanim, 0.0, delta * 2.0);
	cur_radian = time/rawspeed * way
	delaytoswitch = lerp(delaytoswitch, 0.0, delta * (110.0-health)/50.0)
	d_time = lerp(d_time, 0.0, delta * 10.0)
	
	if delaytoswitch < .1 :
		delaytoswitch = randf_range(1.0,4.0);
		way *= -1.0; 
	
	if pickupanim > .1 && smack <.1:
		pickup_anim(4.0, delta, timestarted)
	
	var desiredpos = (player.global_position + (Vector3(sin(cur_radian+ frequency),0,cos(cur_radian+frequency)))*(sin(time + frequency)*circle_range))
	var dir = (global_position - desiredpos).normalized() if desiredpos.distance_to(global_position) > 2 else (player.global_position - global_position).normalized();
	
	pickupanim = lerp(pickupanim, 0.0, delta)
	
	if  (lefthandball && health > 0) && (timetothrow < .5 || lefthandball.timetoblow < .2): 
		var ball = lefthandball
		var throwplay = len(fwens) > 0 && randf_range(0, 10) > 7;
		var fwen = fwens[randi_range(0, len(fwens)-1)] if len(fwens) > 0 else null
		throwplay = true if fwen == null else throwplay
		var balldir = (-(global_position - player.global_position).normalized() if throwplay else -(global_position - fwen.global_position).normalized() + fwen.velocity.normalized()/2 + Vector3.UP/20)
		ball.apply_impulse(balldir * 250.0)
		if fwen && !throwplay :
			fwen.interests[ball] = 1.0
		var part = ball.get_node("./particulator") as GPUParticles3D
		part.material_override = part.material_override.duplicate()
		ball.timetoblow = 1.0 if throwplay else 4.0
		lefthandball = null
		pickupanim = 1.0
		
	if  (righthandball && health > 0) && (timetothrow < .5): 
		var ball = righthandball
		var smackplay = len(fwens) > 0 && randf_range(0, 10) > 7;
		var fwen = fwens[randi_range(0, len(fwens)-1)] if len(fwens) > 0 else null
		smackplay = true if fwen == null else smackplay
		var is_player = ball as Kami
		var final_throw = Vector3.UP * 1.5 if is_player else (-(global_position - player.global_position).normalized() * 3.0)
		var balldir = ( final_throw if fwen == null else -(global_position - fwen.global_position).normalized() + fwen.velocity.normalized()/2 + Vector3.UP)
		ball.bounce_vel = balldir * 50.0 
		ball.global_position += balldir * 2.0
		ball.a_time = 0.0
		ball.g = 0.0
		if fwen && !smackplay :
			fwen.smack = 2.0
			fwen.timestarted = time
			fwen.interests[player] = 1.0
			fwen.bounce_vel += (righthandball.global_position - fwen.global_position).normalized() * 5.0;
		else :
			interests[player] = 1.0
			smack = 6.0
			timestarted = time
			var playerdir = (righthandball.global_position - global_position).normalized()
			ball.velocity = Vector3.ZERO
		remove_collision_exception_with(ball)
		righthandball = null
		pickupanim = 1.0
	
	global_rotation = lerp(global_rotation, e_lookrot(Vector3.UP, target_velocity), delta*5.0)
	
	if wait > 0 && pickupanim < .1 && smack < .1:
		stalk_anim(7.0, delta)
		target_velocity = -(dir)* speed
	else :
		target_velocity = lerp(target_velocity, Vector3.ZERO, delta*2.0)
		wait = randf_range(2, 10)
	wait -= delta * 2.
	
	target_velocity =  Vector3(interestdir.x,0,interestdir.z)* speed*tmp_speed if len(interests) > 0 else target_velocity
	
	if smack > 0.1 :
		smack_anim(smack * 20.0, delta)
	
	if link > 0.1 :
		link_anim(link * 10.0, delta)
		
	if is_on_wall() && is_on_floor() :
		g = jump
	
	if not is_on_floor() :
		air_anim(10.0, delta);
		
	process_fall()
		
	render_healthbar(delta)
	
	if lefthandball && health > 0 :
		lefthandball.global_position = bones["l_palm"].global_position + Vector3(0,1,0);
	if righthandball && health > 0 :
		righthandball.global_position = bones["r_palm"].global_position + Vector3(0,1,0);
	
	g = (jump if iwanttojump else 0.0) if isgrounded else lerp(g, -fall, delta)
	
	render_healthbar(delta)
	
	velocity = Vector3(target_velocity.x, g, target_velocity.z) 
	bounce_vel = lerp(bounce_vel, Vector3.ZERO, delta)
	velocity += bounce_vel
	move_and_slide()
	isgrounded = false
	if is_vis() :	
		for i in get_slide_collision_count():
			var collision = get_slide_collision(i)
			if collision.get_collider().name.contains("baby") :
				add_fwen(collision.get_collider() as Squiggle, true)
				link = 2.0
			if collision.get_collider().name == "ground" :
				isgrounded = true
			if collision.get_collider().name.contains("bombproj") && pickupanim <= 0.1:
				pickupanim = 2.0
				timetothrow = 2.0
				timestarted = time
				lefthandball = collision.get_collider()
				print(lefthandball)
			if collision.get_collider() as Squiggle && pickupanim <= 0.1 :
				var player = collision.get_collider() as Squiggle
				if player == boss :
					break
				if smack < .1 :
					pickupanim = 2.0
					add_collision_exception_with(player)
					timetothrow = 2.0
					timestarted = time
					righthandball = collision.get_collider()
					print(righthandball)
				else :
					player.smanish(25.0, 1.0, -(global_position - player.global_position).normalized(), collision.get_position())
	
	pass
