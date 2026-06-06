class_name DroneMovement
extends CharacterBody3D


const MOVE_SPEED: float = 10.0
const VERTICAL_SPEED: float = 6.0
const ACCELERATION: float = 6.0
const DECELERATION: float = 4.0
const MOUSE_SENSITIVITY: float = 0.003
const PITCH_LIMIT: float = 0.15
const TILT_AMOUNT: float = 0.3
const TILT_SPEED: float = 6.0
const SCREEN_HALF_RATIO: float = 0.5
const MOBILE_CAM_SENSITIVITY: float = 0.003

@export var move_speed: float = MOVE_SPEED
@export var vertical_speed: float = VERTICAL_SPEED
@export var acceleration: float = ACCELERATION
@export var deceleration: float = DECELERATION
@export var mouse_sensitivity: float = MOUSE_SENSITIVITY

@onready var _camera_pivot: Node3D = $CameraPivot
@onready var _drone_mesh: Node3D = $DroneMesh

var _yaw: float = 0.0
var _pitch: float = 0.0
var _mobile_hud: MobileHUD


func _ready() -> void:
	if OS.has_feature("mobile") or OS.has_feature("editor"):
		_mobile_hud = get_parent().get_node_or_null("MobileHUD") as MobileHUD
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _input(event: InputEvent) -> void:
	_handle_touch_look(event)
	if OS.has_feature("mobile"):
		return
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		_handle_mouse_look(event.relative)
	elif event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	elif event is InputEventMouseButton and event.pressed and Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _physics_process(delta: float) -> void:
	_handle_movement(delta)
	_apply_visual_tilt(delta)


# — Private —

func _handle_mouse_look(relative: Vector2) -> void:
	_yaw -= relative.x * mouse_sensitivity
	_pitch = clamp(_pitch - relative.y * mouse_sensitivity, -PITCH_LIMIT, PITCH_LIMIT)
	rotation.y = _yaw
	_camera_pivot.rotation.x = _pitch


func _handle_touch_look(event: InputEvent) -> void:
	if not OS.has_feature("mobile"):
		return
	if not event is InputEventScreenDrag:
		return
	var vp_width := get_viewport().get_visible_rect().size.x
	if event.position.x > vp_width * SCREEN_HALF_RATIO:
		_yaw -= event.relative.x * MOBILE_CAM_SENSITIVITY
		_pitch = clamp(_pitch - event.relative.y * MOBILE_CAM_SENSITIVITY, -PITCH_LIMIT, PITCH_LIMIT)
		rotation.y = _yaw
		_camera_pivot.rotation.x = _pitch


func _handle_movement(delta: float) -> void:
	var wish := _get_wish_velocity()
	var factor := acceleration if wish != Vector3.ZERO else deceleration
	velocity = velocity.lerp(wish, factor * delta)
	move_and_slide()


func _get_wish_velocity() -> Vector3:
	var forward := Vector3(-sin(_yaw), 0.0, -cos(_yaw))
	var right   := Vector3( cos(_yaw), 0.0, -sin(_yaw))

	var dir := _get_input_direction()

	var wish := forward * (-dir.z) + right * dir.x
	wish.x *= move_speed
	wish.z *= move_speed
	wish.y  = dir.y * vertical_speed

	return wish


func _get_input_direction() -> Vector3:
	var kb := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var kb_vertical := Input.get_axis("move_down", "move_up")
	if _mobile_hud:
		var joy := _mobile_hud.get_movement_vector()
		var h := joy if joy != Vector2.ZERO else kb
		var v := _mobile_hud.get_vertical_value()
		return Vector3(h.x, v if v != 0.0 else kb_vertical, h.y)
	return Vector3(kb.x, kb_vertical, kb.y)


func _apply_visual_tilt(delta: float) -> void:
	var local_vel := _drone_mesh.global_transform.basis.inverse() * velocity
	var target := Vector3(
		-local_vel.z / move_speed * TILT_AMOUNT,
		0.0,
		-local_vel.x / move_speed * TILT_AMOUNT
	)
	_drone_mesh.rotation = _drone_mesh.rotation.lerp(target, TILT_SPEED * delta)
