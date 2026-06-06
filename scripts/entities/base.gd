class_name Base
extends Area3D


const DELIVERY_DURATION: float = 3.0

var _is_delivering: bool = false
var _delivery_timer: float = 0.0
var _inventory: DroneInventory = null

signal delivery_completed(earned_coins: int)


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _process(delta: float) -> void:
	if not _is_delivering:
		return
	_delivery_timer += delta
	if _delivery_timer >= DELIVERY_DURATION:
		_complete_delivery()


# — Private —

func _on_body_entered(body: Node3D) -> void:
	if not body is CharacterBody3D:
		return
	var inv := body.get_node_or_null("DroneInventory") as DroneInventory
	if inv == null or inv.get_current_count() == 0:
		return
	_inventory = inv
	_is_delivering = true
	_delivery_timer = 0.0


func _on_body_exited(body: Node3D) -> void:
	if not body is CharacterBody3D:
		return
	var inv := body.get_node_or_null("DroneInventory") as DroneInventory
	if inv == null or inv != _inventory:
		return
	_is_delivering = false
	_delivery_timer = 0.0
	_inventory = null


func _complete_delivery() -> void:
	_is_delivering = false
	_delivery_timer = 0.0
	if _inventory == null:
		return
	var count := _inventory.unload_all()
	_inventory = null
	if count == 0:
		return
	var earned := count * GameData.CORE_VALUE
	GameData.add_coins(earned)
	delivery_completed.emit(earned)
