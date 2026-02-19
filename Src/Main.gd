extends Node

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

const bench_period = 40 # 40 = 20 seconds if benchmark() run in timer_half mode...
const bench_warm_time = 16

var bench_start = 0; var bench_warm = 0
var bench = 0.0; var bench_count = 0; var bench_result = 0

func _ready():
	set_process(true); set_fixed_process(true)
	OS.set_target_fps(process_target_fps_def)
	OS.set_iterations_per_second(process_fixed_target_fps_def)

func _process(delta):
	fps_monitor_process(delta)

func _fixed_process(delta):
	fps_monitor_fixed_process(delta)
	
	timer_half_count += delta
	if timer_half_count >= timer_half: timer_half_count = 0.0
		adaptive_fps()
		
		if bench_start == 1:
			benchmark()
		
		update_gui()

func update_gui():
	get_node("GUI-UP/Label1").set_text("Fps core: "+str(round(process_fixed_fps))+" Fps: "+str(round(process_fps))+" Result: "+str(bench_result))

func _on_Button_pressed():
	get_tree().quit()

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
		if process_fixed_target_fps > process_fixed_target_fps_low_bound:
			process_fixed_target_fps = process_fixed_target_fps_low
			OS.set_iterations_per_second(process_fixed_target_fps)
	elif process_fps > process_fixed_target_fps_low_bound:
		process_fixed_target_fps = process_fixed_target_fps_def
		OS.set_iterations_per_second(process_fixed_target_fps)

func benchmark():
	bench_warm += 1
	bench_result = "Wait..."
	get_node("Sprites/Sprite 2").set_pos(Vector2(int(rand_range(0,640)),int(rand_range(0,360))))
	if bench_warm >= bench_warm_time:
		bench_result = "Tesing..."
		bench += process_fps
		bench_count += 1
		if bench_count >= bench_period:
			bench_result = round(bench / bench_period)
			bench = 0.0
			bench_count = 0
			bench_start = 0
			bench_warm = 0
			get_node("GUI-DOWN/BTN-Benchmarks").set_pressed(false)

func _on_BTNBenchmarks_pressed():
	if bench_start == 0:
		bench_start = 1
		process_target_fps = process_target_fps_max
		OS.set_target_fps(process_target_fps)
	else:
		bench_result = "Aborted..."
		bench_start = 0
		bench = 0.0
		bench_count = 0
		bench_warm = 0
		process_target_fps = process_target_fps_def
		OS.set_target_fps(process_target_fps)
