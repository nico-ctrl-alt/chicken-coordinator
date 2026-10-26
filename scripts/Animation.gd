class_name Anim
extends Node3D

@export var trans : Node3D
@export var skele : Skeleton3D
@export var find_trans = ""
@export var perlin_shake_cam = false;
@export var perlin_shake = false;
@export var bone_id = 0 
@export var sin = Vector3(0,0,0)
@export var wavespeed = 1.0
@export var track : Node3D
@export var track_me  = false
@export var track_offset : Vector3
@export var track_up = Vector3(0,1,0)
@export var lerp_to : Vector3
@export var lerp_to_pos : Vector3
@export var lerp_cam_env : Camera3D
@export var sky_color : Color
@export var stariness : float
@export var fog_Density : float
@export var lerpme = false
@export var waveme = false
@export var lerpmepos = false
@export var lerpmecam = false
@export var duration = 1.0
@export var speed = 1.0
@export var autoplay = true
@export var spawnme : Array[PackedScene]
@export var deleteme : Array[Node3D]
@export var look_at_object = false
@export var object_of_interest : Node3D
@export var dot_threshold = 0.0
@export var change_beat = false
@export var beat_params = Vector3(16, 4, 1)
var object_looked_at
var iscompleted = false
@onready var track_off = track_offset
var ogpos
var ogrot
var ogduration
var music :  AudioStreamPlayer3D
var stream : AudioStreamMP3

func _ready() -> void:
	if change_beat :
		music = get_tree().current_scene.get_node("music") as AudioStreamPlayer3D
		stream = music.stream
	
	if find_trans != "" :
		trans = get_tree().current_scene.get_node(find_trans)
		
	if !lerp_cam_env :
		lerp_cam_env = get_tree().current_scene.get_node("kami/Camera3D")

	if trans :
		ogpos = trans.global_position
		ogrot = trans.global_rotation
	ogduration = duration
	
func _smooth_env() -> void : 
	var env = get_world_3d().environment
	var get_color = env.sky.sky_material.get("shader_parameter/color")
	var star = env.sky.sky_material.get("shader_parameter/starness")
	env.sky.sky_material.set("shader_parameter/color", lerp(get_color, sky_color, 1.0-duration))
	env.fog_density = lerp(env.fog_density, fog_Density, 1.0-duration)
	env.sky.sky_material.set("shader_parameter/starness", lerp(star, stariness, 1.0-duration))

func _smooth_pos() -> void :
	trans.global_position = lerp(ogpos, lerp_to_pos, 1.0-duration)

func _smooth() -> void :
	trans.rotation = lerp(ogrot, lerp_to, 1.0-duration)
	
func _wave() -> void :
	trans.rotation = (trans.rotation+sin)*sin(duration * wavespeed)
	
func _track_to() -> void :
	if lerpme :
		track_off = lerp(track_off, lerp_to, 1.0-duration)
	trans.rotation = e_lookrot(track_up, (track.global_position-trans.global_position).normalized(), track_off)

func _copy_bone() -> void :
	var bone = trans.transform
	skele.set_bone_global_pose(bone_id, bone)
	
func e_lookrot(up : Vector3, dir : Vector3, offset = Vector3.ZERO) -> Vector3 :
	return Transform3D.IDENTITY.looking_at(dir, up).basis.get_euler() + offset 
	
func _animate(delta : float) -> void :
	duration = clamp(duration-delta * speed/100.0,0,100)
	
	if lerpmecam :
		_smooth_env()
		
	
		
	
	if trans : 
		if lerpmepos :
			_smooth_pos()
		if waveme :
			_wave()
		if lerpme :
			_smooth()
		if track :
			_track_to()
	if skele : 
		_copy_bone()

func _spawn_items() -> void :
	for i in len(spawnme) :
		var s = spawnme[i].instantiate()
		get_tree().current_scene.add_child(s)
		spawnme.remove_at(i)
		break
		
func _perlin_shake() -> void:
	if trans as Kami && perlin_shake_cam :
		trans.cam_shake = duration/ogduration

func _delete_items() -> void :
	for i in deleteme :
		if i :
			i.queue_free()
			if i == trans :
				queue_free()
			break

func _process(delta: float) -> void:
	
	if autoplay && look_at_object && lerp_cam_env && object_of_interest && -lerp_cam_env.basis.z.dot((object_of_interest.global_position - lerp_cam_env.global_position).normalized()) > dot_threshold:
		object_looked_at = true
		print("me looked at!")
	
	if (autoplay && !look_at_object) || (autoplay && look_at_object && object_looked_at):
		_animate(delta)
		
	if change_beat && autoplay && stream.loop_offset != beat_params.z :
		stream.beat_count =beat_params.x
		stream.loop_offset = beat_params.z
		change_beat = false
		
	if duration <= 0.0 :
		_spawn_items()
		_delete_items()
		

	
	
