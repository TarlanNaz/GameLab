class_name HUD
extends CanvasLayer

const REWARD_DISPLAY_DURATION: float = 2.0

@onready var _cargo_label: Label = $MarginContainer/StatusPanel/VBox/CargoRow/CargoLabel
@onready var _cargo_bar: ProgressBar = $MarginContainer/StatusPanel/VBox/CargoBar
@onready var _coins_label: Label = $MarginContainer/StatusPanel/VBox/CoinsLabel
@onready var _reward_panel: PanelContainer = $RewardToast
@onready var _reward_label: Label = $RewardToast/MarginContainer/RewardLabel

var _reward_timer: float = 0.0
var _showing_reward: bool = false


func _ready() -> void:
	GameData.coins_changed.connect(_on_coins_changed)
	_reward_panel.visible = false
	_update_status(0, 5)


func _process(delta: float) -> void:
	if not _showing_reward:
		return
	_reward_timer += delta
	if _reward_timer >= REWARD_DISPLAY_DURATION:
		_reward_panel.visible = false
		_showing_reward = false


func show_reward(amount: int) -> void:
	_reward_label.text = "+%d монет" % amount
	_reward_panel.visible = true
	_reward_timer = 0.0
	_showing_reward = true


func update_inventory(current: int, capacity: int) -> void:
	_update_status(current, capacity)


func _on_coins_changed(amount: int) -> void:
	_coins_label.text = "Монеты: %d" % amount


func _update_status(current: int, capacity: int) -> void:
	_cargo_label.text = "Ядра: %d / %d" % [current, capacity]
	_cargo_bar.max_value = capacity
	_cargo_bar.value = current
	_coins_label.text = "Монеты: %d" % GameData.coins
