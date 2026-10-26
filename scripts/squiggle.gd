class_name Squiggle

extends CharacterBody3D

@export var health = 100.0
@export var fall = 100.0
@export var layer = 0;
@export var particles : GPUParticles3D
@export var healthbar : TextureProgressBar
@export var healthbar_vis : GeometryInstance3D
@export var cull_on_death = true
@export var frequency = 1.0;
@export var bone_damage = 1.0
@export var transition_time = 1.0
var fwens = []
@export var materials : Array[Material];

@export var light_change : Array[Node3D]
@export var change_dist : Array[float]
@export var change_size : Array[float]
@export var GI_maps : Array[ViewportTexture]
@export var GI_offset : Array[Vector3]
@export var skele : Skeleton3D
@export var skin : Array[MeshInstance3D]
@export var high_skin : Array[Mesh]
@export var low_skin : Array[Mesh]
@export var noise : FastNoiseLite
@export var ragdoll : PackedScene

@onready var bones = {}
@onready var phys_sphere = load("res://phys_sphere.tscn")
@onready var fire_particles = $fire_particles
@onready var shape_cast : ShapeCast3D = $ShapeCast3D
var tmprot = {}
var restrot = {}
var restscale = {}
var ragbones = {}
var ragparents = {}
var raglocalpos = {}
var bonehealth = {}
var override = 0.0
var time = 0.0
@export var isactive = true

var boss : Squiggle
var bounce_vel : Vector3 = Vector3.ZERO
var g_time = 0.0
var a_time = 0.0
var d_time = 0.0
var dd_time = 0.0
var respawn = false;
var timestarted = 0.0
var cur_anim = "something"
var last_anim = "something"
var cur_lightmap = 5
var interests = {}
var trans = 1.0
var tmp_speed = 0.0;
var g = 0.0
var status_effects = {}
var smack = 0.0
var iframes = 0.0
var ecosys : EcoSystem
var stone = 0.0
var hash = 0.0
var mush = 0.0
var splash =0.0
var spawnpoint
var is_colliding
var on_collision_enter



func set_bones() -> void :
	spawnpoint = global_position
	for i in bones :
		print(bones[i])
		restrot[i] = bones[i].rotation
		tmprot[i] = bones[i].rotation
		restscale[i] = bones[i].scale
		bonehealth[i] = 100
		
func set_bones_skele() -> void :
	for i in bones :
		print(bones[i])
		restrot[i] = skele.get_bone_pose_rotation(bones[i]).get_euler()
		tmprot[i] = skele.get_bone_pose_rotation(bones[i]).get_euler()
		restscale[i] = skele.get_bone_pose_scale(bones[i])
		bonehealth[i] = 100
		
func copy_GI(s : Squiggle) -> void :
	light_change = s.light_change 
	change_dist = s.change_dist
	change_size = s.change_size
	GI_maps = s.GI_maps 
	GI_offset = s.GI_offset 
	pass
	
func lod_skin(lod : bool) -> void:
	for i in len(skin) :
		skin[i].mesh = low_skin[i] if lod else high_skin[i]
	

func reset_anim() -> void :
	return
	for i in bones :
		if bones[i] == null :
			continue
		bones[i].scale = lerp(bones[i].scale, restscale[i], get_process_delta_time() * 10.0)
		bones[i].rotation = restrot[i]
	pass
	
func set_scales() -> void :
	for i in bones :
		if bones[i] == null :
			continue
		bones[i].scale = lerp(bones[i].scale, restscale[i], get_process_delta_time() * 10.0)
	
func reset_anim_skele() -> void :
	return
	for i in bones :
		if bones[i] == null :
			continue
		skele.set_bone_pose_scale(bones[i], lerp(skele.get_bone_pose_scale(bones[i]), restscale[i], get_process_delta_time() * 10.0))
		skele.set_bone_pose_rotation(bones[i], Quaternion.from_euler(restrot[i]))
	pass

func set_scales_skele() -> void :
	for i in bones :
		if bones[i] == null :
			continue
		skele.set_bone_pose_scale(bones[i], lerp(skele.get_bone_pose_scale(bones[i]), restscale[i], get_process_delta_time() * 10.0))
	
