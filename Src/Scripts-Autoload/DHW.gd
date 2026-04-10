extends Node

var os_type = OS.get_name()

var os_name = ""
var os_kernel = "kernel"
var cpu_name = ""
var gpu_name = ""
var wine_detect = ""

var info_path = CBXPL.main_execute_path+"\\Helpers\\Windows-SysInfo.txt"
var script_path = CBXPL.main_execute_path+"\\Helpers\\Get-Windows-SysInfo.vbs"
var vga_exe_path = CBXPL.main_execute_path+"\\Helpers\\Windows-GPU-Info.exe"

var windows_helper = CBXPL.main_execute_path+"\\Helpers\\Windows-HW-Info.bat"
var linux_helper = CBXPL.main_execute_path+"/Helpers/Linux-Helper.sh"

var try_count = 0

func _ready():
	get_hw_info()

func get_hw_info():
	var output = []
	
	if os_type == "Windows":
		os_name = "Windows"
		OS.execute(windows_helper, [], true, output)
	elif os_type == "X11":
		os_name = "Linux"
		var temp_kernel = []
		OS.execute("uname", ["-r"], true, temp_kernel)
		os_kernel = str(temp_kernel[0]).replace("\n", "")
		OS.execute("/bin/bash", [linux_helper], true, output)
	
	if output.size() > 0:
		var lines = output[0].split("\n")
		if lines.size() >= 1: wine_detect = lines[0].strip_edges()
		if lines.size() >= 2: os_name     = lines[1].strip_edges()
		if lines.size() >= 3: cpu_name    = lines[2].strip_edges()
		if lines.size() >= 4: gpu_name    = lines[3].strip_edges()
	
	if wine_detect == "WINE":
		os_name = "WINE"
	
	get_node("/root/Main").update_hw_info_labels()

func get_hw_info_old():
	cpu_name[0] = "not detected"
	gpu_name[0] = "not detected"
	var current_os_name_arr = [""]
	var gpu_driver_name = [""]
	if CBXPL.current_os_type == "Windows":
		CBXPL.current_os_name = "Windows"
		OS.execute("cmd", ["/c", "ver"], true, CBXPL.current_os_kernel)
		#OS.execute("cmd", ["/c", "reg query HKLM\\HARDWARE\\DEVICEMAP\\VIDEO /v \\Device\\Video0"], true, gpu_driver_name)
		OS.execute(CBXPL.main_execute_path+"\\Helpers\\Wine-Detect.bat", [""], true, wine_detect)
		OS.execute(CBXPL.main_execute_path+"\\Helpers\\Windows-CPU-Info.bat", [""], true, cpu_name)
		OS.execute(CBXPL.main_execute_path+"\\Helpers\\Windows-GPU-Info.exe", [""], true, gpu_name)
	elif CBXPL.current_os_type == "X11":
		OS.execute("uname", ["-r"], true, CBXPL.current_os_kernel)
		CBXPL.current_os_name = "Linux"
		OS.execute("bash", ["-c", "lspci -k | grep -A 3 -E '(VGA|3D)' | grep 'in use' | cut -d ':' -f2 | tr -d ' '"], true, gpu_driver_name)
		OS.execute(CBXPL.main_execute_path+"/Helpers/Linux-OS-Name.sh", [""], true, CBXPL.current_os_name_arr)
		if CBXPL.current_os_name_arr[0] != "":
			CBXPL.current_os_name = str(CBXPL.current_os_name_arr[0]).replace("\n", "")
		OS.execute("bash", ["-c", "cat /proc/cpuinfo | grep 'model name' | head -n1 | cut -d: -f2 | sed 's/^[ \t]*//'"], true, cpu_name)
		OS.execute("bash", ["-c", "lspci | grep -iE 'vga|3d|display' | cut -d':' -f3 | sed 's/^ //'"], true, gpu_name)
		if gpu_name[0] == "":
			OS.execute("bash", ["-c", "cat /sys/class/drm/card*/device/uevent | grep PCI_ID | cut -d'=' -f2"], true, gpu_name)
	
	CBXPL.current_os_kernel_str = str(CBXPL.current_os_kernel[0])
	
	#for item in range(gpu_name.size()):
	#	gpu_name_all_str = str(gpu_name[item])
	
	var wine_detect_regex = RegEx.new()
	wine_detect_regex.compile("WINE")
	var result = wine_detect_regex.find(str(wine_detect[0]))
	
	if result == 0: CBXPL.current_os_name = "Windows (WINE)"

