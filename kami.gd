class_name Kami
extends Squiggle

@export var speed = 14;
@export var jump = 100.0;
@export var camdist = 15;
@export var sensitivity = 15;
@export var kami_icons : Array[Texture2D]
@onready var kami_icon : Sprite2D = $Camera3D/CanvasLayer2/Sprite2D
@onready var moise_left : Sprite2D = $Camera3D/CanvasLayer2/moise_left
@onready var moise_right : Sprite2D = $Camera3D/CanvasLayer2/moise_right
@onready var moise_body : Sprite2D = $Camera3D/CanvasLayer2/moise_body
@onready var earthbomb = $prticles;
@onready var waterchant = $waterbear/waterchant2
var camera;
var last_pos = Vector3.ZERO;
@export var fall_time = 4.0
var ogfall;
var target_velocity = Vector3.ZERO
var desired_rot = Vector3.ZERO
var mouse_lastpos;
var me;
var rot = 0;
var rot2 = 0;
var click = 0 
var wind = 0.0
var wall_jump = false
var click1 = 0
var destroyanim = 0.0
var canbomb = true;
var isgrounded = false;
var allbombs = []
@export var kidsounds : Array[AudioStream]
var kid = 0
var cur_armor = "earthkami2"
@export var kami_names = ["earthkami2"]
@export var kids = [0,1,2,3]
@onready var bomb_earth := preload("res://bombproj.tscn")
@onready var the_winds_beak := preload("res://windproj.tscn")
@onready var fire_homon :=  preload("res://fireproj.tscn")
var ripples_strength = 0.0
var dodge = 0.0;
var wind_strength = 0.0
var interact = false
@export var feet : Array[Node3D]
var foot_local_pos = Vector3(-.004, 0, -0.013)
var ticktock = 0
var wallvec = Vector3.ZERO
@export var wall_threshold = 0.0
@export var climb_threshold = 0.0

@onready var raycast = $RayCast3D;
@onready var treeclimbing := $treeclimbing
@onready var monkeybars := $monkeybars
var subcam 
var cam_shake = 0.0
var global_chest_rot
var climb_time = 0.0
@export var climb_curve : Curve
var ripplevec = Vector3.ZERO
var flap = 0.0
var lerp_flap = 0.0
@export var attack_curves : Array[Curve]
var l_punch = 0.0
var r_punch = 0.0
var l_kick = 0.0
var r_kick = 0.0
var fire_delay = 0.0

func death_override() -> void:
	kids.remove_at(kid)
	change_kid()

func left_punch() -> void :
	var success = 0
	var atime = time
	set_rot("l_arm", atime, Vector3(0,-PI/2,0), attack_curves[success].sample(1.0-l_punch))
	set_rot("l_forearm", atime, Vector3(0,0,PI), sin_curve(l_punch, attack_curves[success]))
	set_rot("chest", atime, Vector3(0,-PI,0), sin_curve(l_punch, attack_curves[success]))
	bones["l_palm"].scale = Vector3.ONE * attack_curves[success].sample(1.0-l_punch) * 2.0;
	pass
	
func right_punch() -> void :
	var success = 0
	var atime = time
	set_rot("r_arm", atime, Vector3(0,-PI,0), attack_curves[success].sample(1.0-r_punch))
	set_rot("r_forearm", atime, Vector3(0,0,PI), sin_curve(r_punch, attack_curves[success]))
	set_rot("chest", atime, Vector3(0,PI,0), sin_curve(r_punch, attack_curves[success]))
	bones["r_palm"].scale = Vector3.ONE * attack_curves[success].sample(1.0-r_punch) * 2.0;
	pass


