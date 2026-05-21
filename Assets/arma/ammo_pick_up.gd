extends Node2D

@export var cantidad_balas := 7


func _on_area_2d_body_entered(body):

	if body.is_in_group("player"):

		body.reserva_balas += cantidad_balas

		body.score += 200

		body.actualizar_hud()

		queue_free()
