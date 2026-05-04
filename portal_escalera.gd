extends Area2D

@export var landing_zone : Area2D
@export var lower_zone : Area2D

var body_inside := false
var body_ref : Node2D = null

static var position_stack : Array = []
var can_use := true   # ❗ sacamos static

func _on_body_entered(body: Node2D) -> void:
	if !can_use:
		return

	if body.is_in_group("player"):
		body_inside = true
		body_ref = body

	elif body.is_in_group("enemy"):
		procesar_enemigo(body)

func _on_body_exited(body: Node2D) -> void:
	if body == body_ref:
		body_inside = false
		body_ref = null

func _process(delta):
	if !body_inside or !can_use or !body_ref:
		return

	if body_ref.is_in_group("player"):
		if Input.is_action_just_pressed("teleport"):
			subir(body_ref)

		if position_stack.size() > 0 and Input.is_action_just_pressed("bajar"):
			bajar()

# 🔥 NUEVO (centralizamos lógica enemigo)
func procesar_enemigo(body: Node2D):
	var player = get_tree().get_first_node_in_group("player")
	if !player:
		return

	if player.global_position.y < body.global_position.y - 50:
		subir(body)
	elif player.global_position.y > body.global_position.y + 50:
		bajar_enemigo(body)

# 🔼 SUBIR
func subir(body: Node2D):
	if !landing_zone:
		return

	var marker = landing_zone.get_node_or_null("Marker2D")
	if !marker:
		return

	can_use = false

	if body.is_in_group("player"):
		if position_stack.is_empty() or position_stack.back() != body.global_position:
			position_stack.push_back(body.global_position)

	var pos = marker.global_position

	if body.is_in_group("enemy"):
		pos.x += 24

	body.global_position = pos

	if body is CharacterBody2D:
		body.velocity = Vector2.ZERO

	body_inside = false
	body_ref = null

	# 🔥 FIX CLAVE → PORTAL 2
	if body.is_in_group("enemy"):
		await get_tree().process_frame
		procesar_enemigo(body)

	await get_tree().create_timer(0.3).timeout
	can_use = true

# 🔽 PLAYER
func bajar():
	var player = get_tree().get_first_node_in_group("player")
	if !player:
		return

	can_use = false

	var last_pos = position_stack.pop_back()
	player.global_position = last_pos

	if player is CharacterBody2D:
		player.velocity = Vector2.ZERO

	await get_tree().create_timer(0.3).timeout
	can_use = true

# 🔽 ENEMIGO
func bajar_enemigo(body: Node2D):
	if !lower_zone:
		return

	var marker = lower_zone.get_node_or_null("Marker2D")
	if !marker:
		return

	can_use = false

	var pos = marker.global_position
	pos.x -= 24

	body.global_position = pos

	if body is CharacterBody2D:
		body.velocity = Vector2.ZERO

	body_inside = false
	body_ref = null

	# 🔥 MISMO FIX
	await get_tree().process_frame
	procesar_enemigo(body)

	await get_tree().create_timer(0.3).timeout
	can_use = true