func respawn_anim() -> void :
	health = 100.0
	for i in bones :
		if bones[i] == null :
			continue
		bones[i].visible = true
		bonehealth[i] = 100
		
	
func death_anim(origin : Vector3, raggy = false) -> void :
	reset_anim()
	for i in bones :
		if bones[i] == null :
			continue
		bonefly(i, origin, raggy)
	if cull_on_death :
		if ragdoll :
			var r = ragdoll.instantiate()
			get_tree().current_scene.add_child(r)
			r.global_position = global_position
			r.rotation = rotation
			var rb = r.get_node("Armature/Skeleton3D/PhysicalBoneSimulator3D") as PhysicalBoneSimulator3D
			rb.physical_bones_start_simulation()
			rb.get_node("Physical Bone Bone").apply_impulse((-global_position.direction_to(origin)*10.0) + velocity*10.0)
		bones.clear()
		queue_free()
	pass
	
func sin_curve(v : float, curve : Curve) -> float :
	return curve.sample(abs(sin(v))) * (1 if sin(v) > 0 else  -1) 
	
func perlin_shake(amp : float, axis : Vector3, speed : float) -> Vector3 :
	var atime = time * speed
	return axis * noise.get_noise_3d(atime, atime, atime) * amp
	
func wobble_wobble(delta : float, chain : Array[Node3D], accel : float) -> void:
	var rot = chain[0].get_parent().global_rotation
	for i in chain : 
		i.global_rotation += (rot - i.global_rotation) * accel
		rot = i.rotation
	
func bonefly(i : String, origin : Vector3, raggy = false) -> void :
	
	
	if bones[i] == null ||  (bones[i] is int):
		return
	var ps = phys_sphere.instantiate() as PhysicsBody
	var cs = ps.get_node("CollisionShape3D") as CollisionShape3D
	var newbone = bones[i].duplicate(0) if !(bones[i] is int) else skin[0].duplicate(0)
	var oldbone = bones[i] if !(bones[i] is int) else self
	
	for n in newbone.get_children() :
		newbone.remove_child(n)
		n.queue_free()

	particles.emit_particle(oldbone.transform, Vector3.ZERO, Color.ANTIQUE_WHITE, Color.ALICE_BLUE, 0)
		
	oldbone.get_parent().add_child(newbone);
	newbone.global_position = oldbone.global_position;
	get_tree().current_scene.add_child(ps)
	ps.global_position = newbone.global_position
	newbone.reparent(ps, true)
	if status_effects.has("fire") :
		ps.fire = true
		
	

	
	ps.root = newbone
	if raggy : 
		ps.cull_t = 1000000000000000.0
		ps.fire = false
		ragbones[i] = ps
		var bparent = oldbone.get_parent
		var key = bones.find_key(bparent)
		ragparents[i] = ragbones[key] if ragbones.has(key) else null
		raglocalpos[i] = oldbone.position
	ps.apply_impulse((oldbone.global_position - origin).normalized() * 2.0 * (bounce_vel.length()/10.0) + velocity)
	ps.apply_torque((oldbone.global_position - origin).normalized() * 2.0)
	ps.active = true
	oldbone.visible = false;
	pass

func e_lookrot(up : Vector3, dir : Vector3, offset = Vector3.ZERO) -> Vector3 :
	return Transform3D.IDENTITY.looking_at(dir.rotated(offset.normalized(), offset.length()), up).basis.get_euler()

func set_rot(bone: String, time : float, vector : Vector3, amp = 1.0, priority = 0.0) -> void :
	if not bones.has(bone) || not bones[bone] || fmod(time, 2.0) == 0:
		return
	override = lerp(override, 1.0, .01)
	vector *= amp
	if health > 0.0 :
		var anim = lerp(Vector3(sin(time*3.0), -cos(time*4.0), sin(time*5.0)), restrot[bone] + (vector*1.0), override)
		bones[bone].rotation = wobble_lerp(bones[bone].rotation, anim, .1);
		var transition = lerp(tmprot[bone], anim, trans);
		last_anim = cur_anim if bones[bone].rotation.distance_to(restrot[bone] + vector) < .01 else last_anim
		trans = 1.0 if cur_anim == last_anim else lerp(trans, 0.0, .01)
	pass
	
