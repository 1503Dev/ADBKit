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

var is_ready := false
var is_first_refresh_apps:= true

func _process(delta: float) -> void:
	if is_selected():
		Adb.device = item_list_devices.get_item_text(item_list_devices.get_selected_items()[0])
		color_rect_no_device.hide()
	else:
		color_rect_no_device.show()
		tab_container.current_tab = 0

func _ready() -> void:
	init_menu()
	Adb.node_command_outputs = command_outputs
	refresh_devices_list()
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
				Adb.run(['connect', value.strip_edges()])
			)
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
	pass # Replace with function body.
