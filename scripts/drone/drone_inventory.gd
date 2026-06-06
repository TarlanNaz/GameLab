class_name DroneInventory
extends Node

const DEFAULT_CAPACITY: int = 5

signal inventory_changed(current: int, capacity: int)

@export var capacity: int = DEFAULT_CAPACITY

var _current_count: int = 0

func is_full() -> bool:
	return _current_count >= capacity

func can_collect() -> bool:
	return not is_full()

func add_core() -> void:
	if is_full():
		push_warning("DroneInventory: attempt to add core when full")
		return
	_current_count += 1
	inventory_changed.emit(_current_count, capacity)

func unload_all() -> int:
	var count := _current_count
	_current_count = 0
	inventory_changed.emit(_current_count, capacity)
	return count

func get_current_count() -> int:
	return _current_count