func load_bones() -> void :
	cur_armor = kami_names[kid]
	
	bones = {
	"chest" : get_node(kami_names[kid] + "/Cube_001"),  
	"hips" : get_node(kami_names[kid] + "/Cube_001/Cube_002"),
	"r_leg" : get_node(kami_names[kid] + "/Cube_001/Cube_002/Cylinder_002"),
	"r_calf" : get_node(kami_names[kid] + "/Cube_001/Cube_002/Cylinder_002/Cylinder_003"),
	"l_leg" : get_node(kami_names[kid] + "/Cube_001/Cube_002/Cylinder_004"),
	"l_calf" : get_node(kami_names[kid] + "/Cube_001/Cube_002/Cylinder_004/Cylinder_005"),
	"l_arm" : get_node(kami_names[kid] + "/Cube_001/Cylinder_006"),
	"l_forearm" : get_node(kami_names[kid] + "/Cube_001/Cylinder_006/Cube_003"),
	"l_palm" : get_node(kami_names[kid] + "/Cube_001/Cylinder_006/Cube_003/Cube_004"),
	"l_fing1.1" : get_node(kami_names[kid] + "/Cube_001/Cylinder_006/Cube_003/Cube_004/Cube_005"),
	"l_fing1.2" : get_node(kami_names[kid] + "/Cube_001/Cylinder_006/Cube_003/Cube_004/Cube_005/Cube_006"),
	"l_fing2.1" : get_node(kami_names[kid] + "/Cube_001/Cylinder_006/Cube_003/Cube_004/Cube_007"),
	"l_fing2.2" : get_node(kami_names[kid] + "/Cube_001/Cylinder_006/Cube_003/Cube_004/Cube_007/Cube_008"),
	"l_fing3.1" : get_node(kami_names[kid] + "/Cube_001/Cylinder_006/Cube_003/Cube_004/Cube_009"),
	"l_fing3.2" : get_node(kami_names[kid] + "/Cube_001/Cylinder_006/Cube_003/Cube_004/Cube_009/Cube_010"),
	"r_arm" : get_node(kami_names[kid] + "/Cube_001/Cylinder_007"),
	"r_forearm" : get_node(kami_names[kid] + "/Cube_001/Cylinder_007/Cube_011"),
	"r_palm" : get_node(kami_names[kid] + "/Cube_001/Cylinder_007/Cube_011/Cube_012"),
	"r_fing1.1" : get_node(kami_names[kid] + "/Cube_001/Cylinder_007/Cube_011/Cube_012/Cube_013"),
	"r_fing1.2" : get_node(kami_names[kid] + "/Cube_001/Cylinder_007/Cube_011/Cube_012/Cube_013/Cube_014"),
	"r_fing2.1" : get_node(kami_names[kid] + "/Cube_001/Cylinder_007/Cube_011/Cube_012/Cube_015"),
	"r_fing2.2" : get_node(kami_names[kid] + "/Cube_001/Cylinder_007/Cube_011/Cube_012/Cube_015/Cube_016"),
	"r_fing3.1" : get_node(kami_names[kid] + "/Cube_001/Cylinder_007/Cube_011/Cube_012/Cube_018"),
	"r_fing3.2" : get_node(kami_names[kid] + "/Cube_001/Cylinder_007/Cube_011/Cube_012/Cube_018/Cube_019"),
	"neck" : get_node(kami_names[kid] + "/Cube_001/Cylinder_001"),
	"head" : get_node(kami_names[kid] + "/Cube_001/Cylinder_001/Cube"), 
	"mouthpiece" : get_node(kami_names[kid] + "/Cube_001/Cylinder_001/Cylinder")};
	
	feet[0].reparent(bones["r_calf"])
	feet[0].position = foot_local_pos
	feet[1].reparent(bones["r_calf"])
	feet[1].position = foot_local_pos
	
	if hip_pos != Vector3.ZERO :
		bones["chest"].position = hip_pos
		
	global_chest_rot = bones["chest"].global_rotation
	
	print(bones)
	for i in kami_names :
		if kami_names[kid] != i :
			get_node(i).hide()
	get_node(kami_names[kid]).show()

var hip_pos =Vector3.ZERO
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	load_bones()
	hip_pos = bones["chest"].position
	set_bones()
	camera = $Camera3D
	camdist = 15
	squig_ready()
	subcam= camera.get_node("SubViewport/Camera3D")
	pass # Replace with function body.

func idle_anim(animspeed: float, delta : float) -> void :
	cur_anim = "i"
	if is_on_wall_only() || l_punch > .1 :
		return
	var atime = time * animspeed
	if !is_on_wall_only() :
		set_rot("chest", atime, Vector3(0,sin(atime),0))
	set_rot("hips", atime, Vector3(0,0,sin(atime + PI)))
	set_rot("neck", atime, Vector3(sin(atime/2 + PI)/4.0,0,0))
	set_rot("mouthpiece", atime, Vector3(0, 0, cos(atime/2)))
	set_rot("l_leg", atime, Vector3(sin(atime)/16, 0, 0))
	set_rot("l_calf", atime, Vector3.ZERO)
	set_rot("r_leg", atime, Vector3(sin(atime)/16, 0, 0))
	set_rot("r_calf", atime, Vector3.ZERO)
	set_rot("r_arm", atime, Vector3.ZERO)
	set_rot("r_forearm", atime, Vector3.ZERO)
	if destroyanim < .1 :
		set_rot("l_arm", atime, Vector3.ZERO)
		set_rot("l_forearm", atime, Vector3.ZERO)
	if click == 1 :
		set_rot("chest", atime, Vector3.ZERO)
		set_rot("hips", atime, Vector3.ZERO)
	pass
	