func dir_towards(source : Node3D) -> Vector3 :
	return (source.global_position-global_position).normalized()
	
func dir_towards_closest(preferred : Array[Node3D]) -> Vector3 :
	var source = ecosys._smell_closest(self, 10, preferred)
	return (source.global_position-global_position).normalized()

func where_to_target(target : Node3D) -> Dictionary :
	var space_state = get_world_3d().direct_space_state
	if !space_state :
		return Dictionary()
	var origin = global_position
	var end = origin + target.global_position * 9999999999
	var query = PhysicsRayQueryParameters3D.create(origin, end)
	query.collide_with_areas = true

	return space_state.intersect_ray(query)


func is_vis(min = 0.0) -> bool :
	return ecosys.camdir.dot(global_position-ecosys.cam.global_position) > min

func set_rot_skele(bone: String, time : float, vector : Vector3, amp = 1.0) -> void :
	if not bones.has(bone) || not bones[bone] || fmod(time, 2.0) == 0:
		return
	override = lerp(override, 1.0, .01)
	vector *= amp
	if health > 0.0 :
		var anim = lerp(Vector3(sin(time*3.0), -cos(time*4.0), sin(time*5.0)), restrot[bone] + (vector*1.0), override)
		skele.set_bone_pose_rotation(bones[bone], Quaternion.from_euler(wobble_lerp(skele.get_bone_pose_rotation(bones[bone]).get_euler(), anim, .1)));
		var transition = lerp(tmprot[bone], anim, trans);
		last_anim = cur_anim if skele.get_bone_pose_rotation(bones[bone]).get_euler().distance_to(restrot[bone] + vector) < .01 else last_anim
		trans = 1.0 if cur_anim == last_anim else lerp(trans, 0.0, .01)
	pass
	
func wobble_lerp(A : Vector3, B : Vector3, X : float) -> Vector3 :
	var cosxpi = cos(X * PI)*X
	return A+(.5 * (A * (cosxpi - 1) + B * (1 - cosxpi)))
	
func add_fwen(fwen : Squiggle, recurse : bool = false) -> void :
	timestarted = time
	if fwens.has(fwen) :
		return
	fwens.push_front(fwen)
	frequency = fwen.frequency + PI/len(fwens)
	var dum = 0
	if(recurse) :
		for	i in fwens :
			dum += 1 
			i.add_fwen(fwen)
			i.frequency = fwen.frequency + ((PI/len(fwens))*dum)
			
func render_healthbar(delta : float) -> void :
	process_effects(delta)
	
	if healthbar :
		healthbar.value = health
		healthbar_vis.transparency = lerp(healthbar_vis.transparency, 100.0 if d_time <= 0.0 else 0.0, .1)
	
func play_mod_sound(source : AudioStreamPlayer3D, vol : float, master : float, pitch : float, length : float, panning = 0, startpos = 0) ->void :
	if source.get_playback_position() > length || not source.playing :
		source.play(startpos)
	source.pitch_scale = clamp(pitch,0.1,10.0)
	source.volume_linear = vol * master
	source.panning_strength = panning
	
func dubsin(v : float) -> float :
	return sin(v)*2 - (sin(v/2)/2)
	
func dubcos(v : float) -> float :
	return cos(v)*2 - (cos(v/2)/2)
	
func death_override() -> void :
	pass
	
func raggy_dolls(strength : float) -> void :
	for n in ragbones :
		if ragbones[n] == null || bones[n] == null: 
			continue
		ragbones[n].global_position = bones[n].global_position if ragparents[n] == null else ragparents[n].global_position + raglocalpos[n]
		ragbones[n].global_rotation = lerp(ragbones[n].global_rotation, bones[n].global_rotation, strength*get_physics_process_delta_time())
	
