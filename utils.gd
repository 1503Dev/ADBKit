extends Node

func exec(path: String, args:Array = []) -> Dictionary:
	var output = []
	var exit_code = OS.execute(path, args, output, true)
	var output_str:= ''
	for outp:String in output:
		output_str += outp.replace('\r\n','\n').replace('\\r\\n','\n').replace('\r','\n').replace('\\r','\n') + '\n'
	output_str = output_str.strip_edges()
	
	print('=== START OF COMMAND ===\n'+'> '+path+' '+str(args)+'\n'+output_str+'\n=== END OF COMMAND ===\n')
	return {
		'output': output_str,
		'exit_code': exit_code
	}

func exec_d(path: String, args:Array = []) -> String:
	return exec(path, args).output

func get_bin():
	return OS.get_user_data_dir() + '/bin/adb.exe'

func get_current_time() -> String:
	var time_dict = Time.get_time_dict_from_system()
	var milliseconds = Time.get_ticks_msec() % 1000
	
	return "%02d:%02d:%02d.%03d" % [
		time_dict.hour,
		time_dict.minute,
		time_dict.second,
		milliseconds
	]

func get_item_list_index(il:ItemList, str:String):
	for i in il.item_count:
		if (il.get_item_text(i) == str): return i
	return -1
	
func open_cmd_in_directory(path: String):
	var command: String
	var args: PackedStringArray = []
	
	if OS.get_name() == "Windows":
		command = "cmd.exe"
		args = ["/k", "cd", "/d", path.replace("/", "\\")]
	else:
		command = "gnome-terminal"  # 或根据系统使用其他终端
		args = ["--working-directory=%s" % path]
	
	var success := OS.create_process(command, args)
	if not success:
		printerr("无法创建终端进程")
		
func generate_uuid_v4() -> String:
	randomize()  # 初始化随机数生成器
	
	var uuid = ""
	for i in range(0, 32):
		var hex_digit = randi() % 16
		if i == 12:  # 设置版本号(4)
			hex_digit = 4
		elif i == 16:  # 设置变体(8,9,A,B)
			hex_digit = (randi() % 4) + 8
		
		uuid += "%x" % hex_digit
		
		# 添加分隔符
		if i in [7, 11, 15, 19]:
			uuid += "-"
	
	return uuid

var async_callback1

func async_call(func_to_call: Callable, callback:Callable = func():, args: Array = []) -> void:
	async_callback1 = async_callback1
	var thread = Thread.new()
	thread.start(func():
		# 在子线程中执行
		var result = func_to_call.callv(args)
		# 将结果传回主线程
		call_deferred("async_callback1", result)
		thread.wait_to_finish()
	)

func parse_disk_table(table_text: String) -> Dictionary:
	var result = {}
	var lines = table_text.split("\n", false)
	
	for line in lines:
		if line.strip_edges().is_empty():
			continue
		
		# 智能分割：合并连续空格，保留路径中的空格
		var parts = []
		var current_part = ""
		var in_space = false
		
		for c in line:
			if c == " ":
				if not in_space and current_part:
					parts.append(current_part)
					current_part = ""
				in_space = true
			else:
				current_part += c
				in_space = false
		
		if current_part:
			parts.append(current_part)
		
		# 标准格式校验（6列）
		if parts.size() == 6:
			result[parts[0]] = {
				"Filesystem": parts[0],
				"Size": parts[1],
				"Used": parts[2],
				"Avail": parts[3],
				"Use%": parts[4],
				"Mounted_on": parts[5]
			}
	
	return result

func parse_key_value_data(data: String) -> Dictionary:
	var result = {}
	var lines = data.split("\n", false)
	
	for line in lines:
		line = line.strip_edges()
		if line.is_empty():
			continue
		
		# 提取键值对
		var parts = line.split("]: [", false)
		if parts.size() != 2:
			continue
			
		var key = parts[0].substr(1)  # 去掉开头的"["
		var value = parts[1].substr(0, parts[1].length() - 1)  # 去掉结尾的"]"
		
		result[key] = value
	
	return result

func remove_extra_spaces(text: String) -> String:
	var result := ""
	var in_space := false
	
	for c in text:
		if c == " ":
			if not in_space:  # 如果是第一个空格，保留
				result += " "
				in_space = true
		else:
			result += c
			in_space = false
	
	return result

func findstr(text: String, pattern: String, case_sensitive: bool = true) -> String:
	var results := PackedStringArray()
	var lines := text.split("\n", false)
	
	for line in lines:
		if case_sensitive:
			if pattern in line:
				results.append(line)
		else:
			if pattern.to_lower() in line.to_lower():
				results.append(line)
	if results.size() > 0:
		return results[0]
	return ''
