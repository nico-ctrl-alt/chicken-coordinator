class_name Marble
extends Node3D

@export var everything : Array[Node3D]
@export var meshes : Array[MeshInstance3D]
@export var origin_points : Array[Node3D]
@export var gi_stuff : Node3D
@export var sky_color : Color
@export var fog_density : float
@export var stariness : float
@export var skip_sky = false
@export var speed : float
@export var text := ""
@export var time = 0
@export var song : AudioStreamPlayer3D
@onready var world_env = get_tree().current_scene.get_node("WorldEnvironment") as WorldEnvironment
@onready var player = get_tree().current_scene.get_node("kami") as Kami
@onready var ecosys = get_tree().current_scene.get_node("EcoSystem") as EcoSystem
var materials : Array[Material]

func _ready() -> void:
	call_deferred("do_setup")

func change_GI(i : int) -> void :
	for m in len(meshes) :
		if !meshes[m] : 
			continue
		var b = meshes[m] as MeshInstance3D
		if meshes[m] is MeshInstance3D :
			for mm in b.get_surface_override_material_count() :
				if !materials.has(b.get_active_material(mm)) &&  b.get_active_material(mm).get("shader_parameter/y_GI"):
					print('something changed')
					var j = b.get_active_material(mm)
					j.set("shader_parameter/y_GI", player.GI_maps[i])
					j.set("shader_parameter/x_GI", null)
					j.set("shader_parameter/z_GI", null)
					j.set("shader_parameter/GI_size", player.change_size[i])
					j.set("shader_parameter/y_offset", player.GI_offset[i])
	print(player.change_size[i])
	print(player.change_size[i])

func do_setup() -> void:
	better_shit(time)
	

func better_shit(time : int) : 
	if ecosys.cur_world :
		ecosys.cur_world.end_of_the_world()
		
	player.camera.get_node("Text").text = text
	
	if time != 66 :
		player.global_position = origin_points[time].global_position
		
	if !skip_sky :
		world_env.environment.sky.sky_material.set("shader_parameter/color", sky_color)
		world_env.environment.sky.sky_material.set("shader_parameter/starness", stariness)
		world_env.environment.sky.sky_material.set("shader_parameter/speed", speed)
		world_env.environment.fog_density = fog_density/1000
	change_GI(0)
	ecosys.cur_world = self
	ecosys.song = song

func end_of_the_world() -> void :
	for i in everything :
		if i :
			i.queue_free()
	queue_free()