func smanish(amp : float, force : float, vel : Vector3, origin : Vector3, i_frames = 3.0) -> void :
	if d_time > 0.1 or health <= 0 or iframes > 0.1:
		return
	override = 0.0
	d_time = i_frames
	iframes = i_frames
	bounce_vel += vel * force
	health -= amp
	
	for i in int(amp*5.0) :
		var t = Transform3D(Basis(),  lerp(global_position, origin, .5)+(Vector3(randf_range(-1,1),randf_range(-1,1),randf_range(-1,1)))*5.0)
		particles.emit_particle(t, Vector3.ZERO, Color.ANTIQUE_WHITE, Color.ALICE_BLUE, 0)
	
	for i in bones :
		if !bones[i] || bones[i] is int:
			continue
			
		var damage = clamp(10.0-(origin.distance_squared_to(bones[i].global_position)*10.0), 0, 1.0);
		print(damage)
		if particles && damage > 1.0 :
			bonehealth[i] -= damage* bone_damage
			
		if bonehealth[i] <= 0 && bones[i].visible :
			health -= 1
			bonefly(i, origin)
	if health <= 0 :
		death_override()
		death_anim(origin)
	pass
	
func change_GI(i : int) -> void :
	if cur_lightmap == i :
		return
	for m in bones :
		if !bones[m] || bones[m] is int: 
			continue
		var b = bones[m] as MeshInstance3D
		if bones[m] is MeshInstance3D :
			for mm in b.get_surface_override_material_count() :
				if !materials.has(b.get_active_material(mm)) &&  b.get_active_material(mm).get("shader_parameter/y_GI"):
					print('something changed')
					var j = b.get_active_material(mm)
					j.set("shader_parameter/y_GI", GI_maps[i])
					j.set("shader_parameter/x_GI", null)
					j.set("shader_parameter/z_GI", null)
					j.set("shader_parameter/GI_size", change_size[i])
					j.set("shader_parameter/y_offset", GI_offset[i])
					
	for c in skin :
		var b = c as MeshInstance3D
		for mm in b.get_surface_override_material_count() :
			if !materials.has(b.get_active_material(mm)) &&  b.get_active_material(mm).get("shader_parameter/y_GI"):
				print('something changed')
				var j = b.get_active_material(mm)
				j.set("shader_parameter/y_GI", GI_maps[i])
				j.set("shader_parameter/x_GI", null)
				j.set("shader_parameter/z_GI", null)
				j.set("shader_parameter/GI_size", change_size[i])
				j.set("shader_parameter/y_offset", GI_offset[i])
	cur_lightmap = i
	pass
	
	
func process_effects(delta : float) ->void :
	tmp_speed = lerp(tmp_speed, 1.0, delta)
	maintain_transrot()
	
	var ichangedtoday = false;
	
	#for i in len(light_change) :
		#if global_position.distance_to(light_change[i].global_position) < change_dist[i] :
				#ichangedtoday = true;
				#change_GI(i)
				
	if !ichangedtoday :
		change_GI(8)
	d_time = lerp(d_time, 0.0, delta * 10.0)
	iframes = lerp(iframes, 0.0, delta)
	for i in status_effects :
		if status_effects[i] <= 0 :
			status_effects.erase(i)
			continue
		
		if i == "fire" :
			if sin(time*25.0) > .9 :
				smanish(.5, 0,Vector3.ZERO, global_position, 0.0)
			g = 3.0 if is_on_floor() else g 
			if status_effects[i] > .1 && not fire_particles.visible :
				fire_particles.visible = true
			
			if status_effects[i] < .1 :
				fire_particles.visible = false;
			
		if i == "calm_water" :
			tmp_speed = .2
			
		if i == "poison" :
			smanish(.5, 0,Vector3.ZERO, global_position)
			
		if i == "vine" :
			tmp_speed = 0
			
			
		status_effects[i] -= delta
			
	
# Called when the node enters the scene tree for the first time.
func squig_ready() -> void:
	ecosys = get_tree().current_scene.get_node("EcoSystem");
	spawnpoint = global_position
	ecosys.squigs.push_front(self)
	print(ecosys)
	if healthbar :
		healthbar.max_value = health
	pass # Replace with function body.
	
	
func process_fall() -> void:
	if global_position.y < -600 : 
		g = 0.0
		velocity = Vector3.ZERO
		bounce_vel = Vector3.ZERO
		global_position =  spawnpoint
		
func maintain_transrot() -> void:
	if d_time <= 0 && trans <= 0 && override >= .9:
		for i in bones :
			tmprot[i] = bones[i].rotation


# Called every frame. 'delta' is the elapsed time since the previous frame.
