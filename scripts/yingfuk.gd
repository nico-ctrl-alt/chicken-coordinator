class_name Yingfuk
extends Squiggle

@export var speed = 15.0;
@export var rawspeed = 2.0;
@export var jump = 100.0;
@export var dash = 100.0;

var player
var target;
var interest_pos = Vector3.UP * 5.0;
var target_velocity = Vector3.ZERO
var strategy = ""
var lefthandball;
var righthandball;
var strategies = ["smack", "ball", "collab", "defense"]
@export var headpermutations = []
@export var maskpermutations = []
var iwanttojump = false
var isgrounded = false;
var teammate;
var pickupanim = 0.0;
var timetothrow = 0.0;
var delaytoswitch = 1.0;
var link = 0.0
var way = 1.0;


var attack = true

var wait = 0
var cur_radian = 0;
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	squig_ready()
	player = get_tree().current_scene.get_node("kami") as Squiggle
	copy_GI(player)
	interest_pos = player.global_position
	frequency = randf_range(0, PI*2)
	time += frequency
	var head = randi_range(0, len(headpermutations)-1)
	var mask = randi_range(0, len(maskpermutations)-1)
	
	for i in headpermutations :
		var head_vis = get_node("./birdle/Cube_022/head/" + i)
		head_vis.visible =  headpermutations[head] == i
	
	for i in maskpermutations :
		var mask_vis = get_node("./birdle/Cube_022/head/mask/" + i)
		mask_vis.visible =  maskpermutations[mask] == i
	
	bones = {
		"chest" : get_node("./birdle/Cube_022"),  
		"comumbus" : get_node("./birdle/Cube_022/Cube_030"),
		"comumbu" : get_node("./birdle/Cube_022/Cube_030/Cube_031"),
		"comumb" : get_node("./birdle/Cube_022/Cube_030/Cube_031/Cube_032"),
		"comum" : get_node("./birdle/Cube_022/Cube_030/Cube_031/Cube_032/Cube_033"),
		"com" : get_node("./birdle/Cube_022/Cube_030/Cube_031/Cube_032/Cube_033/Cube_034"),
		"co" : get_node("./birdle/Cube_022/Cube_030/Cube_031/Cube_032/Cube_033/Cube_034/Cube_035"),
		"l_arm" : get_node("./birdle/Cube_022/Cube_026"),
		"l_forearm" : get_node("./birdle/Cube_022/Cube_026/Cube_027"),
		"r_arm" : get_node("./birdle/Cube_022/Cube_024"),
		"r_forearm" : get_node("./birdle/Cube_022/Cube_024/Cube_025"),
		"head" : get_node("./birdle/Cube_022/head"),
		}
	set_bones()
	pass # Replace with function body.

func fly_anim(animspeed : float, delta : float) -> void:
	cur_anim = "f"
	var atime = time *animspeed;
	var wingflap = sin(clamp(atime, 0.0001,100.0))*2
	var wingflap1 = clamp((sin(atime+PI))*2,0.0, 25.0)
	var gordon = 0.0
	set_rot("chest", atime, Vector3(0,0,0))
	if target_velocity.y > -5 && fire_particles.visible == false  && d_time <= .1 : 
		set_rot("l_arm", atime, Vector3(0,0,wingflap))
		set_rot("r_arm", atime, Vector3(0,0,wingflap))
		set_rot("l_forearm", atime, Vector3(0,0,wingflap))
		set_rot("r_forearm", atime, Vector3(0,0,wingflap))
		g += wingflap1*200.0*delta
		gordon = wingflap
	else :
		set_rot("r_arm", atime, Vector3(-PI/3,0,-2 * PI))
		set_rot("l_arm", atime, Vector3(-PI/8,PI/5,PI))
		set_rot("l_forearm", atime, Vector3(0,0,0))
		set_rot("r_forearm", atime, Vector3(0,0,0))
	play_mod_sound($flyingissofun, (gordon/5.0)+1.0, 1.0, 1.0+(g/10.0), dubsin(g))
	
func link_anim(animspeed: float, delta: float) -> void:
	cur_anim = "l"
	var atime = (time-timestarted) * animspeed;
	set_rot("chest", atime, Vector3(0,0,atime * 3.0))
	pass
	
func smack_anim(animspeed: float, delta: float) -> void:
	cur_anim = "s"
	var atime = (time-timestarted) * animspeed;
	set_rot("chest", atime, Vector3(atime * 3.0,0,0))
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	
	
	if link <= .1 && smack <= .1  :
		fly_anim(target_velocity.y/10.0, delta)
	
	if health > 0 :
		wobble_wobble(delta, [bones["comumbu"], bones["comum"], bones["com"], bones["co"]], 1.0 + (smack * 3.0))
	
	process_fall()
	
	if smack > 0.1 :
		smack_anim(smack*60.0, delta)
	
	global_rotation = lerp(global_rotation, e_lookrot(Vector3.UP, -target_velocity), delta * 5.0);
	
	time += delta
	
	if link > 0.1 :
		link_anim(link * 20.0, delta)
	
	timetothrow = lerp(timetothrow, 0.0, delta * 2.0);
	smack = lerp(smack, 0.0, delta * 2.0);
	link = lerp(link, 0.0, delta * 2.0);
	pickupanim = lerp(pickupanim, 0.0, delta * 2.0);
	cur_radian = time/rawspeed * way
	delaytoswitch = lerp(delaytoswitch, 0.0, delta * 2.0)
	d_time = lerp(d_time, 0.0, delta * 10.0)
	
	interest_pos = player.global_position + (player.velocity *3) if attack && interest_pos.distance_to(global_position) > 5.5 else interest_pos
	
	var mushypoi = interest_pos
	mushypoi += (Vector3.UP * (2.0 if mushypoi.distance_to(global_position) > 5.5 else 0.0));
	
	target_velocity = lerp(target_velocity, (-(global_position-mushypoi).normalized()) *(speed if !is_on_floor() else 0), delta * 2)
	
	if global_position.distance_to(mushypoi) < 6 && delaytoswitch <= 0:
		var runaway = fwens[randi_range(0, len(fwens)-1)] if len(fwens) > 0 else (-player.basis.z + Vector3.UP)*20
		attack = !attack
		interest_pos = player.global_position + (player.velocity *3) if attack else runaway
		delaytoswitch = 3 + frequency
	
	var wingspan = bones["l_forearm"].get_node("Icosphere_021").global_position.distance_to(bones["r_forearm"].get_node("Icosphere_015").global_position)/2 if health > 0 else 0;
	
	g = lerp(g, -fall/(wingspan), delta*2.0)
	
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
				timestarted = time
				link = .5
			if collision.get_collider().name == "ground" :
				isgrounded = true
			if collision.get_collider().name.contains("bombproj") && pickupanim <= 0.1:
				pickupanim = 2.0
				timetothrow = 2.0
				timestarted = time
				lefthandball = collision.get_collider()
			if collision.get_collider() is Kami :
				smack = 1.0
				timestarted = time
				collision.get_collider().smanish(25, 4.0, (target_velocity+Vector3.UP).normalized()*10, collision.get_position())
				bounce_vel -=(target_velocity+Vector3.UP).normalized()*10
	pass
