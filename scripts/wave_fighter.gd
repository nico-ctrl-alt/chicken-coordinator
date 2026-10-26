class_name SupaFighta

extends Node3D

@export var listofenemies : Array[PackedScene]
@export var waveCount = 100
@export var spawn_point : Node3D
@export var spawnme : Array[PackedScene]
@export var deleteme : Array[Node3D]
@export var isplaying = false

var boss : Squiggle
var enemiesleft : Array[Squiggle] = []
var waveNum = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _spawn_items() -> void :
	for i in len(spawnme) :
		var s = spawnme[i].instantiate()
		get_tree().current_scene.add_child(s)

func _delete_items() -> void :
	for i in deleteme :
		if i :
			i.queue_free()

func _friend_all() ->void :
	for i in len(enemiesleft) :
		if !enemiesleft[i] :
			continue
		var s = enemiesleft[i] as Squiggle
		if s :
			s.fwens.append_array(enemiesleft)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	for i in len(enemiesleft) :
		if !enemiesleft[i] || enemiesleft[i].health <= 0 :
			enemiesleft.remove_at(i)
			break
	
	if !isplaying :
		return
	
	if waveNum > waveCount-1 :
		_spawn_items()
		_delete_items()
		queue_free()
	
	
	if enemiesleft.size() == 0 :
		waveNum += 1
		for i in (waveNum +1) : 
			var enemy = listofenemies[randi_range(0, listofenemies.size()-1)].instantiate() as Squiggle
			enemiesleft.push_front(enemy)
			get_tree().current_scene.add_child(enemy)
			var radians = i*((2 * PI)/(waveNum+1));
			enemy.global_position = spawn_point.global_position + Vector3(sin(radians),0,cos(radians)) * 20.0
			enemy.spawnpoint = spawn_point.global_position
			enemy.boss = boss
			

	pass
