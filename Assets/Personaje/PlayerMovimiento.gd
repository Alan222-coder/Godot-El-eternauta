extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

@onready var anim = $AnimationPlayer
@onready var sprite2d = $Sprite2D
@onready var muzzle = $Marker2D
@onready var raycast = $Marker2D/RayCast2D
@onready var hp_bar = $CanvasLayer/TextureProgressBar
@onready var camara_shake = $Camera2D
var game_over_scene = preload("res://Assets/muelto_pantalla/muerte.tscn")
# ---------------- HP ----------------
var hp_max := 100
var hp := 100
var invulnerable := false

# ---------------- AIM ----------------
var apuntando := false

@onready var hp_label = $CanvasLayer/TextureProgressBar
# ---------------- MUNICIÓN ----------------
var cargador_max := 6
var cargador := 6

var reserva_balas := 24
@onready var ammo_label = $CanvasLayer/AmmoLabel

func _ready():
	if hp_bar:
		hp_bar.max_value = hp_max
		hp_bar.value = hp
	ammo_label.text = str(cargador) + " / " + str(reserva_balas)
	
func _physics_process(delta):

	# ---------------- GRAVEDAD ----------------
	if not is_on_floor():
		velocity += get_gravity() * delta

	# ---------------- SALTO ----------------
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
	# ---------------- MOVIMIENTO ----------------
	var direction := 0.0

	# No permitir movimiento mientras apunta
	if not apuntando:
		direction = Input.get_axis("ui_left", "ui_right") + Input.get_axis("mizquierda", "mderecha")
		direction = clamp(direction, -1, 1)

	if direction != 0:
		velocity.x = direction * SPEED
		anim.play("Caminar")
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		anim.stop()

	move_and_slide()

	# ---------------- FLIP ----------------
	if direction > 0:
		sprite2d.flip_h = false
		muzzle.position.x = abs(muzzle.position.x)

	elif direction < 0:
		sprite2d.flip_h = true
		muzzle.position.x = -abs(muzzle.position.x)

	# ---------------- APUNTAR ----------------
	if Input.is_action_pressed("aim"):

		apuntando = true

		var direccion = get_global_mouse_position() - muzzle.global_position

		# El raycast sigue el mouse
		raycast.target_position = direccion

	# ---------------- DISPARAR ----------------
	if apuntando and Input.is_action_just_released("aim"):

		apuntando = false
		if cargador > 0:

			cargador -= 1

			actualizar_hud()

			disparar()
	#-------------------------Recarga--------------------
	
	if Input.is_action_just_pressed("reload"):
		recargar()
	
	
#------------------------Funcion_Hud_Balas--------------------------
func actualizar_hud():
	
	ammo_label.text = str(cargador) + " / " + str(reserva_balas)
	
#------------------------Funcion_Recarga--------------------

func recargar():

	if reserva_balas <= 0:
		return

	if cargador == cargador_max:
		return

	var faltan = cargador_max - cargador

	var cantidad_a_recargar = min(faltan, reserva_balas)

	cargador += cantidad_a_recargar
	reserva_balas -= cantidad_a_recargar

	actualizar_hud()
	

#-----------------------Disparo_Raycast------------------

func disparar():

	raycast.force_raycast_update()

	var inicio = muzzle.global_position
	var fin = raycast.to_global(raycast.target_position)

	# ---------------- SI GOLPEA ----------------
	if raycast.is_colliding():

		var collider = raycast.get_collider()
		var punto = raycast.get_collision_point()

		print("Golpeaste:", collider.name)

		# Aplicar daño
		if collider.has_method("recibir_daño"):
			collider.recibir_daño(25)

		draw_linea(inicio, punto)

	else:
		draw_linea(inicio, fin)

# ---------------- EFECTO VISUAL DEL DISPARO ----------------
func draw_linea(start, end):

	var line = Line2D.new()

	line.top_level = true
	line.default_color = Color(1, 1, 0)

	# Grosor
	line.width = 12

	# Punta más gruesa
	var curve = Curve.new()
	curve.add_point(Vector2(0, 0.15))
	curve.add_point(Vector2(1, 1.0))

	line.width_curve = curve

	line.add_point(start)
	line.add_point(end)

	get_tree().current_scene.add_child(line)

	# ---------------- ANIMACIÓN ----------------

	var duration = 0.08
	var elapsed = 0.0

	while elapsed < duration:

		elapsed += get_process_delta_time()

		var t = elapsed / duration
		t = clamp(t, 0.0, 1.0)

		# El inicio avanza hacia el final
		var nuevo_inicio = start.lerp(end, t)

		line.set_point_position(0, nuevo_inicio)

		# Reducir grosor suavemente
		line.width = lerp(12.0, 0.0, t)

		await get_tree().process_frame

	line.queue_free()

# ---------------- RECIBIR DAÑO ----------------
func recibir_daño(cantidad):

	if invulnerable:
		return

	hp -= cantidad
	hp = max(hp, 0)
	hp_bar.value = hp
	invulnerable = true
	screen_shake()
	await get_tree().create_timer(1).timeout
	
	invulnerable = false

	if hp <= 0:
		morir()
	return cantidad
	

#-----------------Shake de la camara--------------
func screen_shake():

	var original_offset = camara_shake.offset

	for i in range(8):

		camara_shake.offset = Vector2(
			randf_range(-6, 6),
			randf_range(-6, 6)
		)

		await get_tree().process_frame

	camara_shake.offset = original_offset

# ---------------- MORIR ----------------
func morir():
	print("Moriste")
	
	var game_over = game_over_scene.instantiate()

	get_tree().current_scene.add_child(game_over)

	get_tree().paused = true
