extends Control
@onready var command_outputs: CodeEdit = $CommandOutputs
@onready var item_list_devices: ItemList = $ItemList_Devices
@onready var timer_refresh_devices: Timer = $Timers/Timer_RefreshDevices
@onready var menu_bar: MenuBar = $MenuBar
@onready var label_device_name: Label = $Tabs/TabContainer/仪表板/Label_For_DeviceName/Label_DeviceName
@onready var color_rect_no_device: ColorRect = $Tabs/ColorRect_NoDevice
@onready var label_disk_info: Label = $Tabs/TabContainer/仪表板/Label_For_DiskInfo/Label_DiskInfo
@onready var progress_bar_disk_space: ProgressBar = $Tabs/TabContainer/仪表板/Label_For_DiskInfo/ProgressBar_DiskSpace
@onready var label_cpu_arch: Label = $Tabs/TabContainer/仪表板/Label_For_CPUArch/Label_CPUArch
@onready var label_android_version: Label = $Tabs/TabContainer/仪表板/Label_For_AndroidVersion/Label_AndroidVersion
@onready var label_build_fingerprint: Label = $Tabs/TabContainer/仪表板/Label_For_BuildFingerprint/Label_BuildFingerprint
@onready var label_os_version: Label = $Tabs/TabContainer/仪表板/Label_For_OSVersion/Label_OSVersion
@onready var label_screen_info: Label = $Tabs/TabContainer/仪表板/Label_For_ScreenInfo/Label_ScreenInfo
@onready var label_for_os_version: Label = $Tabs/TabContainer/仪表板/Label_For_OSVersion
@onready var label_cpu_model: Label = $Tabs/TabContainer/仪表板/Label_For_CPUModel/Label_CPUModel
@onready var code_edit_shell: CodeEdit = $Tabs/TabContainer/控制台/CodeEdit_Shell
@onready var line_edit_shell: LineEdit = $Tabs/TabContainer/控制台/LineEdit_Shell
@onready var item_list_apps: ItemList = $Tabs/TabContainer/软件管理/ItemList_Apps
@onready var tab_container: TabContainer = $Tabs/TabContainer
@onready var line_edit_package: LineEdit = $Tabs/TabContainer/软件管理/LineEdit_Package
@onready var label_app_version: Label = $Tabs/TabContainer/软件管理/Label_For_AppVersion/Label_AppVersion
@onready var color_rect_no_app: ColorRect = $Tabs/TabContainer/软件管理/ColorRect_NoApp
@onready var label_no_app: Label = $Tabs/TabContainer/软件管理/ColorRect_NoApp/Label_NoApp
@onready var label_apk_path: Label = $Tabs/TabContainer/软件管理/Label_ApkPath
@onready var timer_delay_refresh_devices: Timer = $Timers/Timer_DelayRefreshDevices
@onready var h_flow_container_app_manager: HFlowContainer = $Tabs/TabContainer/软件管理/HFlowContainer_AppManager
@onready var label_package: Label = $Tabs/TabContainer/软件管理/Label_Package
@onready var file_dialog_dir_download_app: FileDialog = $Popups/FileDialog_Dir_DownloadApp
@onready var file_dialog_dir_install_app: FileDialog = $Popups/FileDialog_Dir_InstallApp
@onready var code_edit_ps: CodeEdit = $Tabs/TabContainer/进程/CodeEdit_PS
@onready var line_edit_input_text: LineEdit = $Tabs/TabContainer/输入/LineEdit_InputText
@onready var text_edit_input_key: TextEdit = $Tabs/TabContainer/输入/Label_For_InputKey/TextEdit_InputKey

var is_ready := false
var is_first_refresh_apps:= true
var is_first_refresh_ps:= true
var cur_package:= ''
var cur_apk_path:= ''

func _process(delta: float) -> void:
	if is_selected():
		Adb.device = item_list_devices.get_item_text(item_list_devices.get_selected_items()[0])
		color_rect_no_device.hide()
	else:
		color_rect_no_device.show()
		tab_container.current_tab = 0
		is_first_refresh_ps = true

func _ready() -> void:
	init_menu()
	Adb.node_command_outputs = command_outputs
	refresh_devices_list()
	color_rect_no_app.show()
	h_flow_container_app_manager.hide()
	command_outputs.clear()
	is_ready=true
	
