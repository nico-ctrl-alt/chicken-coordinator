extends Squiggle
class_name Synapsid

@export var speed = 10.0
@export var jump = 20.0

var player
var diceroll = 0
var parry = false
var parswing = 0.0
var target : Squiggle
var stops = false
var col_normal = Vector3.UP
var raycast : Dictionary
var vis : bool
var dist : float

func _ready() -> void :
	
	squig_ready()
	player = get_tree().current_scene.get_node("kami") as CharacterBody3D
	copy_GI(player)
	bones = {
			"root" : skele.find_bone("Bone"),
			"spine" : skele.find_bone("Bone.009"),
			"spine_1" : skele.find_bone("Bone.010"),
			"neck" : skele.find_bone("Bone.011"),
			"high_head" : skele.find_bone("Bone.012"),
			"high_jaw" : skele.find_bone("Bone.013"),
			"low_head" : skele.find_bone("Bone.014"),
			"low_jaw" : skele.find_bone("Bone.015"),
			"l_shoulder" : skele.find_bone("Bone.024"),
			"l_arm" : skele.find_bone("Bone.025"),
			"l_forearm" : skele.find_bone("Bone.026"),
			"l_hand_1" : skele.find_bone("Bone.027"),
			"r_shoulder" : skele.find_bone("Bone.020"),
			"r_arm" : skele.find_bone("Bone.021"),
			"r_forearm" : skele.find_bone("Bone.022"),
			"r_hand_1" : skele.find_bone("Bone.023"),
			"l_hip" : skele.find_bone("Bone.001"),
			"l_leg" : skele.find_bone("Bone.002"),
			"l_calf" : skele.find_bone("Bone.003"),
			"l_foot" : skele.find_bone("Bone.004"),
			"r_hip" : skele.find_bone("Bone.005"),
			"r_leg" : skele.find_bone("Bone.006"),
			"r_calf" : skele.find_bone("Bone.007"),
			"r_foot" : skele.find_bone("Bone.008"),
		}
	set_bones_skele()
		
func _walk(delta: float, amp: float, speed: float) -> void:
	var atime = speed * time
	set_rot_skele("spine", atime, Vector3(0,sin(atime)/8,sin(atime-PI/2)/4), amp)
	set_rot_skele("spine_1", atime, Vector3(0,sin(atime)/8,sin(atime)/4), amp)
	set_rot_skele("neck", atime, Vector3(0,sin(atime/2 + PI)/4,0), amp)
	
	set_rot_skele("l_leg", atime, Vector3(0,0,sin(-atime)/2),amp)
	set_rot_skele("l_calf", atime, Vector3(0,0,sin(atime+PI/2)+.5),amp)
	set_rot_skele("l_foot", atime, Vector3(0,0,sin(atime-PI/8)+.5),amp)
	
	set_rot_skele("r_leg", atime, Vector3(0,0,sin(-atime+PI)/2),amp)
	set_rot_skele("r_calf", atime, Vector3(0,0,sin(atime-PI/2)+.5),amp)
	set_rot_skele("r_foot", atime, Vector3(0,0,sin(-atime+PI)/8),amp)
	
	set_rot_skele("r_arm", atime, Vector3(0,sin(atime-PI/2)+.5,0),amp)
	set_rot_skele("r_forearm", atime, Vector3(0,sin(-atime+PI)/2,0),amp)
	set_rot_skele("r_hand_1", atime, Vector3(0,0,sin(atime-PI/8)+.5),amp)
	
	set_rot_skele("l_arm", atime, Vector3(0,sin(-atime+PI)/2,0),amp)
	set_rot_skele("l_forearm", atime, Vector3(0,sin(atime-PI/2)+.5,0),amp)
	set_rot_skele("l_hand_1", atime, Vector3(0,0,sin(-atime+PI)/8),amp)
	
func _parry(delta: float, amp: float, speed: float, btime : float) -> void:
	var atime = speed * time
	set_rot_skele("root", atime, Vector3(0,btime/4,0), amp)
	set_rot_skele("spine", atime, Vector3(0,0, -btime/6), amp)
	set_rot_skele("spine_1", atime, Vector3(0,0,-btime/6), amp)
	set_rot_skele("spine_1", atime, Vector3(0,0,-btime/6), amp)
	


func _process(delta: float) -> void:
	vis = is_vis()
	dist = player.global_position.distance_to(global_position) 
	stops = !vis || dist > 250
	
	for i in skin :
		i.visible = !(!vis || dist > 400)
		
	if stops :
		return
	
	lod_skin(dist > 50)
	
	raycast = where_to_target(player)
	
	target = ecosys._smell_closest_squiggle(self, 500.0)
	time+=delta
	if !parry && !stops && target:
		_walk(delta, 1.0, 10.0 if !parry else 0.0)
	var tmp_vel = (target.global_position - global_position).normalized()* speed if target else Vector3.ZERO
	var dir_to_travel = basis.z if !parry else basis.x/3.0;
	velocity = Vector3(0, g, 0) + (dir_to_travel*speed) + bounce_vel
	g = lerp(g, -fall, delta) if !is_on_floor() else (jump if tmp_vel.y > 10.0 else 0.0)
	bounce_vel = lerp(bounce_vel, Vector3.ZERO, delta * 5.0)
	global_rotation = lerp(global_rotation, e_lookrot(col_normal, tmp_vel, Vector3(0,PI,0)), delta)	
	
	if !stops :
		render_healthbar(delta)
		process_fall()
	
	
	if target && target.global_position.distance_to(global_position) < 20.0 :
		diceroll = randi_range(0,500)
		
	if diceroll == 50 :
		parry = true
		
	if diceroll == 51 :
		parry = false
		
		
	parswing = lerp(parswing, 0.0, delta * 5.0)
	
	if (parswing > 0 || parry) && !stops :
		_parry(delta, -(parswing -.5)*10.0, 1.0, 1.0)
	
	move_and_slide()
	
	if vis && !stops :	
		for i in get_slide_collision_count():
			var collision = get_slide_collision(i)
			var s = collision.get_collider() as Squiggle
			if s :
				bounce_vel += (global_position - collision.get_collider().global_position).normalized() * (10.0 if not parry else -10.0) 
				if parry && parswing <= .1:
					parswing = 10.0
					s.smanish(25.0, 100.0, global_position.direction_to(s.global_position), global_position, 1.0)
					parry = true
				continue
			else :
				col_normal = collision.get_normal()
			
