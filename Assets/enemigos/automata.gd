extends CharacterBody2D

@export var speed := 100
@export var speed_enojado := 170 # Velocidad cuando tiene poca vida

# Distancia máxima horizontal para perseguir
@export var max_distancia_horizontal := 400

# ---------------- VIDA ----------------
var vida := 100
var vida_maxima := 100

var player: Node2D = null

func _ready():
	player = get_tree().get_first_node_in_group("player")

func _physics_process(delta):
	if player == null:
		return

	# ---------------- GIRAR SPRITE ----------------
	if player.global_position.x > global_position.x:
		$Sprite2D.flip_h = false
	else:
		$Sprite2D.flip_h = true

	# ---------------- GRAVEDAD ----------------
	if not is_on_floor():
		velocity += get_gravity() * delta

	# ---------------- DISTANCIA HORIZONTAL ----------------
	var distancia_horizontal = abs(player.global_position.x - global_position.x)

	# Si el jugador está demasiado lejos horizontalmente,
	# el enemigo simplemente se queda quieto
	if distancia_horizontal > max_distancia_horizontal:
		velocity.x = 0
		move_and_slide()
		return

	# ---------------- DISTANCIA VERTICAL ----------------
	var jugador_fuera_vertical = (
		player.global_position.y < global_position.y - 50 or
		player.global_position.y > global_position.y + 50
	)

	# Si el jugador está demasiado arriba o abajo,
	# el enemigo también se queda quieto
	if jugador_fuera_vertical:
		velocity.x = 0
		move_and_slide()
		return

	# ---------------- VELOCIDAD SEGÚN VIDA ----------------
	var velocidad_actual = speed

	# Si tiene menos de la mitad de vida, se vuelve más rápido
	if vida <= vida_maxima / 2:
		velocidad_actual = speed_enojado

	# ---------------- MOVIMIENTO ----------------
	velocity.x = sign(player.global_position.x - global_position.x) * velocidad_actual

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
