class_name VirtualJoystick
extends Control

const DEAD_ZONE: float = 12.0

@onready var _knob: Control = $Knob

var _max_radius: float = 60.0
var _touch_index: int = -1
var _origin: Vector2 = Vector2.ZERO
var _output: Vector2 = Vector2.ZERO


func _ready() -> void:
	await get_tree().process_frame
	_recalc_radius()
	_center_knob()


func get_vector() -> Vector2:
	return _output


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		_recalc_radius()
		_center_knob()


func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		_handle_touch(event)
	elif event is InputEventScreenDrag:
		_handle_drag(event)


func _recalc_radius() -> void:
	_max_radius = min(size.x, size.y) * 0.5 - _knob.size.x * 0.5


func _handle_touch(event: InputEventScreenTouch) -> void:
	if event.pressed and _touch_index == -1 and _is_left_zone(event.position):
		_touch_index = event.index
		_origin = global_position + size * 0.5
		_knob.global_position = _origin - _knob.size * 0.5
	elif not event.pressed and event.index == _touch_index:
		_reset()


func _handle_drag(event: InputEventScreenDrag) -> void:
	if event.index != _touch_index:
		return
	var delta := event.position - _origin
	var clamped := delta.limit_length(_max_radius)
	_knob.global_position = _origin + clamped - _knob.size * 0.5
	_output = clamped / _max_radius if delta.length() > DEAD_ZONE else Vector2.ZERO


func _is_left_zone(pos: Vector2) -> bool:
	return pos.x < get_viewport().get_visible_rect().size.x * 0.5


func _center_knob() -> void:
	_knob.position = (size - _knob.size) * 0.5


func _reset() -> void:
	_touch_index = -1
	_origin = Vector2.ZERO
	_output = Vector2.ZERO
	_center_knob()
