extends CharacterBody3D


var isgrounded;
var target_velocity = Vector3.ZERO;
var g = 0.0;
var bounce_vel = Vector3.ZERO;
var speed = 5.0
var jumpforce = 5.0
@onready var camera = get_tree().current_scene.get_node("Camera3D")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	pass # Replace with function body.
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var move = Vector2((-1 if Input.is_action_pressed("left") else 0) + (1 if Input.is_action_pressed("right") else 0),
	(-1 if Input.is_action_pressed("back") else 0) + (1 if Input.is_action_pressed("forward") else 0))
	
	target_velocity = -Vector3(move.y, 0, move.x) * speed;
	
	g = (jumpforce if Input.is_action_pressed("jump") else 0) if isgrounded else lerp(g, -5.0, delta * 2.0)
	
	velocity = Vector3(target_velocity.x, g, target_velocity.z) + bounce_vel
	
	
	
	move_and_slide()
	isgrounded = false	
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		if collision.get_collider().name == "ground" :
			isgrounded = true
	pass