func gather_system_info_silent_NOT_FULL():
	# Создаем скрипт (VBScript)
	var f = File.new()
	var err = f.open(script_path, File.WRITE)
	if err != OK: return
	
	# Скрипт
	var vbs_code = [
	'On Error Resume Next',
	'Set wmi = GetObject("winmgmts:\\\\.\\root\\cimv2")',
	'Set shell = CreateObject("WScript.Shell")',
	'Set fso = CreateObject("Scripting.FileSystemObject")',
	'Set out = fso.CreateTextFile("' + info_path + '", True)',
	
	# 1. ОС и Версия
	'winVerName = shell.RegRead("HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\DisplayVersion")',
	'If winVerName = "" Then winVerName = shell.RegRead("HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\ReleaseId")',
	'For Each o In wmi.ExecQuery("Select Caption,Version,CSDVersion from Win32_OperatingSystem")',
	'  out.WriteLine o.Caption & " " & winVerName & " " & o.CSDVersion',
	'  out.WriteLine o.Version & " "',
	'Next',
	
	# 2. ПРОЦЕССОР
	'cpu = ""',
	'cpu = shell.RegRead("HKEY_LOCAL_MACHINE\\HARDWARE\\DESCRIPTION\\System\\CentralProcessor\\0\\ProcessorNameString")',
	'If cpu = "" Then',
	'  For Each o In wmi.ExecQuery("Select Name from Win32_Processor"): cpu = o.Name: Next',
	'End If',
	'out.WriteLine cpu',
	
	# 3. ВИДЕОКАРТА
	'GpuString = ""',
	'For Each o In wmi.ExecQuery("Select Name,DriverVersion from Win32_VideoController"): ',
	'  GpuString = o.Name & " " & o.DriverVersion & " | " & GpuString',
	'Next',
	'out.WriteLine GpuString',
	
	'GpuStringT = ""',
	'exePath = "' + vga_exe_path + '"',
	'tempFile = shell.ExpandEnvironmentStrings("%TEMP%") & "\\gpu_data.tmp"',
	'shell.Run "cmd /c """ & exePath & """ > """ & tempFile & """", 0, True',
	'GpuStringT = ""',
	'If fso.FileExists(tempFile) Then',
	'  Set f = fso.OpenTextFile(tempFile, 1)',
	'  If Not f.AtEndOfStream Then',
	'    GpuStringT = f.ReadAll',
	'  End If',
	'  fso.DeleteFile(tempFile)',
	'End If',
	'out.WriteLine GpuStringT & " - " & exePath',
	
	# X. WINE DETECTION
	'retVal = objReg.EnumKey(HKEY_CURRENT_USER, "Software\\Wine", arrSubKeys)',
	'If retVal = 0 Then',
	'  out.WriteLine "WINE"',
	'Else',
	'  out.WriteLine "Real"',
	'End If',
	'out.Close'
	]
	
	for line in vbs_code:
		f.store_line(line)
	f.close()
	
	# Запускаем через shell_open (ЭТО НЕ ВЫЗЫВАЕТ КОНСОЛЬ)
	OS.shell_open(script_path)
	
	# Ждем немного, пока файл создастся (т.к. запуск фоновый)
	var timer = Timer.new()
	timer.set_wait_time(1) # 1 секунды обычно за глаза
	timer.set_one_shot(true)
	timer.connect("timeout", self, "_on_info_ready")
	add_child(timer)
	timer.start()
	
func _on_info_ready():
	var FileWithInfo = File.new()
	if FileWithInfo.file_exists(info_path):
		if FileWithInfo.open(info_path, File.READ) == OK:
			#var result = FileWithInfo.get_as_text()
			#FileWithInfo.close()
			#get_node("/root/Main/Label").set_text(result)
			
			os_name = str(FileWithInfo.get_line())
			cpu_name = str(FileWithInfo.get_line())
			gpu_name = str(FileWithInfo.get_line())
			
			get_node("/root/Main").update_hw_info_labels()
			
			FileWithInfo.close()
		else:
			print("Error opening file: "+str(FileWithInfo))
	
		# Опционально: удаляем временные файлы
		var dir = Directory.new()
		dir.remove(script_path)
		#dir.remove(info_path)
	else:
		if try_count < 8:
			var timer = Timer.new()
			timer.set_wait_time(1) # 1 секунды обычно за глаза
			timer.set_one_shot(true)
			timer.connect("timeout", self, "_on_info_ready")
			add_child(timer)
			timer.start()
		print("File not found: "+info_path+". Try: "+str(try_count))
		try_count += 1
