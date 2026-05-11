extends CharacterBody2D

@export var speed := 100
@export var portal_delay := 0.8

# ---------------- VIDA ----------------
var vida := 100

var player: Node2D = null
var _timer_portal := 0.0
var _yendo_a_portal := false

func _ready():
	player = get_tree().get_first_node_in_group("player")

func _physics_process(delta):

	if player == null:
		return

	# ---------------- GRAVEDAD ----------------
	if not is_on_floor():
		velocity += get_gravity() * delta

	# ---------------- DETECTAR DIFERENCIA DE ALTURA ----------------
	var jugador_lejos_vertical = (
		player.global_position.y < global_position.y - 50 or
		player.global_position.y > global_position.y + 50
	)

	if jugador_lejos_vertical:

		if not _yendo_a_portal:
			_timer_portal += delta

			if _timer_portal >= portal_delay:
				_yendo_a_portal = true

	else:
		_timer_portal = 0.0
		_yendo_a_portal = false

	# ---------------- MOVIMIENTO ----------------
	var target_x: float

	if _yendo_a_portal:

		var portal = _get_portal_en_mi_nivel()

		if portal != null:
			target_x = portal.global_position.x
		else:
			target_x = player.global_position.x

	else:
		target_x = player.global_position.x

	velocity.x = sign(target_x - global_position.x) * speed

	move_and_slide()

	# ---------------- DAÑO AL JUGADOR ----------------
	for body in $Hitbox.get_overlapping_bodies():

		# SOLO dañar al jugador
		if body.is_in_group("player"):
			body.recibir_daño(10)

# ---------------- RECIBIR DAÑO ----------------
func recibir_daño(cantidad):

	vida -= cantidad

	print("Vida enemigo:", vida)

	if vida <= 0:
		morir()

# ---------------- MORIR ----------------
func morir():

	print("Enemigo muerto")

	queue_free()

# ---------------- BUSCAR PORTAL ----------------
func _get_portal_en_mi_nivel() -> Node2D:

	var portales = get_tree().get_nodes_in_group("portales")

	var portal_mas_cercano: Node2D = null
	var distancia_min := INF

	for portal in portales:

		if abs(portal.global_position.y - global_position.y) <= 50:

			var dist = abs(portal.global_position.x - global_position.x)

			if dist < distancia_min:
				distancia_min = dist
				portal_mas_cercano = portal

	return portal_mas_cercano
