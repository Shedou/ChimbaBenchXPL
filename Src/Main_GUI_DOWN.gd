extends Panel

var root = "/root/Main";

var menu_items = {
	"Scenes":root+"/GUI_MID/Scenes",
	"Reference":root+"/GUI_MID/Reference",
	"About":root+"/GUI_MID/About"
}
var menu_buttons = {
	"Scenes":root+"/GUI_DOWN/BTN_Scenes",
	"Reference":root+"/GUI_DOWN/BTN_Reference",
	"About":root+"/GUI_DOWN/BTN_About"
}

var menu_buttons_block_list = {
	"Exit":root+"/GUI_DOWN/BTN_Exit",
	"Scenes":root+"/GUI_DOWN/BTN_Scenes",
	"About":root+"/GUI_DOWN/BTN_About",
	"Reference":root+"/GUI_DOWN/BTN_Reference"
}

func _ready():
	pass

func menu_block():
	for button in menu_buttons_block_list:
		get_node(menu_buttons_block_list[button]).set_disabled(true)

func menu_unblock():
	for button in menu_buttons_block_list:
		get_node(menu_buttons_block_list[button]).set_disabled(false)

func menu_close():
	for item in menu_items:
		get_node(menu_items[item]).hide()
		get_node(menu_buttons[item]).set_pressed(false)

func menu_change(item):
	if get_node(menu_items[item]).is_visible():
		get_node(menu_items[item]).hide()
		get_node(menu_buttons[item]).set_pressed(false)
	else:
		for item in menu_items:
			get_node(menu_items[item]).hide()
			get_node(menu_buttons[item]).set_pressed(false)
		get_node(menu_items[item]).show()
		get_node(menu_buttons[item]).set_pressed(true)

func _on_BTN_Exit_pressed(): get_tree().quit()
func _on_BTN_Scenes_pressed(): menu_change("Scenes")
func _on_BTN_About_pressed(): menu_change("About")
func _on_BTN_Benchmark_pressed(): get_node("../.").benchmark_start()
func _on_BTN_Reference_pressed(): menu_change("Reference")