func refresh_device_static_info():
	label_device_name.text = Adb.get_device_manufacturer() + ' ' + Adb.get_device_model()
	var disk_info:= Adb.get_disk_info()
	label_disk_info.text = disk_info['Filesystem'] + ' (' + disk_info['Mounted_on'] + ')' + ' ' + disk_info['Used'] + '/' + disk_info['Size'] + ' ' + disk_info['Use%']
	progress_bar_disk_space.value = int(disk_info['Use%'].replace('%',''))
	label_cpu_arch.text = Adb.get_cpu_arch()
	label_android_version.text = 'Android ' + Adb.get_android_version_name() + ' (' + Adb.get_android_sdk() + ')'
	label_build_fingerprint.text = Adb.get_fingerprint()
	label_os_version.text = Adb.get_os_version()
	label_cpu_model.text = Adb.get_cpu_model()
	if Adb.is_miui():
		label_for_os_version.text = 'MIUI'
	else:
		label_for_os_version.text = '系统版本'

func init_menu():
	menu_bar.set_menu_title(0, '  选项  ')
	
func refresh_devices_list():
	var devices:= Adb.get_devices()
	var selecteds = item_list_devices.get_selected_items()
	var selected:= ''
	if selecteds.size() > 0:
		selected = item_list_devices.get_item_text(selecteds[0])
	item_list_devices.clear()
	for device in devices:
		item_list_devices.add_item(device)
	item_list_devices.select(Utils.get_item_list_index(item_list_devices, selected))


func _on_timer_refresh_devices_timeout() -> void:
	refresh_devices_list()
	pass # Replace with function body.


func _on_button_connect_device_pressed() -> void:
	Prompt.make('连接设备', func(value:String):
		if value.strip_edges() != '':
			Utils.async_call(func():
				Adb.run(['connect', value.strip_edges().replace('：',':').replace('。','.')])
			)
			timer_delay_refresh_devices.start()
	, '输入 IP:端口')
	pass # Replace with function body.

func get_device() -> String:
	if is_selected():
		Adb.device = item_list_devices.get_item_text(item_list_devices.get_selected_items()[0])
		return item_list_devices.get_item_text(item_list_devices.get_selected_items()[0])
	return ''

func is_selected() -> bool:
	return item_list_devices.is_anything_selected()


func _on_button_test_pressed() -> void:
	pass # Replace with function body.


func _on_menu_选项_index_pressed(index: int) -> void:
	if index == 0:
		var path = OS.get_cache_dir() + '/' + Utils.generate_uuid_v4() + '.html'
		DirAccess.copy_absolute('res://html/about.html', path)
		OS.shell_open('file://' + path)
	pass # Replace with function body.


func _on_item_list_devices_item_selected(index: int) -> void:
	if index != -1:
		Adb.device = item_list_devices.get_item_text(item_list_devices.get_selected_items()[0])
		refresh_device_static_info()
		color_rect_no_device.hide()
		code_edit_shell.clear()
		is_first_refresh_apps = true
		tab_container.current_tab = 0
	else:
		color_rect_no_device.show()
	pass # Replace with function body.


func _on_button_refresh_devices_pressed() -> void:
	refresh_devices_list()
	pass # Replace with function body.


func _on_line_edit_shell_text_submitted(new_text: String) -> void:
	var rez = Adb.shell(new_text)
	line_edit_shell.clear()
	code_edit_shell.text += Utils.get_current_time() + ' > adb shell ' + new_text + '\n' + rez + '\n\n'
	code_edit_shell.set_caret_line(code_edit_shell.text.split('\n').size())
	pass # Replace with function body.


func _on_item_list_apps_item_selected(index: int) -> void:
	if index != -1:
		line_edit_package.text = item_list_apps.get_item_text(index)
		load_app_info()
	pass # Replace with function body.


func _on_button_refresh_apps_pressed() -> void:
	refresh_apps_list()
	pass # Replace with function body.

func refresh_apps_list():
	is_first_refresh_apps = false
	var apps:= Adb.get_apps()
	var selecteds = item_list_apps.get_selected_items()
	var selected:= ''
	if selecteds.size() > 0:
		selected = item_list_apps.get_item_text(selecteds[0])
	item_list_apps.clear()
	for app in apps:
		item_list_apps.add_item(app)
	item_list_apps.select(Utils.get_item_list_index(item_list_apps, selected))


func _on_tab_container_tab_changed(tab: int) -> void:
	if !is_ready: return
	if tab == 1 && is_first_refresh_apps:
		refresh_apps_list()
	if tab == 2 && is_first_refresh_ps:
		refresh_ps()
	pass # Replace with function body.