func walk_anim(animspeed: float, delta : float, amp : float) -> void :
	cur_anim = "w"
	var atime = time * animspeed
	var jump_crouch = 2.0 if Input.is_action_pressed("jump") else 1.0
	if !is_on_wall_only() :
		set_rot("chest",atime, Vector3(PI/8*amp * jump_crouch,PI/2,-PI/2), 1.0)
	set_rot("hips", atime, Vector3(0,0,sin(-(atime))/2), amp)
	set_rot("neck", atime, Vector3(sin(atime + PI)/4,0,0), amp)
	set_rot("head", atime, Vector3(-sin(atime + PI)/4,-PI/5,0), amp)
	set_rot("mouthpiece", atime, Vector3(0, 0, cos(atime/2)),amp)
	set_rot("r_leg", atime, Vector3(0, sin(-atime)/2, 0),amp*2)
	set_rot("r_calf", atime, Vector3(0, (sin(atime+PI/2)*2)-PI/8, 0),amp)
	set_rot("l_leg", atime, Vector3(0, sin(-atime+PI)/2-PI/8, 0),amp*2)
	set_rot("l_calf", atime, Vector3(0, sin(atime-PI/2), 0),amp)
	if abs(sin(atime)) < .2 && (is_on_floor() || is_on_wall()):
		var particle = feet[ticktock].get_node("step") as GPUParticles3D
		bounce_vel += target_velocity * 10.0
		var loud = stone+hash+mush+splash
		$stonestep.volume_linear = (pow(amp,2.0)*stone/loud)*.2
		$hashstep.volume_linear = (pow(amp,2.0)*hash/loud)*.2
		$mushstep.volume_linear = (pow(amp,2.0)*mush/loud)*.2
		$splashstep.volume_linear = (pow(amp,2.0)*splash/loud)*.2
		$stonestep.play()
		$hashstep.play()
		$mushstep.play()
		$splashstep.play()
		particle.emit_particle(Transform3D.IDENTITY, Vector3.ZERO, Color.WEB_GRAY, Color.WEB_GRAY, 0)
		ticktock = 0 if ticktock == 1 else 1
	if destroyanim < .1 && l_punch < .1 :
		set_rot("l_arm", atime, Vector3(-amp/5, 0, -sin(atime)-PI/8),amp)
		set_rot("l_forearm", atime, Vector3(0,-sin(atime+PI)-PI/2,0),amp)
	if click == 0 :
		set_rot("r_arm", atime, Vector3(amp/5, 0, sin(atime+PI)+PI/8),amp)
		set_rot("r_forearm", atime, Vector3(0, -sin(atime)-PI/2,0),amp)
	pass
	
func dodge_anim(animspeed: float, delta : float, amp : float, time_started : float) -> void :
	cur_anim = "d"
	var atime = (time-time_started) * animspeed
	if !is_on_wall_only() :
		set_rot("chest", atime, e_lookrot(Vector3.UP, bounce_vel, Vector3(atime,0,0)), amp)
	set_rot("neck", atime, Vector3(0,sin(.5)/4,0), amp)
	set_rot("mouthpiece", atime, Vector3(0, 0, cos(.5)),amp)
	set_rot("l_leg", atime, Vector3(0, sin(.5)/2, 0),amp)
	set_rot("l_calf", atime, Vector3(0, sin(.5)+.5, 0),amp)
	set_rot("r_leg", atime, Vector3(0, sin(.5)/2, 0),amp)
	set_rot("r_calf", atime, Vector3(0, sin(.5)+.5, 0),amp)
	pass


func climb_anim(animspeed: float, delta : float, amp : float) -> void :
	cur_anim = "clb"
	var atime = climb_time
	climb_time += animspeed * delta/6.0
	if animspeed == 0 : 
		climb_time = PI
	var jump_crouch = 2.0 if Input.is_action_pressed("jump") else 1.0
	if !is_on_wall_only() :
		set_rot("chest",atime, Vector3(PI/8*amp * jump_crouch,PI/2,-PI/2), 1.0)
	set_rot("hips", atime, Vector3(0,0,sin_curve(-(atime), climb_curve)/2), amp)
	set_rot("neck", atime, Vector3(sin_curve(atime + PI, climb_curve)/4,0,0), amp)
	set_rot("head", atime, Vector3(-sin_curve(atime + PI, climb_curve)/4,-PI/5,0), amp)
	set_rot("mouthpiece", atime, Vector3(0, 0, cos(atime/2)),amp)
	
	var lrot1 = Vector3(PI/3 + sin_curve(atime, climb_curve)/2,0,0) if animspeed > 0 else -Vector3(PI/3 + sin_curve(atime, climb_curve)/2,0,0)
	var lrot2 = Vector3(-PI/3 + sin_curve(atime + PI/2, climb_curve)/2,0,0) if animspeed > 0 else -Vector3(-PI/3 +sin_curve(atime + PI/2, climb_curve)/2,0,0)
	
	set_rot("r_leg", atime, -lrot2,amp)
	set_rot("r_calf", atime, -lrot1,amp)
	set_rot("l_leg", atime, lrot2,amp)
	set_rot("l_calf", atime, lrot1,amp)
	if abs(sin(atime/2)) < .2 && (is_on_floor() || is_on_wall()):
		var particle = feet[ticktock].get_node("step") as GPUParticles3D
		bounce_vel += target_velocity * 20.0
		var loud = stone+hash+mush+splash
		$stonestep.volume_linear = (pow(amp,2.0)*stone/loud)*.2
		$hashstep.volume_linear = (pow(amp,2.0)*hash/loud)*.2
		$mushstep.volume_linear = (pow(amp,2.0)*mush/loud)*.2
		$splashstep.volume_linear = (pow(amp,2.0)*splash/loud)*.2
		$stonestep.play()
		$hashstep.play()
		$mushstep.play()
		$splashstep.play()
		particle.emit_particle(Transform3D.IDENTITY, Vector3.ZERO, Color.WEB_GRAY, Color.WEB_GRAY, 0)
		ticktock = 0 if ticktock == 1 else 1
		
	var arot1 = Vector3(PI/2 - PI/5 + sin_curve(atime, climb_curve),0,0) if animspeed > 0 else -Vector3(PI/2 - PI/5 + sin_curve(atime, climb_curve),0,0)
	var arot2 = Vector3(sin_curve(atime + PI/2, climb_curve),0,0) if animspeed > 0 else -Vector3(PI/2- PI/5 + sin_curve(atime + PI/2, climb_curve),0,0)
	if destroyanim < .1 :
		set_rot("l_arm", atime, -arot1,amp)
		set_rot("l_forearm", atime, -arot2,amp)
	if click == 0 :
		set_rot("r_arm", atime, arot1,amp)
		set_rot("r_forearm", atime, arot2,amp)
	pass
	
