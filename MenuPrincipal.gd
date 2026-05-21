extends Control

# ─────────────────────────────────────────────
#  MenuPrincipal.gd
#  Controla el menú principal de El Eternauta
# ─────────────────────────────────────────────

const ESCENA_NIVEL1 := "res://scenes/Nivel1.tscn"

@onready var pantalla_controles : Control  = $PantallaControles
@onready var imagen_controles   : TextureRect = $PantallaControles/ImagenControles

@onready var btn_start          : Button = $PanelBotones/BtnStart
@onready var btn_controles      : Button = $PanelBotones/BtnControles
@onready var btn_exit           : Button = $PanelBotones/BtnExit
@onready var btn_cerrar         : Button = $PantallaControles/BtnCerrarControles


func _ready() -> void:
	_aplicar_estilo_botones()
	_cargar_imagen_controles()

	btn_start.pressed.connect(_on_start_pressed)
	btn_controles.pressed.connect(_on_controles_pressed)
	btn_exit.pressed.connect(_on_exit_pressed)
	btn_cerrar.pressed.connect(_on_cerrar_controles_pressed)


# ── Navegación ──────────────────────────────

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://Assets/niveles reales/NIVEL 1.tscn")


func _on_controles_pressed() -> void:
	pantalla_controles.visible = true


func _on_cerrar_controles_pressed() -> void:
	pantalla_controles.visible = false


func _on_exit_pressed() -> void:
	get_tree().quit()


# ── Helpers ─────────────────────────────────

func _cargar_imagen_controles() -> void:
	var tex : Texture2D = load("res://assets/Controles.png")
	if tex:
		imagen_controles.texture = tex


func _aplicar_estilo_botones() -> void:
	# Estilo oscuro coherente con la estética del juego
	var normal   := StyleBoxFlat.new()
	var hover    := StyleBoxFlat.new()
	var pressed  := StyleBoxFlat.new()

	normal.bg_color   = Color(0.05, 0.05, 0.10, 0.88)
	normal.border_color = Color(0.55, 0.10, 0.80, 1.0)   # violeta
	normal.set_border_width_all(2)
	normal.set_corner_radius_all(6)

	hover.bg_color    = Color(0.18, 0.05, 0.28, 0.95)
	hover.border_color  = Color(0.80, 0.30, 1.00, 1.0)
	hover.set_border_width_all(2)
	hover.set_corner_radius_all(6)

	pressed.bg_color  = Color(0.30, 0.00, 0.45, 1.0)
	pressed.border_color = Color(1.0, 0.60, 1.0, 1.0)
	pressed.set_border_width_all(2)
	pressed.set_corner_radius_all(6)

	for btn in [btn_start, btn_controles, btn_exit]:
		btn.add_theme_stylebox_override("normal",  normal)
		btn.add_theme_stylebox_override("hover",   hover)
		btn.add_theme_stylebox_override("pressed", pressed)
		btn.add_theme_color_override("font_color",          Color.WHITE)
		btn.add_theme_color_override("font_hover_color",    Color(0.95, 0.75, 1.0))
		btn.add_theme_color_override("font_pressed_color",  Color.WHITE)

	# Botón "Volver" con estilo más sutil
	var v_normal := StyleBoxFlat.new()
	v_normal.bg_color    = Color(0.12, 0.12, 0.12, 0.90)
	v_normal.border_color = Color(0.70, 0.70, 0.70, 1.0)
	v_normal.set_border_width_all(2)
	v_normal.set_corner_radius_all(6)

	btn_cerrar.add_theme_stylebox_override("normal", v_normal)
	btn_cerrar.add_theme_color_override("font_color", Color.WHITE)
