extends Area2D

@export var cantidad_balas := 7
@export var score_value := 200

var collected := false

func _ready():

	body_entered.connect(_on_body_entered)


func _on_body_entered(body):

	if collected:
		return

	# Solo el jugador
	if body.is_in_group("player"):

		collected = true

		# Dar balas
		body.reserva_balas += cantidad_balas

		# Actualizar HUD
		body.actualizar_hud()

		# Dar score
		body.add_score(score_value)

		print("Munición recogida")

		# Ocultar visual
		$Sprite2D.visible = false

		# Desactivar colisión
		$CollisionShape2D.disabled = true

		queue_free()
