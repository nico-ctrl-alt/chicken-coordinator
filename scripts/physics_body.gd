class_name PhysicsBody

extends RigidBody3D

@export var ang_vel : Vector3
@export var remove_parent = true
@export var gravity = -8.0
@export var damping = 1.0
@export var root : Node3D
@export var isgrounded = false
@export var active = true
@export var cull_t = 2.0
@export var fire = false
@export var damage = 1.0
@onready var fire_particles = $fire_particles
var time = 0.0
var ignore = null

var resistance = Vector3.ZERO;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	cull_t = lerp(cull_t, 0.0, delta)
	
	time += delta
	
	if fire && !fire_particles.visible :
		fire_particles.visible = true
	if cull_t < .1 :
		root.scale = lerp(root.scale, Vector3.ZERO, ((sin(time)*delta)+.01)*2)
		if root.scale.length() < .1 :
			root.queue_free()
			queue_free();
			
	for i in get_colliding_bodies() :
		if i is Squiggle && i != ignore : 
			if fire == true :
				i.status_effects["fire"] = 25.0 * mass
			i.smanish((linear_velocity.length()/50.0 + (angular_velocity.length()*i.global_position.distance_to(global_position))/50.0) + damage, linear_velocity.length()/100.0 + (angular_velocity.length()*i.global_position.distance_to(global_position)*mass)/100.0, (i.global_position-global_position).normalized(), global_position, .2);
	
	if active && root :
		var glob = root.global_position
		if remove_parent :
			get_tree().current_scene.add_child(root)
		root.global_position = glob
		
	pass
