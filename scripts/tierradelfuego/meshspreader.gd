extends Node
class_name SpreadOnMesh


@export var mesh_To_Spread : MeshInstance3D
@export var squigs : Array[PackedScene]
@export var count = 10
@export var instance = false
@export var per_instance_count = 10
@export var min_dist = 100
@export var spreadonstart = true
@export var sacrament : Quest
@export var find : Quest
@onready var player = get_tree().current_scene.get_node("kami")
var points = []
var id = []
var instances = []

func _ready() -> void:
	await get_tree().create_timer(.2).timeout
	if spreadonstart :
		_spread()
	if instance :
		_init_instances()


func _spread() -> void:
	var verts = mesh_To_Spread.mesh.get_faces();
	for i in count : 
		var s = squigs[randi_range(0,len(squigs)-1)].instantiate()
		var pos = mesh_To_Spread.global_transform * verts[randi_range(0, len(verts)-1)]
		_place(s, pos)
		
func _init_instances() -> void:
	var verts = mesh_To_Spread.mesh.get_faces();
	
	for i in len(squigs) :
		var instance_array = []
		for j in per_instance_count :
			instance_array.push_front(squigs[i].instantiate())
		instances.push_front(instance_array)
	
	for i in count : 
		var s = randi_range(0,len(squigs)-1)
		id.push_front(s)
		var pos = mesh_To_Spread.global_transform * verts[randi_range(0, len(verts)-1)]
		points.push_front(pos)

func _place(s : Node3D, pos : Vector3) -> void:
	if s.global_position.distance_to(player.global_position) < min_dist :
		return
	get_tree().current_scene.add_child(s)

	s.global_position = pos + (Vector3.UP * 10.0)
	if s as Squiggle :
		s.spawnpoint = pos + (Vector3.UP * 10.0)
	if sacrament :
		sacrament.sacrifices.append(s)
		sacrament.deleteme.append(s)
		if len(sacrament.sacrifices) >= sacrament.goal_count :
			sacrament.active  = true
			
func _process(delta: float) -> void:
	if !instance :
		return
		
	for i in len(instances) :
		for j in len(instances[i]) :
			if !instances[i][j] || instances[i][j].health <= 0 :
				instances[i].remove_at(j)
				break
		
	for i in len(points) :
		if player.global_position.distance_to(points[i]) < min_dist :
			_place(instances[id[i]][randi_range(0,len(instances[id[i]]))-1], points[i])
			points.remove_at(i)
			break
		
