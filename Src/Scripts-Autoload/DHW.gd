extends Label

var info_path = CBXPL.main_execute_path+"/Helpers/Windows-SysInfo.txt"
var script_path = CBXPL.main_execute_path+"/Helpers/Get-Windows-SysInfo.vbs"

func _ready():
	if CBXPL.main_current_os == "Windows":
		gather_system_info_silent()
	pass

func gather_system_info_silent():
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
	'Set out = fso.CreateTextFile("' + info_path.replace("/", "\\") + '", True)',
	
	# 1. ОС и Версия
	'winVerName = shell.RegRead("HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\DisplayVersion")',
	'If winVerName = "" Then winVerName = shell.RegRead("HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\ReleaseId")',
	'For Each o In wmi.ExecQuery("Select Caption,Version,CSDVersion from Win32_OperatingSystem")',
	'  out.WriteLine "OS: " & o.Caption & " [" & winVerName & "] Build " & o.Version & " " & o.CSDVersion',
	'Next',
	
	# 2. ПРОЦЕССОР
	'cpu = ""',
	'cpu = shell.RegRead("HKEY_LOCAL_MACHINE\\HARDWARE\\DESCRIPTION\\System\\CentralProcessor\\0\\ProcessorNameString")',
	'If cpu = "" Then',
	'  For Each o In wmi.ExecQuery("Select Name from Win32_Processor"): cpu = o.Name: Next',
	'End If',
	'out.WriteLine "CPU: " & cpu',
	
	# 3. ВИДЕОКАРТА
	'For Each o In wmi.ExecQuery("Select Name,DriverVersion from Win32_VideoController"): ',
	'  out.WriteLine "GPU: " & o.Name & " [Driver: " & o.DriverVersion & "]": Next',
	'out.Close'
	]
	
	for line in vbs_code:
		f.store_line(line)
	f.close()
	
	# Запускаем через shell_open (ЭТО НЕ ВЫЗЫВАЕТ КОНСОЛЬ)
	OS.shell_open(script_path)
	
	# Ждем немного, пока файл создастся (т.к. запуск фоновый)
	var timer = Timer.new()
	timer.set_wait_time(1.0) # 1 секунды обычно за глаза
	timer.set_one_shot(true)
	timer.connect("timeout", self, "_on_info_ready")
	add_child(timer)
	timer.start()
	
func _on_info_ready():
	var f = File.new()
	if f.file_exists(info_path):
		f.open(info_path, File.READ)
		var result = f.get_as_text()
		f.close()
		get_node("/root/Main/Label").set_text(result)
	
		# Опционально: удаляем временные файлы
		var dir = Directory.new()
		dir.remove(script_path)
		#dir.remove(info_path)
	else:
		print("Ошибка: Файл с данными не найден. Возможно, WMI заблокирован.")
