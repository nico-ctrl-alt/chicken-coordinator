extends Squiggle

@onready var player = get_tree().current_scene.get_node("kami")
@export var speed = 5.0
@export var offset = Vector3.ZERO
@export var beat_params = Vector3(16, 4.0, 64.9)
@export var change_beat = false
@onready var wave_fighter : SupaFighta = $wave_fighter
var spines = []
var priorities = [66]
var cur_priority = 66
var danger = Vector3.ZERO
@onready var music = get_tree().current_scene.get_node("music")
var stream : AudioStreamMP3


func _ready() -> void: 
	stream = music.stream
	squig_ready()
	wave_fighter.spawn_point = self as Node3D
	bones = {
	"root" : get_node("Cube_006"),
	"head" : get_node("Cube_006/Cube"),
	"r_eye" : get_node("Cube_006/Cube/Cube_001"),
	"l_eye" : get_node("Cube_006/Cube/Cube_017"),
	"spine_1" : get_node("Cube_006/Cube_007"),
	"spine_2" : get_node("Cube_006/Cube_007/Cube_008"),
	"spine_3" : get_node("Cube_006/Cube_007/Cube_008/Cube_009"),
	"spine_4" : get_node("Cube_006/Cube_007/Cube_008/Cube_009/Cube_010"),
	"spine_5" : get_node("Cube_006/Cube_007/Cube_008/Cube_009/Cube_010/Cube_011"),
	"r_shoulder" : get_node("Cube_006/Cube_025"),
	"r_arm" : get_node("Cube_006/Cube_025/Cube_021"),
	"r_forearm" : get_node("Cube_006/Cube_025/Cube_021/Cube_022"),
	"r_sword" : get_node("Cube_006/Cube_025/Cube_021/Cube_022/Cube_024"),
	"l_shoulder" : get_node("Cube_006/Cube_016"),
	"l_arm" : get_node("Cube_006/Cube_016/Cube_012"),
	"l_forearm" : get_node("Cube_006/Cube_016/Cube_012/Cube_013"),
	"l_sword" : get_node("Cube_006/Cube_016/Cube_012/Cube_013/Cube_015")
	}
	set_bones()
	spines = [bones["spine_1"], bones["spine_2"], bones["spine_3"], bones["spine_4"], bones["spine_5"]]
	pass
	
func praise_be(delta : float, animspeed : float) ->void:
	if global_position.distance_to(player.global_position) > 100 :
		priorities.push_front(1)
	var atime = time * animspeed
	set_rot("root", atime, Vector3.ZERO)
	set_rot("head", atime, Vector3.ZERO)
	set_rot("l_shoulder", time, Vector3(-PI/2 + sin(atime)/3.0,-PI, 0.0))
	set_rot("r_shoulder", time, -Vector3(-PI/2 + sin(atime)/3.0,-PI, 0.0))
	if time-timestarted > 5.0  :
		priorities.pop_front()
	pass
	
func divination(delta : float, animspeed : float) -> void:
	var atime = time * animspeed
	set_rot("root", atime, Vector3.ZERO)
	set_rot("head", atime, Vector3.ZERO)
	set_rot("l_shoulder", atime, Vector3(-PI/3, 0.0,0.0))
	set_rot("l_arm", atime, Vector3(PI/3, 0.0,0.0))
	set_rot("r_shoulder", atime, -Vector3(-PI/3, 0.0,0.0))
	set_rot("r_arm", atime, -Vector3(PI/3, 0.0,0.0))
	if time-timestarted < 1.0 :
		for i in wave_fighter.enemiesleft :
			if !i :
				continue
			i.global_position = lerp(i.global_position,  global_position + global_position.direction_to(player.global_position) * 10.0, delta * 10.0)
	else :
		for i in wave_fighter.enemiesleft :
			if !i :
				continue
			i.g = 0.0
			i.bounce_vel = global_position.direction_to(player.global_position).normalized() * 100.0 
		priorities.pop_front()
	
