extends Area2D

@export var landing_zone : Area2D
@export var lower_zone : Area2D

var body_inside := false
var body_ref : Node2D = null
var enemies_inside : Array = []

var can_use := true


func _on_body_entered(body: Node2D) -> void:

	if !can_use:
		return

	if body.is_in_group("player"):
		body_inside = true
		body_ref = body

	elif body.is_in_group("enemy"):

		if !enemies_inside.has(body):
			enemies_inside.append(body)

		procesar_enemigo(body)


func _on_body_exited(body: Node2D) -> void:

	if body == body_ref:
		body_inside = false
		body_ref = null

	enemies_inside.erase(body)


func _process(delta):

	# PLAYER
	if body_ref != null and !overlaps_body(body_ref):
		body_inside = false
		body_ref = null

	# ENEMIGOS
	for enemy in enemies_inside.duplicate():

		if !overlaps_body(enemy):
			enemies_inside.erase(enemy)
		else:
			procesar_enemigo(enemy)

	if !body_inside or !can_use or !body_ref:
		return

	# SUBIR
	if Input.is_action_just_pressed("teleport"):
		subir(body_ref)

	# BAJAR
	if Input.is_action_just_pressed("bajar"):
		bajar(body_ref)


func procesar_enemigo(body: Node2D):

	if !can_use:
		return

	var player = get_tree().get_first_node_in_group("player")

	if !player:
		return

	if player.global_position.y < body.global_position.y - 50:
		subir(body)

	elif player.global_position.y > body.global_position.y + 50:
		bajar(body)


func subir(body: Node2D):

	if !landing_zone:
		return

	var marker = landing_zone.get_node_or_null("Marker2D")

	if !marker:
		return

	can_use = false

	var pos = marker.global_position

	if body.is_in_group("enemy"):
		pos.x += 24

	body.global_position = pos

	if body is CharacterBody2D:
		body.velocity = Vector2.ZERO

	await get_tree().create_timer(0.3).timeout

	can_use = true


func bajar(body: Node2D):

	if !lower_zone:
		return

	var marker = lower_zone.get_node_or_null("Marker2D")

	if !marker:
		return

	can_use = false

	var pos = marker.global_position

	if body.is_in_group("enemy"):
		pos.x -= 24

	body.global_position = pos

	if body is CharacterBody2D:
		body.velocity = Vector2.ZERO

	await get_tree().create_timer(0.3).timeout

	can_use = true
