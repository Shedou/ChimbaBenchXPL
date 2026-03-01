extends Control

var selected_test = "Simple"
var selected_resolution = 1.0

const btn_select_scene = "/root/Main/GUI_MID/Scenes/List/Select_Scene"
const resolution_button = "/root/Main/GUI_MID/Scenes/Settings/Resolution_Button"

func _ready():
	select_scene_fill()
	settings_fill()
	scene_description_update()

func scene_description_update():
	if selected_test == "Simple":
		get_node("List/Description").set_text("A simple scene with a single light source and minimal geometry and textures.\n\nSuitable for testing the performance of very low-end graphics cards.")
	if selected_test == "Secret":
		get_node("List/Description").set_text("This scene is not intended for testing.")

func _on_Settings_Apply_pressed():
	get_node("/root/Main").resize_multi(selected_resolution)
	get_node("/root/Main").reference_set(str(selected_test))

func settings_fill():
	get_node(resolution_button).add_item("1x - 640x360", 0)
	get_node(resolution_button).add_item("2x - 1280x720", 1)

func select_scene_fill():
	get_node(btn_select_scene).add_item("Simple Test", 0)
	get_node(btn_select_scene).add_item("...", 1)

func _on_Select_Scene_item_selected( ID ):
	if ID == 0: selected_test = "Simple"
	elif ID == 1: selected_test = "Secret"
	scene_description_update()

func _on_Resolution_Button_item_selected( ID ):
	if ID == 0: selected_resolution = 1.0
	elif ID == 1: selected_resolution = 2.0

func _on_Scene_Load_pressed():
	get_node("../../Scene_Node").scene_load(selected_test)
	get_node("/root/Main").reference_set(str(selected_test))
