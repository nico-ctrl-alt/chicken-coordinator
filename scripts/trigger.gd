extends Area3D
class_name Trigger


@export var targets : Array[Node3D]
@export var find_targets : Array[String]
@export var spawnme : Array[PackedScene]
@export var destroyme : Array[Node3D]
@export var playme : Array[Anim]
@export var startme : Array[Node3D]
@export var cam_shake = 0.0
@export var time_to_trigger = .1
@export var destroy_on_trigger = false
@export var stopsong = false
@export var track_being = false
@export var canonbeing : Squiggle
@onready var ecosys := get_tree().current_scene.get_node("EcoSystem")

func _ready() -> void:
	for i in find_targets :
		targets.append(get_tree().current_scene.get_node(i))

func _spawn_items() -> void :
	for i in len(spawnme) :
		var s = spawnme[i].instantiate()
		get_tree().current_scene.add_child(s)

func _delete_items() -> void :
	for i in destroyme :
		if i :
			i.queue_free()
			
func _start_events() -> void :
	if stopsong && ecosys.song :
		ecosys.song.stop()
	for i in len(startme) :
		if startme[i] as SupaFighta :
			startme[i].isplaying = true
		if startme[i] as AudioStreamPlayer3D :
			startme[i].play()
		if startme[i] as GPUParticles3D :
			startme[i].emitting = true
		if startme[i] as Squiggle :
			startme[i].isactive = true

func _play_anim() -> void :
	for i in playme :
		i.autoplay = true


func _process(delta: float) -> void:
	if !has_overlapping_bodies() && !track_being :
		return
	
	if time_to_trigger <= 0 || (track_being && !canonbeing) : 
		_spawn_items()
		_delete_items()
		_play_anim()
		_start_events()
		targets = []
		track_being = false
		time_to_trigger = 100.0

	
	for i in len(get_overlapping_bodies()) :
		var l = get_overlapping_bodies()[i]
		if targets.has(l) :
			time_to_trigger -= delta/2.0
		if l as Kami && time_to_trigger <= 0 : 
			l.cam_shake = cam_shake
		
		
