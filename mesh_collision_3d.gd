@tool class_name MeshCollision3D extends CollisionShape3D

enum _Shape_Type {TRIMESH, CONVEX, SIMPLIFIED_CONVEX, BOUNDING_BOX, CAPSULE, CYLINDER, SPHERE}
enum _Axis {LONGEST, X, Y, Z}
enum _Radius_Axis {SHORTER, LONGER}


@export var auto_sync: bool = true:
	set(value):
		auto_sync = value
		if auto_sync: update_collision()

@export var mesh: Mesh:
	set(value):
		mesh = value
		if mesh and not mesh.changed.is_connected(update_collision):
			mesh.changed.connect(update_collision)
		update_collision()

@export var type: _Shape_Type = _Shape_Type.TRIMESH:
	set(value):
		type = value
		update_collision()


@export_category("Parameters")
@export_custom(PROPERTY_HINT_NONE, "suffix:m") var margin: float = 0.0:
	set(value):
		margin = value
		update_collision()

@export var axis: _Axis = _Axis.LONGEST:
	set(value):
		axis = value
		update_collision()

@export var radius_axis: _Radius_Axis = _Radius_Axis.LONGER:
	set(value):
		radius_axis = value
		update_collision()


@export_category("Transform")
@export_custom(PROPERTY_HINT_NONE, "suffix:m") var position_offset: Vector3 = Vector3.ZERO:
	set(value):
		position_offset = value
		update_transform()

@export var rotation_offset: Vector3 = Vector3.ZERO:
	set(value):
		rotation_offset.x = value.x if abs(value.x) < 360 else 360 * sign(value.x)
		rotation_offset.y = value.y if abs(value.y) < 360 else 360 * sign(value.y)
		rotation_offset.z = value.z if abs(value.z) < 360 else 360 * sign(value.z)
		update_transform()

var mesh_position := Vector3.ZERO
var mesh_rotation := Vector3.ZERO


func update_collision() -> void:
	if not auto_sync: return
	if not mesh:
		shape = null
		return
	
	mesh_rotation = Vector3.ZERO
	mesh_position = Vector3.ZERO
	match type:
		_Shape_Type.TRIMESH:
			var tmp_mesh := mesh.create_outline(margin)
			tmp_mesh = tmp_mesh.create_outline(0)
			shape = tmp_mesh.create_trimesh_shape()
		
		_Shape_Type.CONVEX:
			var tmp_mesh := mesh.create_outline(margin)
			shape = tmp_mesh.create_convex_shape()
		
		_Shape_Type.SIMPLIFIED_CONVEX:
			var tmp_mesh := mesh.create_outline(margin)
			shape = tmp_mesh.create_convex_shape(true, true)
		
		_Shape_Type.BOUNDING_BOX:
			var aabb := mesh.get_aabb().grow(margin).abs()
			var box := BoxShape3D.new()
			box.size = aabb.size
			shape = box
			mesh_position = aabb.position + aabb.size * 0.5
		
		_Shape_Type.CAPSULE:
			var aabb := mesh.get_aabb().grow(margin).abs()
			var capsule := CapsuleShape3D.new()
			var params := get_shape_params(aabb) # x-heigh, y-radius, z-axis
			capsule.height = params.x
			capsule.radius = params.y
			shape = capsule
			mesh_position = aabb.position + aabb.size * 0.5
			if params.z == 0: mesh_rotation.z = 90
			if params.z == 2: mesh_rotation.x = 90
		
		_Shape_Type.CYLINDER:
			var aabb := mesh.get_aabb().grow(margin).abs()
			var cylinder := CylinderShape3D.new()
			var params := get_shape_params(aabb) # x->heigh, y->radius, z->axis
			cylinder.height = params.x
			cylinder.radius = params.y
			shape = cylinder
			mesh_position = aabb.position + aabb.size * 0.5
			if params.z == 0: mesh_rotation.z = 90
			if params.z == 2: mesh_rotation.x = 90
		
		_Shape_Type.SPHERE:
			var aabb := mesh.get_aabb().grow(margin).abs()
			var sphere := SphereShape3D.new()
			var params := get_shape_params(aabb) # x->heigh, y->radius, z->axis
			sphere.radius = params.x * 0.5
			shape = sphere
			mesh_position = aabb.position + aabb.size * 0.5
	
	update_transform()


func update_transform() -> void:
	position = position_offset + mesh_position
	rotation_degrees = rotation_offset + mesh_rotation


func get_shape_params(aabb: AABB) -> Vector3:
	var height: float
	var radius: float
	var main_axis: int = 0 # 0->x, 1->y, 2->z;
	
	match axis: 
		_Axis.X: main_axis = 0
		_Axis.Y: main_axis = 1
		_Axis.Z: main_axis = 2
		_Axis.LONGEST: main_axis = aabb.size.max_axis_index()
	
	if main_axis == 0: 
		if radius_axis == _Radius_Axis.SHORTER:
			radius = min(aabb.size.y, aabb.size.z) * 0.5
		else:
			radius = max(aabb.size.y, aabb.size.z) * 0.5
		height = aabb.size.x
		main_axis = 0
		
	elif main_axis == 1:
		if radius_axis == _Radius_Axis.SHORTER:
			radius = min(aabb.size.x, aabb.size.z) * 0.5
		else:
			radius = max(aabb.size.x, aabb.size.z) * 0.5
		height = aabb.size.y
		main_axis = 1
		
	elif main_axis == 2: 
		if radius_axis == _Radius_Axis.SHORTER:
			radius = min(aabb.size.x, aabb.size.y) * 0.5
		else:
			radius = max(aabb.size.x, aabb.size.y) * 0.5
		height = aabb.size.z
		main_axis = 2
	
	return Vector3(height, radius, main_axis)
