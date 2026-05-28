extends Node

@onready var typewriter_label: RichTextLabel = $UI/MarginContainer/PanelContainer/VBoxContainer/TypewriterLabel
@onready var continue_button: Button = $UI/MarginContainer/PanelContainer/VBoxContainer/ContinueButton
@onready var click_hint: Label = $UI/ClickHint
@onready var ui_layer: CanvasLayer = $UI

@export var next_scene_path: String = "res://Assets/niveles reales/NIVEL 1 cambio de mapa .tscn"
@export var music: AudioStream = preload("res://Assets/All-dialogues-with-guests-in-the-house-No_-I_m-not-a-Human.mp3")
## Volumen en decibeles. 0 = 100%, -10 = ~30%, -20 = ~10%, -80 = silencio
@export_range(-80, 0.0, 0.5) var volume_db: float = 10.0

const DOUBLE_CLICK_TIME: float = 0.35
var _last_click_time: float = -999.0
var _typing_done: bool = false
var _fade_rect: ColorRect
var _audio: AudioStreamPlayer

func _ready() -> void:
	Gamemanager.music_audio.stop()
	_fade_rect = ColorRect.new()
	_fade_rect.color = Color(0, 0, 0, 0)
	_fade_rect.anchors_preset = Control.PRESET_FULL_RECT
	_fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui_layer.add_child(_fade_rect)

	_audio = AudioStreamPlayer.new()
	_audio.stream = music
	_audio.volume_db = volume_db
	add_child(_audio)
	if _audio.stream is AudioStreamMP3:
		(_audio.stream as AudioStreamMP3).loop = true
	elif _audio.stream is AudioStreamOggVorbis:
		(_audio.stream as AudioStreamOggVorbis).loop = true
	elif _audio.stream is AudioStreamWAV:
		(_audio.stream as AudioStreamWAV).loop_mode = AudioStreamWAV.LOOP_FORWARD
	_audio.play()

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
	Gamemanager.music_audio.play()
	_audio.stop()
	var tween := create_tween()
	tween.tween_property(_fade_rect, "color:a", 1.0, 0.4)
	await tween.finished
	get_tree().change_scene_to_file(next_scene_path)
