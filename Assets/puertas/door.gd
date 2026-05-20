extends Node2D

@onready var sprite = $Sprite2D
@onready var collision = $CollisionShape2D
@onready var area = $Area2D

var player_in_range = false
var is_open = false

func _ready():
	area.body_entered.connect(_on_body_entered)
	area.body_exited.connect(_on_body_exited)

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

func _on_body_exited(body):
	if body.is_in_group("player"):
		player_in_range = false
