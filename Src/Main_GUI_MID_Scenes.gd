extends Control

var selected_test = "Simple"
var selected_resolution = 1.0

const btn_select_scene = "/root/Main/GUI_MID/Scenes/List/Select_Scene"
const resolution_button = "/root/Main/GUI_MID/Scenes/Settings/Resolution_Button"

const text_simple = "A simple scene with a single light source and minimal geometry and textures.\n\nClick the \"Load...Scene\" button to load the test. Click \"Benchmark\" to run the benchmark.\n\nThe results are automatically saved in the \"Benchmark-Result.txt\" file next to the program."
const text_shader = "A scene designed to stress the GPU shader cores."
const text_texture = "This test fills the graphics card's memory with textures. This allows you to check the functionality of the video card memory.\n\nFor best results, please use specialized VRAM testing tools."
const text_texture16384 = "This test checks whether the video card driver supports working with textures of size 16384x16384.\n\nFor best results, please use specialized VRAM testing tools."

func _ready():
	select_scene_fill()
	settings_fill()
	scene_description_update()

func scene_description_update():
	if selected_test == "Simple":
		get_node("List/Description").set_text(text_simple)
	if selected_test == "Shader":
		get_node("List/Description").set_text(text_shader)
	if selected_test == "Texture128":
		get_node("List/Description").set_text(text_texture)
	if selected_test == "Texture256":
		get_node("List/Description").set_text(text_texture)
	if selected_test == "Texture512":
		get_node("List/Description").set_text(text_texture)
	if selected_test == "Texture1024":
		get_node("List/Description").set_text(text_texture)
	if selected_test == "Texture2048":
		get_node("List/Description").set_text(text_texture16384)
	
	if selected_test == "PreHeat":
		get_node("List/Description").set_text("This scene is too simple for video cards, so the CPU will be the bottleneck in most cases...")

func _on_Settings_Apply_pressed():
	get_node("/root/Main").resize_multi(selected_resolution)
	get_node("/root/Main").reference_set(str(selected_test))

func settings_fill():
	get_node(resolution_button).add_item("1x - 640x360", 0)
	get_node(resolution_button).add_item("2x - 1280x720", 1)

func select_scene_fill():
	get_node(btn_select_scene).add_item("Simple Test", 0)
	get_node(btn_select_scene).add_item("Shader Test", 1)
	get_node(btn_select_scene).add_item("Texture Fill (128 MB)", 2)
	get_node(btn_select_scene).add_item("Texture Fill (256 MB)", 3)
	get_node(btn_select_scene).add_item("Texture Fill (512 MB)", 4)
	get_node(btn_select_scene).add_item("Texture Fill (1024 MB)", 5)
	get_node(btn_select_scene).add_item("Texture Fill (16384x16384 ~1053 MB)", 6)
	get_node(btn_select_scene).add_item("PreHeat", 7)

func _on_Select_Scene_item_selected( ID ):
	if ID == 0: selected_test = "Simple"
	elif ID == 1: selected_test = "Shader"
	elif ID == 2: selected_test = "Texture128"
	elif ID == 3: selected_test = "Texture256"
	elif ID == 4: selected_test = "Texture512"
	elif ID == 5: selected_test = "Texture1024"
	elif ID == 6: selected_test = "Texture2048"
	elif ID == 7: selected_test = "PreHeat"
	scene_description_update()

func _on_Resolution_Button_item_selected( ID ):
	if ID == 0: selected_resolution = 1.0
	elif ID == 1: selected_resolution = 2.0

func _on_Scene_Load_pressed():
	get_node("../../Scene_Node").scene_load(selected_test)
	get_node("/root/Main").reference_set(str(selected_test))
	get_node("/root/Main").benchmark_reset("Scene Changed...")
	get_node("/root/Main").loaded_scene = str(selected_test)


func _on_Batch_pressed():
	get_node("/root/Main").benchmark_start_batch()
