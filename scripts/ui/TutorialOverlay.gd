class_name TutorialOverlay
extends CanvasLayer

const LOCK_SECONDS: float = 5.0
const FADE_DURATION: float = 0.4

@onready var _panel: PanelContainer = $Panel
@onready var _hints_container: VBoxContainer = $Panel/VBox/HintsContainer
@onready var _footer: Label = $Panel/VBox/Footer
@onready var _timer: Timer = $Timer

var _is_closing: bool = false
var _can_close: bool = false


func _ready() -> void:
	if not GameData.is_first_launch:
		queue_free()
		return

	_populate_hints()
	_timer.wait_time = LOCK_SECONDS
	_timer.start()


func _process(_delta: float) -> void:
	if _is_closing or _can_close:
		return
	var remaining := ceili(_timer.time_left)
	_footer.text = "Нажмите куда угодно через %d с" % remaining


func _input(event: InputEvent) -> void:
	if not _can_close or _is_closing:
		return
	var is_tap: bool = event is InputEventMouseButton and event.pressed
	var is_touch: bool = event is InputEventScreenTouch and event.pressed
	if is_tap or is_touch:
		_close()


# — Private —

func _populate_hints() -> void:
	var is_mobile: bool = OS.has_feature("mobile") or OS.has_feature("editor")
	var hints: Array[String]
	if is_mobile:
		hints = [
			"Левый джойстик — перемещение дрона",
			"Свайп правой стороны — поворот камеры",
			"Кнопка ▲ — дрон летит вверх",
			"Кнопка ▼ — дрон летит вниз",
		]
	else:
		hints = [
			"WASD — перемещение",
			"Мышь — поворот камеры (курсор захвачен)",
			"Escape — отпустить курсор",
			"Клик — вернуть захват курсора",
			"Пробел — дрон летит вверх",
			"Shift — дрон летит вниз",
		]
	hints.append("Собирай энергетические ядра с генераторов")
	hints.append("Доставляй их на базу")

	for text in hints:
		var label := Label.new()
		label.text = "• " + text
		label.add_theme_color_override("font_color", Color.WHITE)
		_hints_container.add_child(label)


func _close() -> void:
	if _is_closing:
		return
	_is_closing = true
	GameData.is_first_launch = false
	GameData.save()
	var tween := create_tween()
	tween.tween_property(_panel, "modulate:a", 0.0, FADE_DURATION)
	await tween.finished
	queue_free()


func _on_timer_timeout() -> void:
	_can_close = true
	_footer.text = "Нажмите куда угодно, чтобы закрыть"
