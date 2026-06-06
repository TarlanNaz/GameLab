class_name EnergyCore
extends Area3D

enum ChargeStage { STAGE_1, STAGE_2, STAGE_3 }

const CHARGE_TIME_PER_STAGE: float = 5.0
const PUSH_FORCE: float = 4.0

const STAGE_COLORS: Array[Color] = [
	Color(1, 0, 0, 1),
	Color(1, 1, 0, 1),
	Color(0, 0.5019608, 0, 1),
]
const STAGE_EMISSION_ENERGIES: Array[float] = [0.0, 1.0, 3.0]

signal collected

var _current_stage: ChargeStage = ChargeStage.STAGE_1
var _charge_timer: float = 0.0
var _is_ready: bool = false
var _drones_in_range: Array[DroneCollector] = []

@onready var _mesh: MeshInstance3D = $MeshInstance3D

func _ready() -> void:
	var mat := StandardMaterial3D.new()
	mat.emission_enabled = true
	_mesh.set_surface_override_material(0, mat)
	_apply_stage_visuals()
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)
	
func _process(delta: float) -> void:
	_handle_charging(delta)
	_handle_push()

func _handle_charging(delta: float) -> void:
	if _is_ready:
		return
	_charge_timer += delta
	if _charge_timer >= CHARGE_TIME_PER_STAGE:
		_charge_timer = 0.0
		_advance_stage()
		
func is_ready_to_collect() -> bool:
	return _is_ready

func collect() -> void:
	collected.emit()
	queue_free()

func _advance_stage() -> void:
	match _current_stage:
		ChargeStage.STAGE_1:
			_current_stage = ChargeStage.STAGE_2
		ChargeStage.STAGE_2:
			_current_stage = ChargeStage.STAGE_3
			_is_ready = true
	_apply_stage_visuals()

func _apply_stage_visuals() -> void:
	var idx: int = int(_current_stage)
	var mat := _mesh.get_surface_override_material(0) as StandardMaterial3D
	mat.albedo_color = STAGE_COLORS[idx]
	mat.emission = STAGE_COLORS[idx]
	mat.emission_energy_multiplier = STAGE_EMISSION_ENERGIES[idx]

func _handle_push() -> void:
	if _is_ready:
		return
	for collector in _drones_in_range:
		_push_drone(collector)

func _on_area_entered(area: Node3D) -> void:
	if area is DroneCollector:
		_drones_in_range.append(area)

func _on_area_exited(area: Node3D) -> void:
	if area is DroneCollector:
		_drones_in_range.erase(area)

func _push_drone(collector: DroneCollector) -> void:
	var drone := collector.get_parent() as DroneMovement
	if drone == null:
		return
	var direction := (drone.global_position - global_position).normalized()
	drone.velocity += direction * PUSH_FORCE
