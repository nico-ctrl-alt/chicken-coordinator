extends Node
class_name EcoSystem

@export var resources : Array[Source];
@export var squigs : Array[Squiggle];
@export var cam : Camera3D 
@export var cur_world : Marble
@export var song : AudioStreamPlayer3D
var camdir = Vector3.ZERO;
@onready var player = get_tree().root.get_node("kami")


func _smell_closest(s : Squiggle, range = 10.0, sources = []) -> Source :
	sources = sources if sources != [] else resources
	var close = null
	var dist = range
	for i in sources : 
		if i.global_position.distance_to(s.global_position) < dist :
			close = i
			dist = i.global_position.distance_to(s.global_position)
	return close
	
func _smell_closest_in_cast(s : Squiggle, cast : ShapeCast3D, range = 10.0, prev_col = null) -> Squiggle :
	var close = prev_col
	var dist = range
	cast.force_shapecast_update()
	for i in cast.get_collision_count() :
		var col = cast.get_collider(i)
		
		if col as StaticBody3D :
			cast.add_exception(col)
		
		if !(col as Squiggle) :
			continue
		
		var tmpdist = col.global_position.distance_to(s.global_position)
		
		if tmpdist < dist && col != s :
			close = col
			dist = tmpdist
	print(str(close) + " is closest!" + ", count: " + str(cast.get_collision_count()))
	return close
	
func _smell_closest_squiggle(s : Squiggle, range = 10.0, sources = []) -> Squiggle :
	sources = sources if sources != [] else squigs
	var close = null
	var dist = range
	for i in sources : 
		if !i : 
			continue
		var tmpdist = i.global_position.distance_to(s.global_position)
		if tmpdist < dist && i != s :
			close = i
			dist = tmpdist
	return close
	
func _see_closest(s : Squiggle, fwd : Vector3, range = 10.0, vis_range = 0) -> Source :
	var close = null
	var dist = range
	for i in resources : 
		if i.global_position.distance_to(s.global_position) < dist && fwd.dot(s.global_position-i.global_position) > vis_range:
			close = i
			dist = i.global_position.distance_to(s.global_position)
	return close
	
	
func _hear_closest(s : Squiggle, range = 10.0) -> Source :
	var close = null
	var dist = range
	for i in resources : 
		if i.global_position.distance_to(s.global_position) < dist :
			close = i
			dist = i.global_position.distance_to(s.global_position)
	return close
	
func _process(delta: float) -> void:
	camdir = -cam.basis.z
