extends Node2D

var velocidad := 40.0

func setup(texto):

	$Texto.text = texto

func _process(delta):

	position.y -= velocidad * delta

	modulate.a -= delta

	if modulate.a <= 0:

		queue_free()