func load_app_info(pkg = line_edit_package.text):
	pkg = pkg.strip_edges()
	line_edit_package.text = line_edit_package.text.strip_edges()
	cur_package = pkg
	label_package.text = cur_package
	if pkg.is_empty():
		color_rect_no_app.show()
		h_flow_container_app_manager.hide()
		label_no_app.text = '请选择一个软件'
		return
	var apk_path = Adb.get_app_apk_path(pkg)
	cur_apk_path = apk_path
	if apk_path.is_empty():
		color_rect_no_app.show()
		h_flow_container_app_manager.hide()
		label_no_app.text = '应用未安装'
		return
	color_rect_no_app.hide()
	h_flow_container_app_manager.show()
	label_app_version.text = Adb.get_app_version_name(pkg) + ' (' + Adb.get_app_version_code(pkg) + ')'
	label_apk_path.text = apk_path


func _on_line_edit_package_text_submitted(new_text: String) -> void:
	load_app_info()
	pass # Replace with function body.


func _on_button_uninstall_app_pressed() -> void:
	if cur_package.to_lower().strip_edges() == 'android':
		Alert.make('禁止卸载 Framework')
		return
	var text = '是否卸载 ' + cur_package
	if Adb.is_app_system(cur_apk_path):
		text = cur_package + ' 为系统应用，是否卸载'
	Confirm.make(text, func():
		var rez = Adb.adb(['uninstall', '--user', '0', cur_package])
		if rez == 'Success':
			Alert.make('卸载成功')
		else:
			Alert.make(rez, '卸载失败')
		Adb.remove_package_info(cur_package)
		load_app_info(cur_package)
		refresh_apps_list()
	)
	pass # Replace with function body.


func _on_timer_delay_refresh_devices_timeout() -> void:
	refresh_devices_list()
	pass # Replace with function body.


func _on_button_keep_uninstall_app_2_pressed() -> void:
	if cur_package.to_lower().strip_edges() == 'android':
		Alert.make('禁止卸载 Framework')
		return
	var text = '是否卸载 ' + cur_package + ' 并保留数据，请谨慎选择'
	if Adb.is_app_system(cur_apk_path):
		text = cur_package + ' 为系统应用，是否卸载' + '并保留数据，请谨慎选择'
	Confirm.make(text, func():
		var rez = Adb.shell('cmd package uninstall -k ' + cur_package)
		if rez == 'Success':
			Alert.make('卸载成功')
		else:
			Alert.make(rez, '卸载失败')
		Adb.remove_package_info(cur_package)
		load_app_info(cur_package)
		refresh_apps_list()
	)
	pass # Replace with function body.


func _on_button_disable_app_pressed() -> void:
	if cur_package.to_lower().strip_edges() == 'android':
		Alert.make('禁止禁用 Framework')
		return
	var rez = Adb.shell('pm disable-user ' + cur_package)
	Alert.make('部分系统软件被禁用后重启会变砖，如有需要请及时恢复\n'+rez, '禁用成功')
	pass # Replace with function body.


func _on_button_enable_app_pressed() -> void:
	var rez = Adb.shell('pm enable ' + cur_package)
	Alert.make(rez, '启用成功')
	pass # Replace with function body.


func _on_button_launch_app_pressed() -> void:
	var rez:= Adb.shell('monkey -p ' + cur_package + ' -c android.intent.category.LAUNCHER 1')
	if rez.contains('monkey aborted'):
		var split:= rez.split('\n')
		var reson:= split[split.size() - 1]
		if reson.contains('No activities'): reson = '找不到启动活动'
		Alert.make(reson, '启动失败')
	pass # Replace with function body.


func _on_button_download_app_pressed() -> void:
	file_dialog_dir_download_app.popup()
	pass # Replace with function body.


func _on_file_dialog_dir_download_app_dir_selected(dir: String) -> void:
	var apk_name:= cur_apk_path.split('/')[cur_apk_path.split('/').size() - 1]
	if FileAccess.file_exists(dir + '/' + apk_name):
		Alert.make('文件 ' + apk_name + ' 已存在')
	else:
		Adb.pull(cur_apk_path, dir)
	pass # Replace with function body.


func _on_button_install_app_pressed() -> void:
	file_dialog_dir_install_app.popup()
	pass # Replace with function body.

func _on_file_dialog_dir_install_app_file_selected(path: String) -> void:
	var rez:= Adb.adb(['install', path])
	if rez.contains('Success'):
		Alert.make('安装成功')
	else:
		Alert.make(rez, '安装结果')
	pass # Replace with function body.


