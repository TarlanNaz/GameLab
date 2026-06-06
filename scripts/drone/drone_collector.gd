class_name DroneCollector
extends Area3D

@onready var _inventory = $"../DroneInventory"


func _ready() -> void:
	area_entered.connect(_on_area_entered)


func _on_area_entered(area: Node3D) -> void:
	if area is EnergyCore:
		_try_collect(area)


func _try_collect(core: EnergyCore) -> void:
	if not core.is_ready_to_collect():
		return
	if not _inventory.can_collect():
		return
	_inventory.add_core()
	core.collect()
