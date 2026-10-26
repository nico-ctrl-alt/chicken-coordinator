extends OmniLight3D

@export var speed = 1.0
@export var xyz : Vector3
@export var noise : FastNoiseLite
var time = 0.0

func _process(delta: float) -> void:
	time +=delta * speed/100
	noise.offset = xyz * time
