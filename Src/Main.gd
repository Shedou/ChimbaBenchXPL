extends Node

const project_name = "ChimbaBenchXPL"
const project_version = "A3"
const project_license = "GNU GPLv3 or later"

var main_render_size = OS.get_video_mode_size() # Vector2()
var main_display_size = OS.get_screen_size()
var main_rd_sizes = str(str(main_render_size.width)+"x"+str(main_render_size.height))+" - "+str(str(main_display_size.width)+"x"+str(main_display_size.height))
var render_size_multiplier = 1.0
const window_size_default = Vector2(640, 360)
var window_size
var wine_detect = ["no"]
var main_cmd_line = OS.get_cmdline_args()
var main_cmd_execute = OS.get_executable_path()
var main_execute_path = main_cmd_execute.get_base_dir()
var main_current_os = OS.get_name()
var main_current_os_name = "undefined"
var main_current_os_name_arr = [""]
var main_current_os_kernel = ["undefined"]
var main_cpu_name = ["undefined"]
var main_cpu_name_str = ""
var main_gpu_name = ["undefined"]
var main_gpu_name_str = ""
var main_gpu_name_all_str = ""
var main_gpu_driver_name = [""]
var main_gpu_driver_name_str = ""
var main_current_os_kernel_str = ""
var main_exe_dir = OS.get_executable_path().get_base_dir();

var reference_texture = null
var theme_default = load("res://Default_Theme.tres")
var theme_default_big = load("res://Default_Theme_x2.tres")

const timer_quad = 0.25; const timer_half = 0.5; const timer_full = 1.0
var timer_quad_count = 0.0; var timer_half_count = 0.0; var timer_full_count = 0.0

var process_target_fps = 0
var process_fixed_target_fps = 0
const process_target_fps_def = 120
const process_target_fps_max = 0
const process_fixed_target_fps_def = 30
const process_fixed_target_fps_low = 6
const process_fixed_target_fps_low_bound = 12

var process_count = 0.0; var process_fixed_count = 0.0;
var process_fps = 0.0; var process_fixed_fps = 0.0
var process_timer = 0.0; var process_fixed_timer = 0.0

const bench_period = 30 # 40 = 20 seconds if benchmark() run in timer_half mode...
const bench_warm_time = 16

var bench_start_batch_counter = 0
var bench_start_batch = 0
var bench_start = 0; var bench_warm = 0
var bench = 0.0; var bench_count = 0; var bench_result = 0
var bench_fps_start = 0; var bench_fps_start_collected = 0
var bench_strange_flag = ""

var result_file = File.new()
var result_file_path = ""
var result_file_code = null
var loaded_scene = "Main Menu"

func _ready():
	result_file_path = str(main_execute_path+"/Benchmark-Result.txt")
	var full_command = str(OS.get_executable_path()) + " " + str(StringArray(OS.get_cmdline_args()).append(" "))
	OS.set_window_title(str(project_name)+" - "+str(project_version))
	get_hw_info()
	update_hw_info_labels()
	
	set_process(true); set_fixed_process(true)
	get_tree().get_root().connect("size_changed", self, "on_resize");
	
	OS.set_target_fps(process_target_fps_def)
	OS.set_iterations_per_second(process_fixed_target_fps_def)
	reference_set("Default")

func get_hw_info():
	main_cpu_name[0] = "not detected"
	main_gpu_name[0] = "not detected"
	if main_current_os == "Windows":
		main_current_os_name = "Windows"
		OS.execute("cmd", ["/c", "ver"], true, main_current_os_kernel)
		#OS.execute("cmd", ["/c", "reg query HKLM\\HARDWARE\\DEVICEMAP\\VIDEO /v \\Device\\Video0"], true, main_gpu_driver_name)
		OS.execute(main_exe_dir+"\\Helpers\\Wine-Detect.bat", [""], true, wine_detect)
		OS.execute(main_exe_dir+"\\Helpers\\Windows-CPU-Info.bat", [""], true, main_cpu_name)
		OS.execute(main_exe_dir+"\\Helpers\\Windows-GPU-Info.exe", [""], true, main_gpu_name)
	elif main_current_os == "X11":
		OS.execute("uname", ["-r"], true, main_current_os_kernel)
		main_current_os_name = "Linux"
		OS.execute("bash", ["-c", "lspci -k | grep -A 3 -E '(VGA|3D)' | grep 'in use' | cut -d ':' -f2 | tr -d ' '"], true, main_gpu_driver_name)
		OS.execute(main_exe_dir+"/Helpers/Linux-OS-Name.sh", [""], true, main_current_os_name_arr)
		if main_current_os_name_arr[0] != "":
			main_current_os_name = str(main_current_os_name_arr[0]).replace("\n", "")
		OS.execute("bash", ["-c", "cat /proc/cpuinfo | grep 'model name' | head -n1 | cut -d: -f2 | sed 's/^[ \t]*//'"], true, main_cpu_name)
		OS.execute("bash", ["-c", "lspci | grep -iE 'vga|3d|display' | cut -d':' -f3 | sed 's/^ //'"], true, main_gpu_name)
		if main_gpu_name[0] == "":
			OS.execute("bash", ["-c", "cat /sys/class/drm/card*/device/uevent | grep PCI_ID | cut -d'=' -f2"], true, main_gpu_name)
	
	main_current_os_kernel_str = str(main_current_os_kernel[0])
	main_cpu_name_str = str(main_cpu_name[0])
	main_gpu_name_str = str(main_gpu_name[0])
	main_gpu_driver_name_str = str(main_gpu_driver_name[0])
	
	#for item in range(main_gpu_name.size()):
	#	main_gpu_name_all_str = str(main_gpu_name[item])
	
	var wine_detect_regex = RegEx.new()
	wine_detect_regex.compile("WINE")
	var result = wine_detect_regex.find(str(wine_detect[0]))
	
	if result == 0: main_current_os_name = "Windows (WINE)"