func phase_to(delta : float, animspeed: float) -> void:
	var atime = time * animspeed
	set_rot("root", atime, Vector3.UP * atime)
	set_rot("head", atime, -Vector3.FORWARD * time)
	set_rot("l_shoulder", time, Vector3(0,0, 0.0))
	set_rot("r_shoulder", time, -Vector3(0,0, 0.0))
	if time-timestarted > 1.0 :
		priorities.pop_front()
	
func sword_spin(delta : float, animspeed: float) -> void:
	var atime = time * animspeed
	set_rot("root", atime, Vector3.UP * atime)
	set_rot("head", atime, Vector3.ZERO)
	set_rot("l_shoulder", time, Vector3(-PI/2,-PI, 0.0))
	set_rot("r_shoulder", time, -Vector3(-PI/2,-PI, 0.0))
	for i in get_slide_collision_count() :
		var s = get_slide_collision(i).get_collider() as Squiggle
		if s :
			s.smanish(25.0, 10.0, Vector3.UP, global_position, 1.0)
	if d_time > .1 || time-timestarted > 1.0 :
		priorities.pop_front()
func _process(delta: float) -> void:
	
	if !isactive :
		return
	
	if change_beat && health < healthbar.max_value/2 && stream.loop_offset != beat_params.z :
		stream.beat_count =beat_params.x
		stream.loop_offset = beat_params.z
		change_beat = false
	
	if len(priorities) == 0 :
		priorities.push_front(66)
		
	if priorities[0] == 66 && len(priorities) > 1 :
		priorities.pop_front()
	
	time += delta
	
	var dir = dir_towards(player)
	var raycast := where_to_target(player)
	
	if cur_priority == 0 :
		praise_be(delta, 5.0)
	if wave_fighter :
		wave_fighter.isplaying = cur_priority == 0
	
	if cur_priority == 66 :
		praise_be(delta, 1.0)
	
	render_healthbar(delta)
	var diceroll = 3 if randi_range(0,10) > 5 else 1
	if raycast.has("collider") && raycast["collider"] == player && dir.dot(basis.z) > 0 && !priorities.has(diceroll) :
		priorities.push_back(diceroll)
	
	if len(wave_fighter.enemiesleft) == 0 && !priorities.has(0) :
		priorities.push_back(0)
	
	if len(priorities) != 0 && cur_priority != priorities[0] :
		cur_priority = priorities[0]
		timestarted = time
		wave_fighter._friend_all()
	
	for i in spines :
		i.basis.y = lerp(i.basis.y, Vector3.UP - velocity.normalized()/10.0, delta)
		i.basis = i.basis.orthonormalized()
	
	velocity = Vector3((dir.x * sin(time * 2.0)),g, (dir.z * cos(time * 2.0))) * speed * delta
	
	g = dir.y if not is_on_floor() else g+delta
	
	if player.global_position.distance_to(global_position) > 100 && !priorities.has(diceroll):
		priorities.push_back(diceroll)
	
	if cur_priority == 1 :
		velocity = dir * speed * 1.5 * delta
		sword_spin(delta, 10.0)
	
	if cur_priority == 2 :
		velocity = danger * speed * 2.0 * delta
		phase_to(delta, 10.0)
		
	if cur_priority == 3 :
		divination(delta, 5.0)
	
	global_rotation.y = lerp(global_rotation.y, e_lookrot(Vector3.UP -velocity.normalized()/10.0, dir, Vector3(0,PI,0)).y, delta * 10.0)
	
	move_and_slide()
	var shape_results = shape_cast.get_collision_count()
	if cur_priority != 0 && !priorities.has(2) :
		for i in shape_results :
			if shape_cast.get_collider(i) as PhysicsBody :
				priorities.push_front(2)
				danger = -dir_towards(shape_cast.get_collider(i))
		
	pass
