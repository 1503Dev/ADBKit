extends Node

const DIR_BIN:= 'user://bin/'
const DIR_RES_BIN:= 'res://bin/win64/'

@onready var os:= OS.get_name()

func _ready() -> void:
	if(os != 'Windows'):
		OS.alert('This program can only run on Windows x64

此程序只能运行在 Windows x64 上

このプログラムは Windows x64 でのみ動作します

Este programa solo puede ejecutarse en Windows x64

यह प्रोग्राम केवल Windows x64 पर चल सकता है।', 'Warning')
		get_tree().quit()
	
	print('User dir: ' + OS.get_user_data_dir())
	
	if(DirAccess.dir_exists_absolute(DIR_BIN)):
		var user_bin = DirAccess.open(DIR_BIN)
		var cache_bin_files:= user_bin.get_files()
		for fn in cache_bin_files:
			user_bin.remove(fn)
			print('Removed '+fn)
		print('Cleared cache')
	var res_bin:= DirAccess.open(DIR_RES_BIN)
	var bin_files:= res_bin.get_files()
	DirAccess.open('user://').make_dir('bin')
	for fn in bin_files:
		DirAccess.copy_absolute(DIR_RES_BIN + fn, DIR_BIN + fn)
		print('Copied '+fn)
