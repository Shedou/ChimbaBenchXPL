extends Node

const timer_half = 0.5; var timer_half_check = 0.0

var bench = 0.0; var bench_count = 0; var bench_result = 0

var fps_process; var fps_fixed_process
var fpsmon_p_fps = 0.0; var fpsmon_p_timer = 0.0; var fpsmon_p_count = 0
var fpsmon_fp_fps = 0.0; var fpsmon_fp_timer = 0.0; var fpsmon_fp_count = 0

var rn1; var rn2; var rn3
var fps = 0; var timer = 0.0; var frames_count = 0

func _ready():
	set_process(true); set_fixed_process(true)
	#Globals.set("debug/force_fps", 120)
	#Globals.set("physics/fixed_fps", 120)

func _process(delta):
	fps_monitor_process(delta)

func _fixed_process(delta):
	fps_monitor_fixed_process(delta)
	timer_half_check += delta
	if timer_half_check >= timer_half:
		timer_half_check = 0.0
		get_node("GUI/Label1").set_text("fps: "+str(fps_process)+"\nfps fixed: "+str(fps_fixed_process))
		get_node("GUI/Label2").set_text("bench: "+str(bench)+"\nbench result: "+str(bench_result))

func _on_Button_pressed():
	rn1 = int(rand_range(0,640)); rn2 = int(rand_range(0,360))
	get_node("GUI/Label").set_text("X: "+str(rn1)+" Y: "+str(rn2))
	get_node("GUI/Sprite 2").set_pos(Vector2(rn1,rn2))

func fps_monitor_process(delta):
	fpsmon_p_timer += delta; fpsmon_p_count += 1
	if fpsmon_p_timer >= 1.0:
		fps_process = fpsmon_p_count / fpsmon_p_timer
		fpsmon_p_timer = 0.0; fpsmon_p_count = 0
		
		bench += fps_process
		bench_count += 1
		if bench_count >= 5:
			bench_result = bench / 5
			bench = 0.0
			bench_count = 0

func fps_monitor_fixed_process(delta):
	fpsmon_fp_timer += delta; fpsmon_fp_count += 1
	if fpsmon_fp_timer >= 1.0:
		fps_fixed_process = fpsmon_fp_count / fpsmon_fp_timer
		fpsmon_fp_timer = 0.0; fpsmon_fp_count = 0