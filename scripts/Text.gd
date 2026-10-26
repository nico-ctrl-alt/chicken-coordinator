class_name Text

extends Node3D


@export var Aleph : Array[Texture2D]
@export var offset : Vector3
@export var spacingX = 10.0;
@export var spacingY = 10.0;
@export var size_general = 1.0
@export var size_individual = 1.0
@export var wraplimit = 50;
@export var rotational : Vector3
var letters = {}
@export var text = ""
var computed_text = []
@export var letter : PackedScene
@export var disappear = false
@onready var player = get_tree().current_scene.get_node("kami")

var time = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	letters["A"] = Aleph[0]
	letters["B"] = Aleph[1] 
	letters["C"] = Aleph[2] 
	letters["D"] = Aleph[3] 
	letters["E"] = Aleph[4] 
	letters["F"] = Aleph[5] 
	letters["G"] = Aleph[6] 
	letters["H"] = Aleph[7] 
	letters["I"] = Aleph[8] 
	letters["J"] = Aleph[9] 
	letters["K"] = Aleph[10] 
	letters["L"] = Aleph[11] 
	letters["M"] = Aleph[12] 
	letters["N"] = Aleph[13] 
	letters["O"] = Aleph[14] 
	letters["P"] = Aleph[15] 
	letters["Q"] = Aleph[16] 
	letters["R"] = Aleph[17] 
	letters["S"] = Aleph[18] 
	letters["T"] = Aleph[19] 
	letters["U"] = Aleph[20] 
	letters["V"] = Aleph[21] 
	letters["W"] = Aleph[22] 
	letters["X"] = Aleph[23] 
	letters["Y"] = Aleph[24] 
	letters["Z"] = Aleph[25]
	letters[" "] = Aleph[26]
	
	letters["a"] = Aleph[0]
	letters["b"] = Aleph[1] 
	letters["c"] = Aleph[2] 
	letters["d"] = Aleph[3] 
	letters["e"] = Aleph[4] 
	letters["f"] = Aleph[5] 
	letters["g"] = Aleph[6] 
	letters["h"] = Aleph[7] 
	letters["i"] = Aleph[8] 
	letters["j"] = Aleph[9] 
	letters["k"] = Aleph[10] 
	letters["l"] = Aleph[11] 
	letters["m"] = Aleph[12] 
	letters["n"] = Aleph[13] 
	letters["o"] = Aleph[14] 
	letters["p"] = Aleph[15] 
	letters["q"] = Aleph[16] 
	letters["r"] = Aleph[17] 
	letters["s"] = Aleph[18] 
	letters["t"] = Aleph[19] 
	letters["u"] = Aleph[20] 
	letters["v"] = Aleph[21] 
	letters["w"] = Aleph[22] 
	letters["x"] = Aleph[23] 
	letters["y"] = Aleph[24] 
	letters["z"] = Aleph[25]
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	time += delta
	for i in len(text) :
		if i >= len(computed_text) :
			var l = letter.instantiate() as MeshInstance3D
			add_child(l)
			l.material_override = l.get_active_material(0).duplicate()
			computed_text.push_back(l)
			continue
	var char_count = 0
	var row_count = 0

	
	for i in len(computed_text) :
		if i >= len(text) :
			computed_text[i].queue_free
			computed_text.erase(i)
			continue
		if computed_text[i].get_active_material(0).get("albedo_texture") != letters[text[i]] :
			computed_text[i].get_active_material(0).set("albedo_texture", letters[text[i]])
		char_count += 1
		if char_count > wraplimit && text[i] == " " :
			row_count += 1
			char_count = 0
		computed_text[i].position = (basis.x * char_count * spacingX/10) + (-basis.y*row_count * (spacingY/10) )+offset + (basis.y/50* sin(time+i))
		computed_text[i].scale = Vector3.ONE * size_general/(1.5 if text[i].to_lower() == text[i] else 1)
		computed_text[i].transparency = lerp(computed_text[i].transparency, 1.0 if disappear && player.velocity.length() > .8 else 0.0, delta)
		computed_text[i].rotation = rotational
		
	pass
