extends Node

const scene_list = {
	"Simple":"res://Scenes/Simple/Scene_Simple.tscn",
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
		child.queue_free()
		child = null
	node_children = null

func scene_reload():
	get_tree().reload_current_scene()