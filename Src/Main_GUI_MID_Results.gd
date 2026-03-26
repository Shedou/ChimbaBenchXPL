extends Control

const btn_select_list = "/root/Main/GUI_MID/Results/Select_List"
const btn_select_list_scene = "/root/Main/GUI_MID/Results/Select_List_Scene"

var file_with_results = File.new()
var file_with_results_code = null
var file_with_results_path = null

const result_files = {
"Simple360p":"/DB/Results-Simple-360p.txt",
"Simple720p":"/DB/Results-Simple-720p.txt",
"Shader360p":"/DB/Results-Shader-360p.txt",
"Shader720p":"/DB/Results-Shader-720p.txt",
}

var ResultsT = []

func _ready():
	select_list_fill()
	select_list_scene_fill()
	list_fill()

func list_fill():
	var db_simple_640 = str(get_node("/root/Main").main_execute_path+result_files["Simple360p"])
	file_with_results_path = db_simple_640
	if file_with_results.open(file_with_results_path, File.READ) == OK:
		while not file_with_results.eof_reached():
			ResultsT.append(file_with_results.get_line())
		file_with_results.close()
	
	for item in ResultsT:
		get_node("ItemList").add_item(" "+str(item))
	

func select_list_fill():
	get_node(btn_select_list).add_item("Complex - 640x360", 0)
	get_node(btn_select_list).add_item("Complex - 1280x720", 1)
	get_node(btn_select_list).add_item("Windows - 640x360", 2)
	get_node(btn_select_list).add_item("Windows - 1280x720", 3)
	get_node(btn_select_list).add_item("Linux - 640x360", 4)
	get_node(btn_select_list).add_item("Linux - 1280x720", 5)
	get_node(btn_select_list).add_item("WINE - 640x360", 6)
	get_node(btn_select_list).add_item("WINE - 1280x720", 7)

func select_list_scene_fill():
	get_node(btn_select_list_scene).add_item("Simple Test", 0)
	get_node(btn_select_list_scene).add_item("Shader Test", 1)
