extends Node3D
class_name Source

@export var energy = 0;
@export var nuts = 0;
@export var compost = 0;
@export var meat = 0;
@export var tech = 0; 
@export var salad = 0;
@export var temperature = 0;
@onready var ecosys = get_tree().root.get_node("EcoSystem") 
@onready var player = ecosys.player

func _process(delta : float) -> void :
	if player.global_position.distance_to(global_position) < 5 :
		print("sin")
		