func _on_button_force_stop_app_pressed() -> void:
	var text = '是否终止 ' + cur_package
	Confirm.make(text, func():
		Adb.force_stop(cur_package)
	)
	pass # Replace with function body.

func refresh_ps():
	is_first_refresh_ps = false
	code_edit_ps.text = '\n'.join(Adb.get_ps())


func _on_button_refresh_ps_pressed() -> void:
	refresh_ps()
	pass # Replace with function body.


func _on_texture_button_back_pressed() -> void:
	if is_selected():
		Adb.press('KEYCODE_BACK')
	pass # Replace with function body.


func _on_texture_button_home_pressed() -> void:
	if is_selected():
		Adb.press('KEYCODE_HOME')
	pass # Replace with function body.


func _on_texture_button_app_switch_pressed() -> void:
	if is_selected():
		Adb.press('KEYCODE_APP_SWITCH')
	pass # Replace with function body.


func _on_texture_button_menu_pressed() -> void:
	if is_selected():
		Adb.press('KEYCODE_MENU')
	pass # Replace with function body.


func _on_texture_button_power_pressed() -> void:
	if is_selected():
		Adb.press('KEYCODE_POWER')
	pass # Replace with function body.


func _on_texture_button_back_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and is_selected():
		if event.button_index == MOUSE_BUTTON_RIGHT and event.is_released():
			Adb.press_long('KEYCODE_BACK')
			accept_event()
	pass # Replace with function body.


func _on_texture_button_home_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and is_selected():
		if event.button_index == MOUSE_BUTTON_RIGHT and event.is_released():
			Adb.press_long('KEYCODE_HOME')
			accept_event()
	pass # Replace with function body.


func _on_texture_button_app_switch_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and is_selected():
		if event.button_index == MOUSE_BUTTON_RIGHT and event.is_released():
			Adb.press_long('KEYCODE_APP_SWITCH')
			accept_event()
	pass # Replace with function body.


func _on_texture_button_menu_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and is_selected():
		if event.button_index == MOUSE_BUTTON_RIGHT and event.is_released():
			Adb.press_long('KEYCODE_MENU')
			accept_event()
	pass # Replace with function body.


func _on_texture_button_power_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and is_selected():
		if event.button_index == MOUSE_BUTTON_RIGHT and event.is_released():
			Adb.press_long('KEYCODE_POWER')
			accept_event()
	pass # Replace with function body.


func _on_line_edit_input_text_text_submitted(new_text: String) -> void:
	Adb.input(new_text)
	line_edit_input_text.clear()
	pass # Replace with function body.


func _on_text_edit_input_key_text_changed() -> void:
	Adb.input(text_edit_input_key.text)
	text_edit_input_key.clear()
	pass # Replace with function body.


func _on_text_edit_input_key_gui_input(event: InputEvent) -> void:
	if event is InputEventKey and is_selected():
		var is_accept_event:= true
		if event.keycode == KEY_BACKSPACE and event.is_pressed():
			Adb.press('KEYCODE_DEL')
		elif event.keycode == KEY_ENTER and event.is_pressed():
			Adb.press('KEYCODE_ENTER')
		elif event.keycode == KEY_SHIFT and event.is_released():
			Adb.press('KEYCODE_SHIFT_LEFT')
		elif event.keycode == KEY_SPACE and event.is_pressed():
			Adb.press('KEYCODE_SPACE')
		else: is_accept_event = false
		if is_accept_event: accept_event()
	pass # Replace with function body.


func _on_button_reboot_to_fastboot_pressed() -> void:
	Adb.adb_async(['reboot', 'bootloader'])
	pass # Replace with function body.


func _on_button_reboot_to_recovery_pressed() -> void:
	Adb.adb_async(['reboot', 'recovery'])
	pass # Replace with function body.

func _on_button_reboot_to_fastboot_2_pressed() -> void:
	Adb.adb_async(['reboot'])
	pass # Replace with function body.


func _on_button_screenshot_pressed() -> void:
	Input.set_default_cursor_shape(Input.CURSOR_BUSY)
	var uuid:= Utils.generate_uuid_v4()
	var path:= '/sdcard/adbkit_screenshot_' + uuid + '.png'
	Adb.shell('screencap -p ' + path)
	Adb.pull(path, OS.get_cache_dir())
	Adb.shell('rm ' + path)
	OS.shell_open(OS.get_cache_dir() + '/adbkit_screenshot_' + uuid + '.png')
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)
	pass # Replace with function body.
