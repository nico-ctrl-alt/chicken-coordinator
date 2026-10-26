extends Node3D
class_name Shell

@export var shell : MeshInstance3D
@export var shell_count = 100;
var shells =[]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	for i in shell_count :
		if len(shells) <= i :
			var james = shell.duplicate();
			james.set_instance_shader_parameter("shellid", i)
			get_parent().add_child(james)
			james.global_position = shell.global_position
			james.global_position.y+= .1 * i
			shells.append(james)
			print(james.get_instance_shader_parameter("shellid"))
			continue
	pass