func jump_anim (animspeed: float, delta : float, time_started : float) -> void :
	cur_anim = "j"
	var atime = (time + time_started)* animspeed
	if !is_on_floor() :
		if kid == 3 :
			return
		set_rot("neck", atime, Vector3(0,sin(atime/2 + PI),0))
		set_rot("mouthpiece", atime, Vector3(0, 0, cos(atime/2)))
		set_rot("l_leg", atime, Vector3(0, sin(atime), 0))
		set_rot("r_calf", atime, Vector3(0, sin(atime + PI/4), 0))
		set_rot("r_leg", atime, Vector3(0, sin(-atime+PI)/2, 0))
		set_rot("r_calf", atime, Vector3(0, sin(atime-PI/4)+.5, 0))
		set_rot("r_arm", atime, Vector3(0, sin(atime)*2+.5, 0))
		set_rot("l_arm", atime, Vector3(0, sin(atime+PI)*2+.5, 0))
	else :
		set_rot("hips", atime, Vector3(0, 0, 0))
		set_rot("l_leg", atime, Vector3(0, -PI/4, 0))
		set_rot("r_calf", atime, Vector3(0, PI/2, 0))
		set_rot("r_leg", atime, Vector3(0, -PI/4, 0))
		set_rot("r_calf", atime, Vector3(0, PI/2, 0))
		
	if click > 0 :
		set_rot("r_arm", atime, Vector3.ZERO)
		set_rot("r_forearm", atime, Vector3.ZERO)
	pass
	
func change_kid() -> void :
	cur_lightmap = 66
	var newkid = kid + 1
	for i in len(kami_names) :
		if kids.has(newkid) :
			kid = newkid
			break
		else :
			newkid = wrap(newkid + 1, -1, len(kami_names))
			
	dodge = .2
	bounce_vel += Vector3(target_velocity.x,0.0,target_velocity.z).normalized() * 80.0
	timestarted = time
	iframes = .3
	
func fly_anim(animspeed: float, delta : float, amp : float) -> void :
	cur_anim = "sda"
	var atime = time * animspeed/5.0
	var wingflap = sin(lerp_flap+PI/2)
	var wingflap3 = sin(lerp_flap+PI+PI/2)
	var wingflap1 = clamp((sin(lerp_flap-PI/4))*2,0.0, 25.0)
	var gordon = 0.0
	
	
	set_rot("hips", atime, Vector3(0,0,0), amp)
	set_rot("neck", atime, Vector3(0,0,0), amp)
	set_rot("head", atime, Vector3(0,0,0), amp)
	set_rot("r_leg", atime, Vector3(0, sin(-atime)/2, 0),2.0)
	set_rot("r_calf", atime, Vector3(0, (sin(atime+PI/2)*2)-PI/8, 0),2.0)
	set_rot("l_leg", atime, Vector3(0, sin(-atime+PI)/2-PI/8, 0),2.0)
	set_rot("l_calf", atime, Vector3(0, sin(atime-PI/2), 0),2.0)
	
	
	if !is_on_wall_only() :
		set_rot("chest", atime, Vector3(0,0,0))
	
	if fire_particles.visible == false  : 
		set_rot("l_arm", atime, Vector3(wingflap,0,0))
		set_rot("r_arm", atime, Vector3(wingflap3,0,0))
		set_rot("l_forearm", atime, Vector3(wingflap,0,0))
		set_rot("r_forearm", atime, Vector3(wingflap3,0,0))
		set_rot("l_palm", atime, -restrot["l_palm"] + Vector3(PI/2,0,0))
		set_rot("r_palm", atime, -restrot["r_palm"] +Vector3(-PI/2,0,0))
		g += (wingflap1*100.0)*delta if !is_on_floor() else jump;
		bounce_vel += -camera.basis.z*wingflap1
		gordon = wingflap
	else :
		set_rot("r_arm", atime, Vector3(-PI/3,0,-2 * PI))
		set_rot("l_arm", atime, Vector3(-PI/8,PI/5,PI))
		set_rot("l_forearm", atime, Vector3(0,0,0))
		set_rot("r_forearm", atime, Vector3(0,0,0))
	play_mod_sound($shoot, (gordon/30.0)+.2, 1.0, 1.0+(g/60.0), dubsin(g))
	
	
func fire_anim(animspeed: float, delta : float, amp : float, press : bool) -> void :
	cur_anim = "f"
	var atime = time * animspeed
	
	if $shoot.stream != kidsounds[kid] :
		$shoot.stream = kidsounds[kid]
	
	if kid == 0 :
		earth_bomb(atime*2.0, press)
		
		
	if kid == 2 :
		fire_rapid(atime)
	pass
	
