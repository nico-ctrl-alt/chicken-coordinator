class_name BombExplosion

extends RigidBody3D

@export var boom = false;
@export var damage = 10.0;
@export var force = .5
@export var timetoblow = 4.0;
@export var destroy = true
@export var autoblow = .6
@export var boss : Squiggle
@export var radius = 3.0
@export var bossdir = Vector3(0.0,1.0,0.0)

var ogbomb
@onready var shape = get_node("CollisionShape3D") as CollisionShape3D
@onready var firstone = get_node("./particulator") as GPUParticles3D
@onready var secondone = get_node("./particulator2") as GPUParticles3D
@onready var shapecast := get_node("./ShapeCast3D") as ShapeCast3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ogbomb = timetoblow
	firstone.material_override = firstone.material_override.duplicate()
	pass # Replace with function body.
	
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if timetoblow < autoblow :
		boom = true
		
	timetoblow = lerp(timetoblow, -1.0, delta)
	
	if boom && timetoblow > 0.1 :
		var clor = firstone.material_override.get("shader_parameter/color")
		firstone.material_override.set("shader_parameter/color", lerp(clor, Vector4(1.0,1.0,1.0,1.0), delta * 10.0))
		shape.disabled = true
		sleeping = true
		var part = firstone.process_material
		$sound.play();
		part.set("shader_parameter/multiplyme", lerp(part.get("shader_parameter/multiplyme"), .2, delta * 30.0))
		part.set("shader_parameter/explodeme",lerp(part.get("shader_parameter/explodeme"), 100.0 if timetoblow > ogbomb/2 else 50.0, delta * 50.0))
		part.set("shader_parameter/diskify",lerp(part.get("shader_parameter/diskify"), 2. if timetoblow > ogbomb/2 else 0.0, delta * 1.0))
		part.set("shader_parameter/scale_max",lerp(part.get("shader_parameter/scale_max"), 2.0 if timetoblow > ogbomb/2 else 0.0, delta * 5))
		secondone.emitting = true
		firstone.amount_ratio = lerp(firstone.amount_ratio, 0.0, delta * 10000.)	
		firstone.scale = lerp(firstone.scale, Vector3(10.,10.,10.), delta * 4.0)
		freeze = true
		if shapecast.enabled :
			for j in shapecast.collision_result :
				var bb = j.collider as Squiggle
				if bb && !bb.get_collision_exceptions().has(self) && bb != boss:
					print(bb)
					var dir = (j.collider.global_position - global_position).normalized()
					bb.smanish(damage, force, dir, j.point, 0.0)
					bb.add_collision_exception_with(self)
				if bb == boss :
					bb.bounce_vel += (bossdir + global_position.direction_to(bb.global_position)) * force
					bb.g = 0.0;
		shapecast.scale = lerp(shapecast.scale, Vector3.ONE*radius*10.0, delta)
	
		
	
	if timetoblow <= -.9 && destroy:
		queue_free()
	
	pass
