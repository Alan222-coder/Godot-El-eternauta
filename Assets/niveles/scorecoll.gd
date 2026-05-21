extends Area2D

@export var score_value := 1

var collected := false

func _on_body_entered(body):

	if collected:
		return

	# Solo objetos del grupo "player"
	if body.is_in_group("player"):

		collected = true

		# Sumar score
		body.add_score(score_value)

		# Desaparecer sprite
		$Sprite2D.visible = false

		# Desactivar colisión
		$CollisionShape2D.disabled = true
		print("RESCATADOOOOOOOOOAHUAJIKOA")
