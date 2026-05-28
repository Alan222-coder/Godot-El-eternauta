extends Area2D

@export var next_scene := "res://Assets/niveles reales/Nivel 3 cambio de mapa.tscn"

func _on_body_entered(body):

	if body.is_in_group("player"):

		if body.completable:

			get_tree().change_scene_to_file(next_scene)
