extends Node3D

const MUSIC_START_POSITION: float = 3.0

@onready var _hud: HUD = $Hud
@onready var _base: Base = $Base
@onready var _drone_inventory: DroneInventory = $Drone/DroneInventory
@onready var _music_player: AudioStreamPlayer = $MusicPlayer


func _ready() -> void:
	_drone_inventory.inventory_changed.connect(_hud.update_inventory)
	_base.delivery_completed.connect(_hud.show_reward)
	_music_player.finished.connect(_on_music_finished)
	_music_player.play(MUSIC_START_POSITION)


func _on_music_finished() -> void:
	_music_player.play(MUSIC_START_POSITION)
