extends Node

const scene_list = {
	"Simple":"res://Scenes/Simple/Scene_Simple.tscn",
	"Shader":"res://Scenes/Shader/Scene_Shader_Alt.tscn",
	"Texture128":"res://Scenes/Texture128/Scene_Texture.tscn",
	"Texture256":"res://Scenes/Texture256/Scene_Texture.tscn",
	"Texture512":"res://Scenes/Texture512/Scene_Texture.tscn",
	"Texture1024":"res://Scenes/Texture1024/Scene_Texture.tscn",
	"Texture2048":"res://Scenes/Texture2048/Scene_Texture.tscn",
	"Secret":"res://Scenes/Secret/Scene_Secret.tscn"
}

var scene_instance
var scene
var node_children

func _ready():
	pass

func scene_load(name):
	scene_delete_all()
	if scene_list[name]:
		scene = load(scene_list[name])
		scene_instance = scene.instance()
		if scene_instance:
			get_node("/root/Main/Scene_Node").add_child(scene_instance)

func scene_delete_all():
	node_children = get_node("/root/Main/Scene_Node").get_children()
	
	for child in node_children:
		#remove_child(child)
		child.nfree()
		child.queue_free()
		child = null
	node_children = null
	#node_children.queue_free()

func scene_reload():
	get_tree().reload_current_scene()
