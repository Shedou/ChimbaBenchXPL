extends Control

const btn_select_list = "/root/Main/GUI_MID/Results/Select_List"
const btn_select_list_scene = "/root/Main/GUI_MID/Results/Select_List_Scene"
var selected_scene = "PreHeat"
var selected_platform = "Windows"

var FileWithResults = File.new()
var FileWithResultsCode = null
var FileWithResultsPath = null
var ResultsT = []

const result_files = {
"SimpleComplex":"/DB/Results-Simple-Complex.txt",
"SimpleWindows":"/DB/Results-Simple-Windows.txt",
"SimpleLinux":"/DB/Results-Simple-Linux.txt",
"ShaderComplex":"/DB/Results-Shader-Complex.txt",
"ShaderWindows":"/DB/Results-Shader-Windows.txt",
"ShaderLinux":"/DB/Results-Shader-Linux.txt",
"PreHeatComplex":"/DB/Results-PreHeat-Complex.txt",
"PreHeatWindows":"/DB/Results-PreHeat-Windows.txt",
"PreHeatLinux":"/DB/Results-PreHeat-Linux.txt",
}

func _ready():
	select_list_fill()
	select_list_scene_fill()
	list_fill("PreHeat", "Windows")
	set_process_input(true)

func list_fill(test, platform):
	get_node("ItemList").clear()
	ResultsT = []
	FileWithResultsPath = str(CBXPL.main_execute_path+result_files[test+platform])
	if FileWithResults.open(FileWithResultsPath, File.READ) == OK:
		while not FileWithResults.eof_reached():
			ResultsT.append(FileWithResults.get_line())
		FileWithResults.close()
		for item in ResultsT:
			get_node("ItemList").add_item(" "+str(item))
	else:
		get_node("ItemList").add_item("Error opening file: "+str(FileWithResultsPath))

func select_list_fill():
	get_node(btn_select_list).add_item("Windows", 0)
	get_node(btn_select_list).add_item("Linux", 1)
	get_node(btn_select_list).add_item("Complex", 2)

func select_list_scene_fill():
	get_node(btn_select_list_scene).add_item("PreHeat Test", 0)
	get_node(btn_select_list_scene).add_item("Simple Test", 1)
	get_node(btn_select_list_scene).add_item("Shader Test", 2)
	

func _on_Select_List_Scene_item_selected( ID ):
	if ID == 0: selected_scene = "PreHeat"
	if ID == 1: selected_scene = "Simple"
	if ID == 2: selected_scene = "Shader"
	list_fill(selected_scene, selected_platform)

func _on_Select_List_item_selected( ID ):
	if ID == 0: selected_platform = "Windows"
	elif ID == 1: selected_platform = "Linux"
	elif ID == 2: selected_platform = "Complex"
	list_fill(selected_scene, selected_platform)
