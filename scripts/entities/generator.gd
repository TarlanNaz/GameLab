class_name Generator
extends StaticBody3D

@export var core_scene: PackedScene
@export var spawn_interval: float = 15.0

var _active_core: EnergyCore = null
var _spawn_timer: float = 0.0

@onready var _spawn_point: Marker3D = $SpawnPoint

func _ready() -> void:
	_spawn_core()

func _process(delta: float) -> void:
	if _active_core != null:
		return
	_spawn_timer += delta
	if _spawn_timer >= spawn_interval:
		_spawn_timer = 0.0
		_spawn_core()

func _spawn_core() -> void:
	if core_scene == null:
		push_error("Generator: core_scene is not set")
		return
	var core := core_scene.instantiate() as EnergyCore
	_spawn_point.add_child(core)
	var world_scale := global_transform.basis.get_scale()
	core.scale = Vector3.ONE / world_scale
	core.collected.connect(_on_core_collected)
	_active_core = core

func _on_core_collected() -> void:
	_active_core = null
	_spawn_timer = 0.0