func update_hw_info_labels():
	get_node("GUI_UP/CPU").set_text(str(main_cpu_name[0]))
	get_node("GUI_UP/VGA").set_text(str(main_gpu_name[0]))
	get_node("GUI_UP/display").set_text(main_rd_sizes)
	get_node("GUI_UP/OS").set_text("OS: "+str(main_current_os_name))

func reference_set(name):
	if render_size_multiplier == 2.0: reference_texture = load("res://References/"+name+"580.webp")
	else: reference_texture = load("res://References/"+name+"290.webp")
	get_node("GUI_MID/Reference").set_texture(reference_texture)

func _process(delta): fps_monitor_process(delta)
func _fixed_process(delta): fps_monitor_fixed_process(delta)
	timer_half_count += delta
	if timer_half_count >= timer_half: timer_half_count = 0.0
		adaptive_fps()
		if bench_start == 1 && bench_start_batch == 0: benchmark()
		if bench_start_batch == 1:
			if bench_start == 3:
				if bench_start_batch_counter <= 3:
					if bench_start_batch_counter == 0:
						get_node("GUI_MID/Scenes")._on_Resolution_Button_item_selected(0)
						get_node("GUI_MID/Scenes")._on_Select_Scene_item_selected(0)
						bench_start = 2
					elif bench_start_batch_counter == 1:
						get_node("GUI_MID/Scenes")._on_Resolution_Button_item_selected(1)
						get_node("GUI_MID/Scenes")._on_Select_Scene_item_selected(0)
						bench_start = 2
					elif bench_start_batch_counter == 2:
						get_node("GUI_MID/Scenes")._on_Resolution_Button_item_selected(1)
						get_node("GUI_MID/Scenes")._on_Select_Scene_item_selected(1)
						bench_start = 2
					elif bench_start_batch_counter == 3:
						get_node("GUI_MID/Scenes")._on_Resolution_Button_item_selected(0)
						get_node("GUI_MID/Scenes")._on_Select_Scene_item_selected(1)
						bench_start = 2
					bench_start_batch_counter += 1
					get_node("GUI_MID/Scenes")._on_Settings_Apply_pressed()
					get_node("GUI_MID/Scenes")._on_Scene_Load_pressed()
				else: benchmark_batch_reset("stop_batch")
			
			if bench_start_batch == 1:
				benchmark()
		
		update_gui_up()

func update_gui_up():
	get_node("GUI_UP/fps").set_text("Core fps: "+str(round(process_fixed_fps))+" fps: "+str(round(process_fps)))
	get_node("GUI_UP/benchmark").set_text(bench_strange_flag+"Result: "+str(bench_result))

func fps_monitor_process(delta):
	process_timer += delta;
	process_count += 1
	if process_timer >= 1.0:
		process_fps = process_count / process_timer
		process_timer = 0.0
		process_count = 0.0

func fps_monitor_fixed_process(delta):
	process_fixed_timer += delta
	process_fixed_count += 1.0
	if process_fixed_timer >= 1.0:
		process_fixed_fps = process_fixed_count / process_fixed_timer
		process_fixed_timer = 0.0
		process_fixed_count = 0.0

