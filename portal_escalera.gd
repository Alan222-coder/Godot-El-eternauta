extends Area2D

@export var landing_zone : Area2D

var player_inside := false
var player_ref : Node2D = null

static var position_stack : Array = []
static var can_use := true

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_inside = true
		player_ref = body

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_inside = false
		player_ref = null

func _process(delta):
	if player_inside and can_use and Input.is_action_just_pressed("teleport"):
		subir()
	
	if position_stack.size() > 0 and can_use and Input.is_action_just_pressed("bajar"):
		bajar()

func subir():
	if !landing_zone:
		return
	
	var marker = landing_zone.get_node_or_null("Marker2D")
	if !marker:
		return
	
	can_use = false
	
	# 🔥 evitar duplicados
	if position_stack.is_empty() or position_stack.back() != player_ref.global_position:
		position_stack.push_back(player_ref.global_position)
	
	player_ref.global_position = marker.global_position
	
	if player_ref is CharacterBody2D:
		player_ref.velocity = Vector2.ZERO
	
	player_inside = false
	player_ref = null
	
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
	#hola mundo 
	
