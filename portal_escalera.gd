extends Area2D
@export var landing_zone : Area2D
@export var lower_zone : Area2D
var body_inside := false
var body_ref : Node2D = null
var enemies_inside : Array = []          # ✅ lista de enemigos dentro
static var position_stack : Array = []
var can_use := true

func _on_body_entered(body: Node2D) -> void:
	if !can_use:
		return
	if body.is_in_group("player"):
		body_inside = true
		body_ref = body
	elif body.is_in_group("enemy"):
		if !enemies_inside.has(body):
			enemies_inside.append(body)   # ✅ registrar enemigo
		procesar_enemigo(body)

func _on_body_exited(body: Node2D) -> void:
	if body == body_ref:
		body_inside = false
		body_ref = null
	enemies_inside.erase(body)            # ✅ quitar enemigo si sale físicamente

func _process(delta):
	# Verificación cada frame para el jugador
	if body_ref != null and !overlaps_body(body_ref):
		body_inside = false
		body_ref = null

	# ✅ Verificación cada frame para cada enemigo
	for enemy in enemies_inside.duplicate():
		if !overlaps_body(enemy):
			enemies_inside.erase(enemy)
		else:
			procesar_enemigo(enemy)

	if !body_inside or !can_use or !body_ref:
		return

	if body_ref.is_in_group("player"):
		if Input.is_action_just_pressed("teleport"):
			subir(body_ref)
		if position_stack.size() > 0 and Input.is_action_just_pressed("bajar"):
			bajar()

func procesar_enemigo(body: Node2D):
	if !can_use:
		return                            # ✅ respetar can_use
	var player = get_tree().get_first_node_in_group("player")
	if !player:
		return
	if player.global_position.y < body.global_position.y - 50:
		subir(body)
	elif player.global_position.y > body.global_position.y + 50:
		bajar_enemigo(body)

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
	enemies_inside.erase(body)            # ✅ limpiar de la lista al teletransportar
	if body.is_in_group("enemy"):
		await get_tree().process_frame
		procesar_enemigo(body)
	await get_tree().create_timer(0.3).timeout
	can_use = true

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
	enemies_inside.erase(body)            # ✅ limpiar de la lista al teletransportar
	await get_tree().process_frame
	procesar_enemigo(body)
	await get_tree().create_timer(0.3).timeout
	can_use = true
