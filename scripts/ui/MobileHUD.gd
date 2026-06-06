class_name MobileHUD
extends CanvasLayer

@onready var _joystick: VirtualJoystick = $VirtualJoystick
@onready var _vertical_buttons: VerticalButtons = $VerticalButtons


func _ready() -> void:
	if not OS.has_feature("mobile") and not OS.has_feature("editor"):
		_joystick.hide()
		_vertical_buttons.hide()


func get_movement_vector() -> Vector2:
	return _joystick.get_vector()


func get_vertical_value() -> float:
	return _vertical_buttons.get_vertical_axis()
