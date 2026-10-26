class_name Quest
extends Node3D


@export var sacrifices : Array[Squiggle]
@export var offerings : Array[Source]
@export var find_me : Array[Node3D]
@export var return_me : Array[Node3D]
@export var goal : Node3D
@export var survive_me : SupaFighta
@export var goal_count = 1000
@export var deleteme : Array[Node3D]
@export var animation : Array[Anim]
@export var rewards : Array[PackedScene]
@export var active = false

func _process(delta: float) -> void:
	if !active : 
		return
	
	for i in len(sacrifices) :
		if i > (len(sacrifices)-1) :
			break
		if !sacrifices[i] or sacrifices[i].health <= 0 :
			goal_count -= 1
			sacrifices.remove_at(i)
			
	if len(sacrifices) <= 0 || goal_count <= 0 :
		end_quest()

func end_quest() -> void :
	
	for i in deleteme :
		if i :
			i.queue_free()
			continue
	for i in animation :
		i.autoplay = true
	for i in rewards :
		var s = i.instantiate()
		get_tree().current_scene.add_child(s)
	queue_free()
