extends Node2D

@onready var sprite = $Sprite2D
@onready var collision = $CollisionShape2D
@onready var area = $Area2D
@onready var texto_ui=$"../../../TextEdit"
var player_in_range = false
var is_open = false
var ya_mostro_mensaje=false

func _ready():
	area.body_entered.connect(_on_body_entered)
	area.body_exited.connect(_on_body_exited)
	texto_ui.visible = false

func _process(delta):
	if player_in_range and Input.is_action_just_pressed("interact"):
		toggle_door()

func toggle_door():
	is_open = !is_open

	if is_open:
		# Se vuelve translúcida
		sprite.modulate.a = 0.4
		# Desactiva colisión
		collision.disabled = true
	else:
		# Vuelve a normal
		sprite.modulate.a = 1.0
		
		# Activa colisión
		collision.disabled = false

func _on_body_entered(body):
	if body.is_in_group("player"):
		player_in_range = true
		texto_ui.text = "Apretá la E para abrir la puerta"
		texto_ui.visible = true
		ya_mostro_mensaje = true
func _on_body_exited(body):
	if body.is_in_group("player"):
		player_in_range = false
		ya_mostro_mensaje = true
		texto_ui.visible = false
	#if body.is_in_group("player"):
		#player_in_range = false
		
