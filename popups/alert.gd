extends Control
@onready var window: Window = $Window
@onready var label: Label = $Window/Label

func _ready() -> void:
	hide()
	window.hide()
	z_index = 10

func make(text:String, title:String = '提示'):
	window.title = title
	label.text = text
	show()
	window.show()
	get_tree().paused = true


func _on_button_cancel_pressed() -> void:
	get_tree().paused = false
	hide()
	window.hide()
	pass # Replace with function body.


func _on_window_close_requested() -> void:
	get_tree().paused = false
	_on_button_cancel_pressed()
	pass # Replace with function body.


func _on_button_ok_pressed() -> void:
	get_tree().paused = false
	_on_button_cancel_pressed()
	pass # Replace with function body.
