@tool
extends Camera3D

@export var path : String
@export var sprite : Sprite3D

func _ready() -> void:
	var rd:RenderingDevice = RenderingServer.get_rendering_device()
	var fmt:RDTextureFormat = RDTextureFormat.new()
	fmt.format = RenderingDevice.DATA_FORMAT_R16_SFLOAT
	fmt.width = 1024
	fmt.height = 1024
	fmt.usage_bits = RenderingDevice.TEXTURE_USAGE_STORAGE_BIT | RenderingDevice.TEXTURE_USAGE_SAMPLING_BIT | RenderingDevice.TEXTURE_USAGE_CAN_COPY_FROM_BIT
	var tex: RID = rd.texture_create(fmt, RDTextureView.new())
	
	
	sprite.material_override.set("shader_parameters/tex", tex)
	
	var instances : Array[Node] = get_tree().current_scene.find_children("*", "MeshInstance3D", true)
	for i in instances :
		for j in i.get_surface_override_material_count() :
			var m = i.get_surface_override_material(j)
			if !m: 
				continue
			
			if m.get("shader_parameters/x_GI") : 
				m.set("shader_parameters/" + path, tex)
	
	var effect : DepthEffect = compositor.compositor_effects[0]
	effect.target_tex = tex 