func water_ripple(ctime : float, camp : float) ->void :
	cur_anim = "wr"
	var atime = dubsin(ctime)
	var amp = camp + (ripples_strength*3.0)
	play_mod_sound($shoot, 1.0, 2.0, atime+1.0, 1.0)
	set_rot("r_fing1.1", atime, Vector3(sin(atime),sin(atime)/2, sin(atime)/2))
	set_rot("r_fing2.1", atime, Vector3(-sin(atime), sin(atime),0))
	set_rot("r_fing3.1", atime, Vector3(-sin(atime)/2,-sin(atime)/2, -sin(atime)))
	set_rot("r_fing1.2", atime, Vector3(sin(atime),sin(atime)/2, sin(atime)/2))
	set_rot("r_fing2.2", atime, Vector3(-sin(atime), sin(atime),0))
	set_rot("r_fing3.2", atime, Vector3(-sin(atime)/2,-sin(atime)/2, -sin(atime)))
	bones["r_arm"].look_at(camera.global_position + (camera.basis.z * 100))
	bones["r_arm"].rotate(Vector3.UP, PI/1.5)
	set_rot("r_forearm", atime, Vector3(sin(atime+PI)/3, -PI/4  + (-sin(atime+PI)/3),PI/3))
	set_rot("r_palm", atime, Vector3(0,0,0))
	if !is_on_wall_only() :
		set_rot("chest", atime, Vector3(dubsin(atime)/4,0,0), amp)
	set_rot("hips", atime, Vector3(0,0,dubsin(-(atime + PI))/2), amp)
	set_rot("neck", atime, Vector3(0,dubsin(atime/2 + PI)/4,0), amp)
	set_rot("mouthpiece", atime, Vector3(0, 0, cos(atime/2)),amp)
	set_rot("l_leg", atime, Vector3(0, dubsin(-atime)/2, 0),amp)
	set_rot("l_calf", atime, Vector3(0, dubsin(atime+PI/2)+.5, 0),amp)
	set_rot("r_leg", atime, Vector3(0, dubsin(-atime+PI)/2, 0),amp)
	set_rot("r_calf", atime, Vector3(0, dubsin(atime-PI/2)+.5, 0),amp)
	atime = (time-timestarted) * 50.0;
	if !is_on_wall_only() :
		set_rot("chest", atime, Vector3(0,atime * 3.0,0), ripples_strength)
	if abs(dubsin(atime)) < .1 :
		var loud = stone+hash+mush+splash
		$splashstep.volume_linear = 1.0
		$splashstep.play()
	
	waterchant.emit_particle(Transform3D.IDENTITY, Vector3.ZERO, Color.ALICE_BLUE,  Color.ALICE_BLUE, 0);
	
func fire_rapid(atime : float) -> void :
	var iszoom = click1 > 0 
	bones["r_arm"].look_at(camera.global_position + (-(camera.basis.z * 100) if !iszoom else (camera.basis.z * 100)))
	bones["r_arm"].rotate(Vector3.UP, -PI/1.5 if !iszoom else PI/1.5)
	set_rot("r_forearm", atime, Vector3(sin(atime+PI)/3, -PI/4  + (-sin(atime+PI)/3),PI/3))
	set_rot("r_palm", atime, Vector3(0,0,0))
	
	if !iszoom :
		bounce_vel += -camera.basis.z * 5.0
	

	
	if sin(atime*(100.0 if not iszoom else 10.0)) < -0.5 :
		if canbomb :
			var proj := fire_homon.instantiate() as PhysicsBody
			get_tree().current_scene.add_child(proj)
			proj.name = "fireproj"
			proj.ignore = self
			proj.global_position = bones["r_forearm"].get_node("Cube_012").global_position + ((-(-camera.basis.z*3)  if !iszoom else (-camera.basis.z*3)))
			proj.apply_impulse(-camera.basis.z * (240.0 if iszoom else -20.0));
			proj.scale = Vector3.ONE if iszoom else Vector3.ONE*10.0
			canbomb = false
		earthbomb.emitting = true
		play_mod_sound($shoot, 1.0, 1.0, 2.0 if not iszoom else 1.0, .01, 0.0, 0.0)
	else : 
		canbomb = true
	earthbomb.global_position = bones["r_palm"].global_position;
	
func earth_bomb(time : float, press : bool) -> void : 
	cur_anim = "ad"
	if Input.is_action_just_pressed("fire1") :
		timestarted = time
	var atime = ((time - timestarted))
	bones["r_arm"].look_at(camera.global_position + (camera.basis.z * 100))
	bones["r_arm"].rotate(Vector3.UP, PI/1.5)
	set_rot("r_forearm", atime, Vector3(sin(atime+PI)/3, -PI/4  + (-sin(atime+PI)/3),PI/3))
	set_rot("r_palm", atime, Vector3(0,0,0))
	
	set_rot("r_fing1.1", atime, Vector3(sin(atime),sin(atime)/2, sin(atime)/2))
	set_rot("r_fing2.1", atime, Vector3(-sin(atime), sin(atime),0))
	set_rot("r_fing3.1", atime, Vector3(-sin(atime)/2,-sin(atime)/2, -sin(atime)))
	set_rot("r_fing1.2", atime, Vector3(sin(atime),sin(atime)/2, sin(atime)/2))
	set_rot("r_fing2.2", atime, Vector3(-sin(atime), sin(atime),0))
	set_rot("r_fing3.2", atime, Vector3(-sin(atime)/2,-sin(atime)/2, -sin(atime)))
	for i in len(allbombs) :
		if i >= len(allbombs) || allbombs[i] == null:
			allbombs.remove_at(i)
			continue
		if allbombs[i].timetoblow > allbombs[i].autoblow :
			allbombs[i].timetoblow = clamp(allbombs[i].timetoblow, allbombs[i].autoblow + .3,100.0)
	if fire_delay <= .1:
		var proj := bomb_earth.instantiate() as RigidBody3D
		get_tree().current_scene.add_child(proj)
		proj.boss = self
		proj.name = "bombproj"
		proj.global_position = bones["r_palm"].global_position + (-camera.basis.z*3)
		proj.apply_impulse(-camera.basis.z * 120 );
		canbomb = false
		proj.get_node("particulator").emitting = true;
		allbombs.push_front(proj)
		earthbomb.global_position = bones["r_palm"].global_position;
		earthbomb.emitting = true
		play_mod_sound($shoot, 1.0, 1.0, 1.0, .5, 0.0, 0.0)
		fire_delay = .3
	else :
		canbomb = true

	
