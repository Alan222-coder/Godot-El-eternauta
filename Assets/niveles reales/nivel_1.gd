extends Node2D
@export var enemigo_scene : PackedScene

var evento_activado := false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func spawn_enemigos():

	print("FUNCION SPAWN")

	var enemigo = enemigo_scene.instantiate()

	print("ENEMIGO CREADO")

	enemigo.modulate = Color.RED
	enemigo.scale = Vector2(3,3)
	enemigo.z_index = 100
	add_child(enemigo)

	print("ENEMIGO AGREGADO")
