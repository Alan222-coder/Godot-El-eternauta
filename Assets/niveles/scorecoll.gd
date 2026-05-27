extends Area2D

@export var score_value := 600

var collected := false

func _on_body_entered(body):

	if collected:
		return

	# Solo objetos del grupo "player"
	if body.is_in_group("player"):

		collected = true

		# Sumar score
		body.sumar_score(score_value)
		body.set_completable()

		# Desaparecer sprite
		$Sprite2D.visible = false

		# Desactivar colisión
		$CollisionShape2D.disabled = true
