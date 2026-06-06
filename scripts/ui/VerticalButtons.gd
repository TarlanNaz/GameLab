class_name VerticalButtons
extends Control

var _up_pressed: bool = false
var _down_pressed: bool = false


func _ready() -> void:
	var up_btn: BaseButton = $Panel/VBox/UpWrap/UpButton
	var down_btn: BaseButton = $Panel/VBox/DownWrap/DownButton
	up_btn.button_down.connect(func() -> void: _up_pressed = true)
	up_btn.button_up.connect(func() -> void: _up_pressed = false)
	down_btn.button_down.connect(func() -> void: _down_pressed = true)
	down_btn.button_up.connect(func() -> void: _down_pressed = false)


func get_vertical_axis() -> float:
	if _up_pressed:
		return 1.0
	if _down_pressed:
		return -1.0
	return 0.0