func adaptive_fps():
	if process_fps < process_fixed_target_fps_low_bound:
		if process_fixed_target_fps > process_fixed_target_fps_low_bound || process_fixed_target_fps == 0:
			process_fixed_target_fps = process_fixed_target_fps_low
			OS.set_iterations_per_second(process_fixed_target_fps)
	elif process_fps > process_fixed_target_fps_low_bound:
		process_fixed_target_fps = process_fixed_target_fps_def
		OS.set_iterations_per_second(process_fixed_target_fps)

func benchmark():
	bench_warm += 1
	bench_result = "Wait..."
	if bench_warm >= bench_warm_time:
		if bench_fps_start_collected == 0:
			bench_fps_start = round(process_fps)
			bench_fps_start_collected = 1
		bench_result = "Testing..."
		bench += process_fps
		bench_count += 1
		if bench_count >= bench_period:
			bench_result = round(bench / bench_period)
			if bench_result > 2000:
				if (bench_fps_start+300.0) < bench_result || (bench_fps_start-300.0) > bench_result:
					bench_strange_flag = ".!. "
			elif bench_result > 200:
				if (bench_fps_start+80.0) < bench_result || (bench_fps_start-80.0) > bench_result:
					bench_strange_flag = ".!. "
			elif bench_result > 20:
				if (bench_fps_start+20.0) < bench_result || (bench_fps_start-20.0) > bench_result:
					bench_strange_flag = ".!. "
			
			if bench_start_batch == 1:
				benchmark_batch_reset(bench_result)
				bench_start = 3
			else:
				benchmark_reset(bench_result)
			
			result_save()
			#get_node("GUI_DOWN/BTN_Benchmark").set_pressed(false)
			#get_node("GUI_DOWN").menu_unblock()

func benchmark_start():
	if bench_start_batch == 1:
		benchmark_batch_reset("stop_batch")
	else:
		if bench_start == 0:
			benchmark_reset("Bench start...")
			bench_start = 1
			process_target_fps = process_target_fps_max
			OS.set_target_fps(process_target_fps)
			get_node("GUI_DOWN").menu_block()
			get_node("GUI_DOWN").menu_close()
		else:
			benchmark_reset("Aborted...")
			get_node("GUI_DOWN").menu_unblock()

func benchmark_start_batch():
	if bench_start == 0:
		benchmark_batch_reset("Batch start...")
		bench_start = 3
		bench_start_batch = 1
		bench_start_batch_counter = 0
		process_target_fps = process_target_fps_max
		OS.set_target_fps(process_target_fps)
		get_node("GUI_DOWN").menu_block()
		get_node("GUI_DOWN").menu_close()
		get_node("GUI_DOWN/BTN_Benchmark").set_pressed(true)
	else:
		benchmark_batch_reset("Batch aborted...")
		get_node("GUI_DOWN").menu_unblock()

func benchmark_reset(reason):
	if bench_start_batch == 1:
		benchmark_batch_reset(reason)
	else:
		bench_start_batch = 0
		bench_start_batch_counter = 0
		bench_result = reason
		bench_start = 0; bench = 0.0; bench_count = 0; bench_warm = 0
		bench_fps_start = 0; bench_fps_start_collected = 0
		if str(reason) == "Aborted..." || str(reason) == "New settings..." || str(reason) == "Bench start...":
			bench_strange_flag = ""
		get_node("GUI_DOWN/BTN_Benchmark").set_pressed(false)
		get_node("GUI_DOWN").menu_unblock()

func benchmark_batch_reset(reason):
	if str(reason) == "Aborted..." || str(reason) == "stop_batch":
		bench_strange_flag = ""
		bench_start_batch = 0
		bench_start_batch_counter = 0
		get_node("GUI_DOWN/BTN_Benchmark").set_pressed(false)
		get_node("GUI_DOWN").menu_unblock()
	
	bench_result = reason
	bench_start = 0; bench = 0.0; bench_count = 0; bench_warm = 0
	bench_fps_start = 0; bench_fps_start_collected = 0

