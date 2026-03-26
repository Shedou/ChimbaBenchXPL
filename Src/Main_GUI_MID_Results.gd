extends Control

const btn_select_list = "/root/Main/GUI_MID/Results/Select_List"
const btn_select_list_scene = "/root/Main/GUI_MID/Results/Select_List_Scene"

var FileWithResults = File.new()
var FileWithResultsCode = null
var FileWithResultsPath = null
var ResultsT = []

const result_files = {
"Simple360pComplex":"/DB/Results-Simple-360p-Complexe.txt",
"Simple720pComplex":"/DB/Results-Simple-720p-Complex.txt",
"Shader360pComplex":"/DB/Results-Shader-360p-Complex.txt",
"Shader720pComplex":"/DB/Results-Shader-720p-Complex.txt",
"Simple360pWindows":"/DB/Results-Simple-360p-Windows.txt",
"Simple720pWindows":"/DB/Results-Simple-720p-Windows.txt",
"Shader360pWindows":"/DB/Results-Shader-360p-Windows.txt",
"Shader720pWindows":"/DB/Results-Shader-720p-Windows.txt",
"Simple360pLinux":"/DB/Results-Simple-360p-Linux.txt",
"Simple720pLinux":"/DB/Results-Simple-720p-Linux.txt",
"Shader360pLinux":"/DB/Results-Shader-360p-Linux.txt",
"Shader720pLinux":"/DB/Results-Shader-720p-Linux.txt",
"Simple360pWINE":"/DB/Results-Simple-360p-WINE.txt",
"Simple720pWINE":"/DB/Results-Simple-720p-WINE.txt",
"Shader360pWINE":"/DB/Results-Shader-360p-WINE.txt",
"Shader720pWINE":"/DB/Results-Shader-720p-WINE.txt",
}

func _ready():
	select_list_fill()
	select_list_scene_fill()
	list_fill("Simple360pComplex")

func list_fill(name):
	var FileWithResultsPath = str(get_node("/root/Main").main_execute_path+result_files[name])
	if FileWithResults.open(FileWithResultsPath, File.READ) == OK:
		while not FileWithResults.eof_reached():
			ResultsT.append(FileWithResults.get_line())
		FileWithResults.close()
		for item in ResultsT:
			get_node("ItemList").add_item(" "+str(item))
	else:
		get_node("ItemList").add_item("Error opening file: "+str(FileWithResultsPath))

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
