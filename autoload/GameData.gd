extends Node

const CORE_VALUE: int = 50
const SAVE_PATH: String = "user://gamedata.cfg"
const SAVE_SECTION: String = "game"

var coins: int = 0
var is_first_launch: bool = true

signal coins_changed(new_amount: int)


func _ready() -> void:
	load_data()


func add_coins(amount: int) -> void:
	coins += amount
	coins_changed.emit(coins)
	save()


func save() -> void:
	var config := ConfigFile.new()
	config.set_value(SAVE_SECTION, "is_first_launch", is_first_launch)
	config.set_value(SAVE_SECTION, "coins", coins)
	config.save(SAVE_PATH)


func load_data() -> void:
	var config := ConfigFile.new()
	if config.load(SAVE_PATH) != OK:
		return
	is_first_launch = config.get_value(SAVE_SECTION, "is_first_launch", true)
	coins = config.get_value(SAVE_SECTION, "coins", 0)
	coins_changed.emit(coins)
