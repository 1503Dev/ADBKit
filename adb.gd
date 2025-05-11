extends Node

@onready var bin:String = Utils.get_bin()

var node_command_outputs:CodeEdit

var device:= ''
var prop:= {}
var cpuinfo:= {}
var package_info:= {}

func run(args:Array = []) -> String:
	var rez = Utils.exec_d(bin, args)
	var args_str:= ''
	for arg in args:
		args_str+= ' ' + arg
	if node_command_outputs.text.length() > 5000:
		node_command_outputs.text = ''
	node_command_outputs.text += Utils.get_current_time() + ' > adb' + args_str + '\n' + rez + '\n\n'
	node_command_outputs.set_caret_line(node_command_outputs.text.split('\n').size())
	return rez

func shell(cmd:String, _device:String = device) -> String:
	return run(['-s', _device, 'shell',  cmd])

func adb(args:Array = [], _device:String = device) -> String:
	return run(['-s', _device] + args)
#
#func shell_and_find(cmd:String, find:String, _device:String = device) -> String:
	#return run(['-s', _device, 'shell',  cmd, ''])

func get_devices() -> Array:
	var outp:= run(['devices'])
	if outp == 'List of devices attached': return []
	var split = outp.split('\n')
	var rez:= []
	for device in split:
		if device.ends_with('\tdevice'):
			rez.push_back(device.split('\tdevice')[0])
	return rez

func get_device_model():
	return get_prop_value('ro.product.model')

func get_device_manufacturer():
	return get_prop_value('ro.product.manufacturer')

func get_disk_info()->Dictionary:
	var ori:= Utils.parse_disk_table(shell('df -h /data').replace('Mounted on', 'Mounted_on'))
	var rez:= {}
	for key in ori.keys():
		if key != 'Filesystem':
			rez = ori[key]
	return rez

func get_cpu_arch():
	return get_prop_value('ro.product.cpu.abi')

func shell_getprop(str):
	return shell('getprop ' + str)

func get_android_version_name():
	return get_prop_value('ro.build.version.release')

func get_android_sdk():
	return get_prop_value('ro.build.version.sdk')

func get_fingerprint():
	return get_prop_value('ro.build.fingerprint')

func get_prop()->Dictionary:
	if !prop.has(device):
		prop[device] = Utils.parse_key_value_data(shell('getprop'))
	return prop[device]

func get_prop_value(key):
	return get_prop()[key]

func get_os_version():
	return get_prop_value('ro.build.version.incremental')

func is_miui():
	return get_prop().has('ro.miui.ui.version.name')

func get_lcd_density():
	return get_prop().has('ro.sf.lcd_density')

func get_cpu_model():
	var rez:=  Utils.findstr(get_cpu_info(), 'Hardware').split(':')
	if rez.size() > 1:
		return rez[1].strip_edges()
	rez =  Utils.findstr(get_cpu_info(), 'model name').split(':')
	if rez.size() > 1:
		return rez[1].strip_edges()
	return '未知'

func get_cpu_info():
	if !cpuinfo.has(device):
		cpuinfo[device] = shell('cat /proc/cpuinfo')
	return cpuinfo[device]

func get_apps()->Array:
	var ori:= shell('pm list packages').split('\n')
	var rez:= []
	for package in ori:
		if !package.is_empty():
			var split:= package.split(':')
			if split.size() > 1:
				rez.push_back(split[1])
	return rez

func get_package_info(pkg):
	if !package_info.has(device):
		package_info[device] = {
			pkg: shell('dumpsys package '+pkg)
		}
	elif !package_info[device].has(pkg):
		package_info[device][pkg] = shell('dumpsys package '+pkg)
	return package_info[device][pkg]

func remove_package_info(pkg):
	if package_info.has(device) and package_info[device].has(pkg):
		package_info[device].erase(pkg)

func get_app_version_name(pkg):
	var pkg_info = get_package_info(pkg)
	return Utils.findstr(pkg_info, 'versionName').strip_edges().split('=')[1]

func get_app_version_code(pkg):
	var pkg_info = get_package_info(pkg)
	return Utils.findstr(pkg_info, 'versionCode').strip_edges().split('=')[1].split(' ')[0]

func get_app_apk_path(pkg):
	var rez = shell('pm path ' + pkg)
	if rez.is_empty(): return ''
	return rez.split('package:')[1]

func is_app_system(path:String):
	if path.begins_with('/system') or path.begins_with('/apex'): return true
	return false

func pull(path, local_path):
	return adb(['pull', path, local_path])

func get_ps() -> Array:
	var ori:= shell('ps').split('\n')
	var rez:= []
	for line in ori:
		if (line.contains('.') and !line.contains('[') and !line.contains('@')) or ori[0] == line:
			rez.push_back(line.replace('USER', '用户').replace('RSS', '内存').replace('NAME', '包名'))
	return rez

func force_stop(pkg):
	return shell('am force-stop ' + pkg)

func shell_async(cmd:String, _device:String = device):
	Utils.async_call(func():
		run(['-s', _device, 'shell',  cmd])
	)

func adb_async(args:Array = [], _device:String = device):
	Utils.async_call(func():
		run(['-s', _device] + args)
	)

func press(key):
	shell_async('input keyevent ' + key)

func press_long(key):
	shell_async('input keyevent --longpress ' + key)

func input(text):
	shell_async('input text "' + text + '"')
