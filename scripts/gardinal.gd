extends Squiggle
class_name Gardinal

@export var stiffness_a : float
@export var damping_a : float
@export var stiffness_l : float
@export var damping_l : float
@export var phys_skele : Skeleton3D
var phys_bones = {}

func _animate_physics (delta : float) -> void :
	for l in phys_bones	:
		var b = phys_bones[l]
		var target_transform : Transform3D = skele.global_transform * skele.get_bone_global_pose(b.get_bone_id())
		var current_transform : Transform3D = phys_skele.global_transform * phys_skele.get_bone_global_pose(b.get_bone_id())
		
		var position_difference = target_transform.origin - current_transform.origin
		var force = hookes_law(position_difference, b.linear_velocity, stiffness_l, damping_l)
		b.linear_velocity += (force * delta)
		
		var rotation_difference: Basis = (target_transform.basis * current_transform.basis.inverse())
		var torque = hookes_law(rotation_difference.get_euler(), b.angular_velocity, stiffness_a, damping_a)
		b.angular_velocity += torque * delta
		
func hookes_law(d : Vector3, cv: Vector3, ss : float, dd : float) -> Vector3 :
	return (ss * d) - (dd * cv)
		
func walk_anim(animspeed : float, amp : float) -> void :
	cur_anim = "w"
	var atime = time * animspeed
	set_rot_skele("chest", atime, Vector3(sin(atime)/4,0,0), amp)
	set_rot_skele("neck", atime, Vector3(0,sin(atime/2 + PI)/4,0), amp)
	set_rot_skele("l_leg", atime, Vector3(0,0,sin(-atime)/2),amp)
	set_rot_skele("l_calf", atime, Vector3(0,0,sin(atime+PI/2)+.5),amp)
	set_rot_skele("r_leg", atime, Vector3(0,0,sin(-atime+PI)/2),amp)
	set_rot_skele("r_calf", atime, Vector3(0,0,sin(atime-PI/2)+.5),amp)
	set_rot_skele("l_arm", atime, Vector3(-.2, sin(atime)/10, sin(atime)),amp)
	set_rot_skele("l_forearm", atime, Vector3(0, 0,sin(atime)),amp)
	set_rot_skele("r_arm", atime, Vector3(.2, sin(atime)/10, sin(atime+PI)),amp)
	set_rot_skele("r_forearm", atime, Vector3(0, 0,-sin(atime)),amp)
	pass

func _ready() -> void :
	squig_ready()
	bones = {
		"root" : skele.find_bone("Bone"),
		"chest" : skele.find_bone("Bone.001"),
		"chest_1" : skele.find_bone("Bone.002"),
		"neck" : skele.find_bone("Bone.003"),
		"head" : skele.find_bone("Bone.004"),
		"l_shoulder" : skele.find_bone("Bone.006"),
		"l_arm" : skele.find_bone("Bone.007"),
		"l_forearm" : skele.find_bone("Bone.008"),
		"l_hand_1" : skele.find_bone("Bone.009"),
		"l_finger_1" : skele.find_bone("Bone.010"),
		"l_hand_2" : skele.find_bone("Bone.011"),
		"l_finger_2" : skele.find_bone("Bone.012"),
		"l_hand_3" : skele.find_bone("Bone.013"),
		"l_finger_3" : skele.find_bone("Bone.014"),
		"r_shoulder" : skele.find_bone("Bone.005"),
		"r_arm" : skele.find_bone("Bone.015"),
		"r_forearm" : skele.find_bone("Bone.016"),
		"r_hand_1" : skele.find_bone("Bone.017"),
		"r_finger_1" : skele.find_bone("Bone.018"),
		"r_hand_2" : skele.find_bone("Bone.019"),
		"r_finger_2" : skele.find_bone("Bone.020"),
		"r_hand_3" : skele.find_bone("Bone.021"),
		"r_finger_3" : skele.find_bone("Bone.022"),
		"l_hip" : skele.find_bone("Bone.023"),
		"l_leg" : skele.find_bone("Bone.025"),
		"l_calf" : skele.find_bone("Bone.027"),
		"l_foot" : skele.find_bone("Bone.029"),
		"l_backfoot" : skele.find_bone("Bone.031"),
		"r_hip" : skele.find_bone("Bone.024"),
		"r_leg" : skele.find_bone("Bone.026"),
		"r_calf" : skele.find_bone("Bone.028"),
		"r_foot" : skele.find_bone("Bone.030"),
		"r_backfoot" : skele.find_bone("Bone.032")
	}
	
	var tmp_bones = phys_skele.find_children("*", "PhysicalBone3D", true)
	
	for b in tmp_bones :
		if bones.values().has(b.get_bone_id()) :
			phys_bones[b.get_bone_id()] = b 
	
	print('something i already knew')
	phys_skele.physical_bones_start_simulation()
	set_bones_skele()

func _physics_process(delta: float) -> void:
	time += delta
	walk_anim(1.0, 1.0)
	_animate_physics(delta)