func result_save():
	var tdate = OS.get_date().values()
	var ttime = OS.get_time().values()
	var tDay = str(tdate[1]); var tMonth = str(tdate[2]); var tYear = str(tdate[3])
	var tSec = str(ttime[0]); var tHour = str(ttime[1]); var tMin = str(ttime[2])
	tDay = fix_digit(tDay); tMonth = fix_digit(tMonth); tYear = fix_digit(tYear);
	tSec = fix_digit(tSec); tHour = fix_digit(tHour); tMin = fix_digit(tMin);
	
	if result_file.file_exists(result_file_path):
		result_file_code = result_file.open(result_file_path, File.READ_WRITE)
	else:
		result_file_code = result_file.open(result_file_path, File.WRITE)
		result_file_code = result_file.open(result_file_path, File.READ_WRITE)
	
	if result_file_code == OK:
		result_file.seek_end()
		result_file.store_string("\n")
		result_file.store_string(" "+tYear+"-"+tMonth+"-"+tDay+" - "+tHour+":"+tMin+":"+tSec)
		result_file.store_string(" - "+project_name+" "+project_version+" - "+main_current_os_name)
		result_file.store_string(" - "+main_current_os_kernel_str.replace("\n", "")+"\n")
		result_file.store_string("CPU: "+main_cpu_name_str.replace("\n", "")+"\n")
		result_file.store_string("GPU: "+main_gpu_name_str.replace("\n", "")+" - ("+main_gpu_driver_name_str.replace("\n", "")+")\n")
		#result_file.store_string("GPUs List: "+main_gpu_name_all_str.replace("\n", " : ")+"\n")
		result_file.store_string("Result: "+str(bench_result)+" - "+loaded_scene+" - "+str(main_render_size.x)+"x"+str(main_render_size.y))
		result_file.store_string("\n")
		result_file.close()
	else:
		print("result_file_code: ", result_file_code)
	pass

func fix_digit(digit):
	var fixed = digit
	if digit == "0": fixed = "00"
	elif digit == "1": fixed = "01"
	elif digit == "2": fixed = "02"
	elif digit == "3": fixed = "03"
	elif digit == "4": fixed = "04"
	elif digit == "5": fixed = "05"
	elif digit == "6": fixed = "06"
	elif digit == "7": fixed = "07"
	elif digit == "8": fixed = "08"
	elif digit == "9": fixed = "09"
	return fixed

func on_resize():
	main_render_size = OS.get_video_mode_size()
	main_rd_sizes = str(str(main_render_size.width)+"x"+str(main_render_size.height))+" - "+str(str(main_display_size.width)+"x"+str(main_display_size.height))
	
	benchmark_reset("New settings...")
	update_hw_info_labels()

var all_nodes = [
"GUI_MID",
"GUI_MID/Scenes",
"GUI_MID/Scenes/Settings",
"GUI_MID/Scenes/Settings/Label", "GUI_MID/Scenes/Settings/Resolution",
"GUI_MID/Scenes/Settings/Resolution_Button", "GUI_MID/Scenes/Settings/Settings_Apply",
"GUI_MID/Scenes/List",
"GUI_MID/Scenes/List/Label", "GUI_MID/Scenes/List/Select_Scene", "GUI_MID/Scenes/List/Scene_Load", "GUI_MID/Scenes/List/Description",
"GUI_MID/About",
"GUI_MID/About/Background",
"GUI_MID/About/Icon",
"GUI_MID/About/Project_URL",
"GUI_MID/About/GitHub_URL",
"GUI_MID/About/Blog_URL",
"GUI_MID/About/Developers",
"GUI_MID/About/Lead_Developer",
"GUI_MID/About/Background/Project_Name",
"GUI_MID/About/Background/Project_License",
"GUI_MID/About/Background/Godot_Engine",
"GUI_MID/Reference",
"GUI_MID/Results",
"GUI_MID/Results/Background", "GUI_MID/Results/Select_List_Scene",
"GUI_MID/Results/Select_List", "GUI_MID/Results/ItemList",
"GUI_UP",
"GUI_UP/fps", "GUI_UP/benchmark", "GUI_UP/VGA", "GUI_UP/CPU", "GUI_UP/OS", "GUI_UP/display",
"GUI_DOWN",
"GUI_DOWN/BTN_Exit", "GUI_DOWN/BTN_Scenes", "GUI_DOWN/BTN_About", "GUI_DOWN/BTN_Results",
"GUI_DOWN/BTN_Benchmark", "GUI_DOWN/BTN_Save", "GUI_DOWN/BTN_Reference"
]

func resize_multi(multiplier):
	main_display_size = OS.get_screen_size()
	if window_size_default * multiplier <= main_display_size:
		window_size = window_size_default * multiplier
		OS.set_window_size(window_size)
		OS.set_window_position(main_display_size / 2 - window_size / 2)
		for item in all_nodes:
			if get_node(item).has_method("set_theme"): get_node(item).set_theme(theme_default)
			if get_node(item).has_method("get_size"):
				get_node(item).set_size(get_node(item).get_size() / render_size_multiplier)
			get_node(item).set_pos(get_node(item).get_pos() / render_size_multiplier)
		for item in all_nodes:
			if get_node(item).has_method("set_theme"):
				if multiplier == 2.0: get_node(item).set_theme(theme_default_big)
			if get_node(item).has_method("get_size"):
				get_node(item).set_size(get_node(item).get_size() * multiplier)
			get_node(item).set_pos(get_node(item).get_pos() * multiplier)
		render_size_multiplier = multiplier

