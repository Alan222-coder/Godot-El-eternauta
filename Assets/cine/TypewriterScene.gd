extends Node

@onready var typewriter_label: RichTextLabel = $UI/MarginContainer/PanelContainer/VBoxContainer/TypewriterLabel
@onready var continue_button: Button = $UI/MarginContainer/PanelContainer/VBoxContainer/ContinueButton
@onready var click_hint: Label = $UI/ClickHint
@onready var ui_layer: CanvasLayer = $UI

@export var next_scene_path: String = "res://Assets/niveles reales/NIVEL 1 cambio de mapa .tscn"

const DOUBLE_CLICK_TIME: float = 0.35
var _last_click_time: float = -999.0
var _typing_done: bool = false
var _fade_rect: ColorRect

func _ready() -> void:
	# Crear el FadeRect por código, sin necesidad de agregarlo en la escena
	_fade_rect = ColorRect.new()
	_fade_rect.color = Color(0, 0, 0, 0)
	_fade_rect.anchors_preset = Control.PRESET_FULL_RECT
	_fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui_layer.add_child(_fade_rect)

	continue_button.hide()
	continue_button.pressed.connect(_on_continue_pressed)
	typewriter_label.typing_finished.connect(_on_typing_finished)
	typewriter_label.start_typing()

func _input(event: InputEvent) -> void:
	if _typing_done:
		return
	if event is InputEventMouseButton \
			and event.button_index == MOUSE_BUTTON_LEFT \
			and event.pressed:
		var now := Time.get_ticks_msec() / 1000.0
		if now - _last_click_time <= DOUBLE_CLICK_TIME:
			typewriter_label.skip_to_end()
			click_hint.hide()
			_last_click_time = -999.0
		else:
			_last_click_time = now

func _on_typing_finished() -> void:
	_typing_done = true
	click_hint.hide()
	continue_button.modulate.a = 0.0
	continue_button.show()
	var tween := create_tween()
	tween.tween_property(continue_button, "modulate:a", 1.0, 0.6).set_ease(Tween.EASE_OUT)

func _on_continue_pressed() -> void:
	var tween := create_tween()
	tween.tween_property(_fade_rect, "color:a", 1.0, 0.4)
	await tween.finished
	get_tree().change_scene_to_file(next_scene_path)
