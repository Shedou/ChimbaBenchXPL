extends Control

func _ready():
	get_node("Background/Project_Name").set_text(get_node("/root/Main").project_name+" - "+get_node("/root/Main").project_version)
	get_node("Background/Project_License").set_text(get_node("/root/Main").project_license)
	get_node("Background/Godot_Engine").set_text("Based on Godot Engine 2.1.5")


func _on_Project_URL_pressed(): OS.shell_open("https://github.com/Shedou/ChimbaBenchXPL")
func _on_Blog_URL_pressed(): OS.shell_open("https://overclockers.ru/blog/Hard-Workshop")
func _on_GitHub_URL_pressed(): OS.shell_open("https://github.com/Shedou")