func destroy_anim(animspeed: float, delta : float, time_started : float) -> void :
	cur_anim = "d"
	var atime = (time-time_started) * animspeed * 2.0
	bones["l_arm"].look_at(camera.global_position + (camera.basis.z * 100))
	bones["l_arm"].rotate(Vector3.FORWARD, -PI/1.5)
	set_rot("l_forearm", atime, Vector3(sin(atime+PI)/3, -PI/4  + (-sin(atime+PI)/3),PI/3))
	set_rot("l_palm", atime, Vector3(0,0,0))
	
	if destroyanim > 4.: 
		$explod.play()
		

	for i in len(allbombs) :
		if i >= len(allbombs) || allbombs[i] == null:
			allbombs.remove_at(i)
			continue
		allbombs[i].autoblow = 5.0 
		allbombs.remove_at(i)
	if destroyanim <.2 :
		allbombs.clear()
	
	set_rot("r_fing1.1", atime, Vector3(sin(atime),sin(atime)/2, sin(atime)/2))
	set_rot("r_fing2.1", atime, Vector3(-sin(atime), sin(atime),0))
	set_rot("r_fing3.1", atime, Vector3(-sin(atime)/2,-sin(atime)/2, -sin(atime)))
	set_rot("r_fing1.2", atime, Vector3(sin(atime),sin(atime)/2, sin(atime)/2))
	set_rot("r_fing2.2", atime, Vector3(-sin(atime), sin(atime),0))
	set_rot("r_fing3.2", atime, Vector3(-sin(atime)/2,-sin(atime)/2, -sin(atime)))
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	var move = Vector2((-1 if Input.is_action_pressed("left") else 0) + (1 if Input.is_action_pressed("right") else 0),
	(-1 if Input.is_action_pressed("back") else 0) + (1 if Input.is_action_pressed("forward") else 0))
	
	interact = Input.is_action_just_released("interact")
	
	set_scales()
	
	if kami_icon.texture != kami_icons[kid] :
		kami_icon.texture = kami_icons[kid]
	
	time += delta
	
	fire_delay = lerp(fire_delay, 0.0, delta * 3.0)
	
	wind = wind + delta if click > .1 else lerp(wind, 0.0, delta * wind * 3.0)
	
	a_time = a_time + delta if !is_on_floor() && !is_on_wall() else 0.0
	g_time = g_time + delta if is_on_floor() || is_on_wall() else  0.0
	
	if g_time <= .01 && g_time > 0 && is_on_wall() :
		bounce_vel = Vector3.ZERO
		target_velocity = Vector3.ZERO
	
	if kid == 3 && flap > .1 :
		fly_anim(3.0, delta, 15.0)
		
	moise_left.scale = Vector2.ONE * (.9 if Input.is_action_pressed("fire") else 1.0)
	moise_right.scale = Vector2.ONE * (.9 if Input.is_action_pressed("fire1") else 1.0)
	moise_body.scale = Vector2.ONE * (.9 if Input.is_action_pressed("fire") && Input.is_action_pressed("fire1") else 1.0)
	
	if kid == 2 && status_effects.has("fire") && status_effects["fire"] > 0 :
		status_effects["fire"] = 0;
		fire_particles.visible = false
	
	var t_vel = (-move.y * camera.basis.z) + (move.x * camera.basis.x)
	target_velocity = lerp(target_velocity, t_vel, delta * 2.0 )
	
	var look = Vector2(Input.get_joy_axis(0, JOY_AXIS_RIGHT_X), Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y))/10.0
	
	var mouse_delta = ((Input.get_last_mouse_screen_velocity()/1000) + (look if look.length() > .1 else Vector2.ZERO))*delta
	
	var cx = sin(rot)
	var cy = cos(rot)
	rot += mouse_delta.x*sensitivity
	
	dd_time = lerp(dd_time, 10.0, delta * 3.0) if health <= 0 else 0.0
	d_time = lerp(d_time, 0.0, delta * 10.0)
	
	if dd_time >= 9.9 :
		respawn_anim()
	
	var cx2 = sin(rot2)
	var cy2 = cos(rot2)
	rot2 = clamp(rot2 + mouse_delta.y*sensitivity, -PI/2 + .1,PI/2 - .1)
	
	render_healthbar(delta)
	
	click = 1 if Input.is_action_pressed("fire")  && destroyanim <= .1 else 0
	click1 = 1 if Input.is_action_pressed("fire1") && destroyanim <= .1 else 0
	
	if Input.get_action_strength("lefthook") : 
		l_punch = 1.0
	
	l_punch = lerp(l_punch, 0.0, delta * 5.0)
	if l_punch > 0.1 : 
		left_punch()
		
	if Input.get_action_strength("righthook") : 
		r_punch = 1.0
	
	r_punch = lerp(r_punch, 0.0, delta * 5.0)
	if r_punch > 0.1 : 
		right_punch()
	
	destroyanim = lerp(destroyanim, 0.0, delta * 3.0)
	
	if Input.is_action_pressed("fire") && destroyanim < 2.5 && destroyanim > .7 :
		destroyanim = .7
		
	for i in len(allbombs) :
		if i >= len(allbombs) || allbombs[i] == null :
			allbombs.remove_at(i)
			break
	
	if click1 > 0 && kid == 0 :
		destroyanim = 1.0
		timestarted = time
		
	var iszoom = click1 > 0 && kid ==2
	
	camera.fov = lerp(camera.fov, 100.0 if !iszoom else 120.0, delta * 2.0)
	
	if Input.is_action_just_pressed("shift") && dodge <= .1:
		change_kid()
		
	dodge = lerp(dodge, 0.0, delta*3.0)
		
	if dodge > .1 :
		dodge_anim(1.0, delta, bounce_vel.length()/10.0, timestarted);
		
	ripples_strength = lerp(ripples_strength, 0.0, delta * 7.0)
	
	if Input.is_action_just_pressed("fire") && ripples_strength < .1:
		ripplevec = Vector3(1.0,0.0,1.0)
		ripples_strength = 2.0 * PI
		timestarted = time
		
	if Input.is_action_just_pressed("fire1") && ripples_strength < .1 :
		ripplevec = Vector3(-1.0,0.0,1.0)
		ripples_strength = 2.0 * PI
		timestarted = time
		
	if Input.is_action_pressed("fire") &&  Input.is_action_pressed("fire1"):
		ripplevec = Vector3(0.0,2.0 * Vector3.UP.dot(-camera.basis.z),1.0)
		
	if ripples_strength > .1 && kid == 1 :
		water_ripple(time, ripples_strength)
		bounce_vel += Vector3((sin(ripples_strength)+1.0)*ripplevec.x, 0.0, (cos(ripples_strength)+1.0)*ripplevec.z).rotated(Vector3.UP, camera.rotation.y) * -5.0
		g += (sin(ripples_strength)+1.0)*ripplevec.y * 2.0
		iframes = .8
		
	if !is_on_floor() && kid == 3 && click1 > .1:
		ripples_strength = 10.0
		wind_strength += 25.0 * delta
		g = lerp(g, -200.0, delta * 3.0)
		bounce_vel += -camera.basis.z*delta*500.0
		
	if destroyanim > .1 : 
		destroy_anim(-1.0, delta, timestarted)
		
	var cam_horizontal = ((Vector3.RIGHT*cx) + (Vector3.FORWARD*cy))
	var cam_vertical = (Vector3.UP*cx2) + (cam_horizontal * (cy2-1.0))
	var calcdir = (cam_vertical + cam_horizontal)*camdist
	
	var scroll = (1 if Input.is_action_just_released("scrollup") else 0) + (-1 if  Input.is_action_just_released("scrolldown") else 0)
	camdist = clamp(camdist+ scroll, .1, 20)

	wind_strength = lerp(wind_strength, 0.0, delta * 10.0) if is_on_floor() else wind_strength
	

	var camdir = (cam_horizontal+cam_vertical)*camdist

	
	if kid >= len(kami_names) :
		kid = 0
	if kid < 0 :
		kid = len(kami_names) -1
	
	if kami_names[kid] != cur_armor :
		load_bones()
		
		
	
	var climbing = (camera.basis.z.normalized()).dot(wallvec.normalized()) > climb_threshold
	
	var lowest_foot = feet[0].global_position.y if feet[0].global_position.y < feet[1].global_position.y else feet[1].global_position.y
	
	bones["chest"].position.y = hip_pos.y+(lowest_foot-bones["chest"].global_position.y+(3.5))/2.0
	bones["chest"].position.x = hip_pos.x + ((wallvec.x) if is_on_wall_only() else 0.0)
	bones["chest"].position.z = hip_pos.z+ ((wallvec.z) if is_on_wall_only() else 0.0)
	
	camera.global_position = global_position + camdir if global_position.y > -500 || isgrounded || ogfall <= 0 else last_pos;
	last_pos = camera.global_position if global_position.y > -500 else last_pos + last_pos/100.0;
	var rev = 1.0 if move.y > 0 else -1.0;
	desired_rot = Vector3(0, camera.rotation.y+PI/2,  0)
	
	if kid == 3 && Input.is_action_just_pressed("fire") :
		flap = 2 * PI;
		g += 1.0
		
	flap = lerp(flap, 0.0, delta * 4.0)
	lerp_flap = lerp(lerp_flap, flap, delta * 4.0)
	
	var anim_proceed = !(!is_on_floor() && flap >.1) && dodge <= .1 && !(is_on_wall_only() && climbing)
	if a_time <= .1 :
		if target_velocity.length() > .1 || (click > 0 && abs(mouse_delta.x) > 0):
			
			if anim_proceed :
				walk_anim(rev * (12.0) , delta*3.0, target_velocity.length() * rev)
		else : 
			if anim_proceed:
				idle_anim(2.0, delta)
	else :
		jump_anim(4.0, delta, timestarted)

	
	if click == 1 :
		fire_anim(4.0, delta, target_velocity.length() * rev, Input.is_action_just_pressed("fire1"))
	else :
		earthbomb.emitting = false;
		
	if global_position.y < -500: 
		camera.global_rotation = lerp(camera.global_rotation, e_lookrot(Vector3.UP, -camera.global_position-Vector3(0,100,0)), delta*2.0)
		ogfall -= delta
		$CollisionShape3D.disabled = false
		if ogfall < fall_time/2 :
			process_fall() 
	else :
		camera.look_at_from_position(camera.global_position, global_position + perlin_shake(cam_shake, Vector3.ONE, 25.0 * cam_shake))
		ogfall = fall_time
	cam_shake = lerp(cam_shake, 0.0, delta*2.0)
	
	isgrounded = is_on_floor()
	var g2 = g
	g = (jump if Input.is_action_just_pressed("jump") else 0.0) if isgrounded && !(click && kid == 3) else lerp(g, -fall, delta if !is_on_wall() else 0.0)
	
	if Input.is_action_just_pressed("jump") :
		timestarted = time
		
	global_chest_rot = bones["chest"].global_rotation if !is_on_wall_only() else global_chest_rot
	bones["chest"].global_rotation = global_chest_rot if is_on_wall_only() else bones["chest"].global_rotation
	timestarted = time if Input.is_action_just_released("jump") else timestarted
	
	get_node(kami_names[kid]).rotation = lerp(get_node(kami_names[kid]).rotation, desired_rot, delta * 5) if camdist != .1 else desired_rot
	bounce_vel = lerp(bounce_vel, Vector3.ZERO, delta * 4.0)
	velocity = (Vector3(target_velocity.x*speed, g * (1.0 if not is_on_wall() else .2), target_velocity.z*speed*tmp_speed) if dodge <=.1 else Vector3.ZERO) + bounce_vel
	isgrounded = false	
	
	treeclimbing.global_rotation.y = e_lookrot(Vector3.UP, -wallvec, Vector3(0,PI/2,0)).y;
	monkeybars.global_rotation.y = e_lookrot(Vector3.UP, -wallvec, Vector3(0,PI/2,0)).y;
	
	wall_jump = is_on_wall_only() &&  Input.is_action_just_released("jump") 
	for i in get_slide_collision_count():
		if i > (get_slide_collision_count()-1) :
			break
		
		on_collision_enter = !is_colliding

			
		if ripples_strength > 0.1 && kid == 3  && destroyanim < .1:
			var proj := the_winds_beak.instantiate() as BombExplosion
			get_tree().current_scene.add_child(proj)
			proj.boss = self
			proj.force = 120.0
			proj.damage = 35.0 + 2.0*wind_strength
			proj.shapecast.enabled = false
			proj.shapecast.scale = Vector3.ONE * 1.5 *wind_strength
			proj.shapecast.enabled = true
			proj.timetoblow = proj.autoblow
			proj.global_position = global_position + Vector3.DOWN *1.0
			destroyanim = 1.0
			proj.get_node("particulator").emitting = false
			var part = proj.get_node("particulator2") as GPUParticles3D
			part.amount = int(10.0*wind_strength)
			part.emitting = true
			ripples_strength = 0.0;
			iframes = 1.0
		
		var collision = get_slide_collision(i)
		if collision.get_collider(i) is Squiggle && ripples_strength > .5 && click :
			var squig = collision.get_collider(i)
			squig.smanish(20.0,10.0, -camera.basis.z.normalized()/2.0 + Vector3.UP, collision.get_position(), .01)
			bounce_vel -= (bounce_vel + Vector3.UP*2.0) * 1.5
		
		var col = collision.get_collider()
		
		if col is PetsBody3D :
			stone = col.stone
			hash = col.hash
			mush = col.mush
			splash = col.splash
		
		
		if is_on_wall_only() : 
			wallvec = collision.get_normal().normalized()
			bounce_vel -= wallvec/2.0
			print(collision.get_normal())
			g = 0.0;
			var gtimeexcuse= clamp(g_time * 6.0,0,1.0)
			if !climbing :
				global_chest_rot = lerp(global_chest_rot, e_lookrot(Vector3.UP, wallvec, Vector3(0,PI,-PI if  wallvec.dot(camera.basis.x) < wall_threshold else 0)), delta * 5.0)
			else :
				climb_anim(rev * (12.0) if target_velocity.length() > .1 else 0.0 , delta*3.0, rev)
				target_velocity = (move.y * Vector3.UP) + (-move.x * bones["chest"].basis.x.normalized()/10)
				global_chest_rot = lerp(global_chest_rot, e_lookrot(Vector3.UP, wallvec, Vector3(-PI/2,PI,PI/2)), delta * 5.0)
				
				
		if wall_jump : 
			bounce_vel = ((global_position - collision.get_position(i)).normalized()*150.0)
			g = jump/1.2
			wall_jump = false
			
			
	is_colliding = is_on_floor()
	if health > 0 :
		move_and_slide()
			 
	pass
