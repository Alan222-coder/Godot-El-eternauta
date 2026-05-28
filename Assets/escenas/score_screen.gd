# ScoreScreen.gd
extends Node

## Escena a la que irá el botón "Continuar"
@export var siguiente_escena: PackedScene

@onready var score_value: Label = $CenterContainer/PanelContainer/VBoxContainer/ScoreSection/ScoreValue
@onready var continue_button: Button = $CenterContainer/PanelContainer/VBoxContainer/ContinueButton


func _ready() -> void:

	continue_button.pressed.connect(_on_continue_pressed)

	_mostrar_score()


func _mostrar_score() -> void:

	if get_tree().has_meta("score"):

		score_value.text = str(get_tree().get_meta("score"))

	else:

		score_value.text = "0"


func _on_continue_pressed() -> void:

	if siguiente_escena:

		get_tree().change_scene_to_packed(siguiente_escena)

	else:

		push_warning("ScoreScreen: 'siguiente_escena' no está asignada.")
