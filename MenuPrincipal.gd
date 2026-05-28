extends Control

# ─────────────────────────────────────────────
#  MenuPrincipal.gd
#  Controla el menú principal de El Eternauta
# ─────────────────────────────────────────────

const ESCENA_NIVEL1 := "res://scenes/Nivel1.tscn"

@onready var pantalla_controles : Control      = $PantallaControles
@onready var imagen_controles   : TextureRect  = $PantallaControles/ImagenControles

@onready var btn_start          : TextureButton = $PanelBotones/BtnStart
@onready var btn_controles      : TextureButton = $PanelBotones/BtnControles
@onready var btn_exit           : TextureButton = $PanelBotones/BtnExit
@onready var btn_cerrar         : TextureButton = $PantallaControles/BtnCerrarControles
@onready var boton = $audio_boton

func _ready() -> void:
	_cargar_imagen_controles()

	btn_start.pressed.connect(_on_start_pressed)
	btn_controles.pressed.connect(_on_controles_pressed)
	btn_exit.pressed.connect(_on_exit_pressed)
	btn_cerrar.pressed.connect(_on_cerrar_controles_pressed)
	if not Gamemanager.music_audio.playing:
		Gamemanager.music_audio.play()

# ── Navegación ──────────────────────────────

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://Assets/cine/TypewriterScene.tscn")
	boton.play()

func _on_controles_pressed() -> void:
	pantalla_controles.visible = true
	boton.play()

func _on_cerrar_controles_pressed() -> void:
	pantalla_controles.visible = false
	boton.play()

func _on_exit_pressed() -> void:
	get_tree().quit()
	boton.play()

# ── Helpers ─────────────────────────────────

func _cargar_imagen_controles() -> void:
	var tex : Texture2D = load("res://assets/Controles.png")
	if tex:
		imagen_controles.texture = tex
