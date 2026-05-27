extends Area2D

@export var cantidad_balas := 7
@export var score_value := 200
@onready var audio_pickup = $"../AudioPickUp"
var collected := false

func _ready():

	body_entered.connect(_on_body_entered)


func _on_body_entered(body):

	if body.is_in_group("player"):

		Gamemanager.reserva_balas += cantidad_balas

		body.sumar_score(200)

		body.actualizar_hud()
		print("Intentando spawn")
		get_tree().current_scene.spawn_enemigos()
		audio_pickup.play()

		get_parent().get_node("Sprite2D").visible = false

		monitoring = false

		await audio_pickup.finished

		queue_free()
