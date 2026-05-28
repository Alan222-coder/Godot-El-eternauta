extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

@export var popup_scene : PackedScene

@onready var hp_bar = get_node_or_null("CanvasLayer/TextureProgressBar")
@onready var anim = $AnimationPlayer
@onready var sprite2d = $Sprite2D
@onready var muzzle = $Marker2D
@onready var raycast = $Marker2D/RayCast2D

var completable := false

@onready var camara_shake = $Camera2D

# AUDIO
@onready var audio_disparo = get_node_or_null("AudioDisparo")
@onready var audio_recarga = get_node_or_null("AudioRecarga")

# UI
@onready var ammo_label = get_node_or_null("CanvasLayer/AmmoLabel")
@onready var score_label = get_node_or_null("CanvasLayer/ScoreLabel")

var game_over_scene = preload("res://Assets/muelto_pantalla/muerte.tscn")

# ---------------- HP ----------------
var hp_max := 100
var hp := 100
var invulnerable := false

# ---------------- AIM ----------------
var apuntando := false

# ---------------- MUNICIÓN ----------------
var recargando := false

#--------------------tiempo---------------------
@onready var time_label = $CanvasLayer/TimeLabel

#-----------------------Pasos------------------

@onready var audio_paso = $AudioPaso
var puede_paso := true
var tiempo_paso := 0.35

#------------------------Musica_puntos----------------------------
@onready var audio_score = $AudioScore

func _ready():

	Gamemanager.player = self

	if hp_bar:

		hp_bar.max_value = hp_max
		hp_bar.value = hp

	actualizar_hud()
	actualizar_score()

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

		if puede_paso and is_on_floor():

			sonido_paso()

	else:

		velocity.x = move_toward(velocity.x, 0, SPEED)

		anim.stop()

	move_and_slide()

	# ---------------- FLIP ----------------
	if apuntando:

		# Mirar hacia el mouse
		if get_global_mouse_position().x > global_position.x:

			sprite2d.flip_h = false
			muzzle.position.x = abs(muzzle.position.x)

		else:

			sprite2d.flip_h = true
			muzzle.position.x = -abs(muzzle.position.x)

	else:

		# Mirar hacia la dirección de movimiento
		if direction > 0:

			sprite2d.flip_h = false
			muzzle.position.x = abs(muzzle.position.x)

		elif direction < 0:

			sprite2d.flip_h = true
			muzzle.position.x = -abs(muzzle.position.x)

	# ---------------- APUNTAR ----------------
	if Input.is_action_pressed("aim") and not recargando:

		apuntando = true

		var direccion = get_global_mouse_position() - muzzle.global_position

		# El raycast sigue el mouse
		raycast.target_position = direccion

	# ---------------- DISPARAR ----------------
	if apuntando and Input.is_action_just_released("aim") and not recargando:

		apuntando = false

		if Gamemanager.cargador > 0:

			Gamemanager.cargador -= 1

			actualizar_hud()

			if audio_disparo:

				audio_disparo.play()

			disparar()

	# ---------------- RECARGAR ----------------
	if Input.is_action_just_pressed("reload"):

		recargar()

	actualizar_hud()

#--------------------Funcion_Paso----------------

func sonido_paso():

	puede_paso = false

	audio_paso.play()

	await get_tree().create_timer(tiempo_paso).timeout

	puede_paso = true

# ---------------- HUD ----------------
func actualizar_hud():

	ammo_label.text = str(Gamemanager.cargador) + " / " + str(Gamemanager.reserva_balas)

	score_label.text = str(Gamemanager.score)

	var tiempo_restante = int(Gamemanager.tiempo)

	var minutos = tiempo_restante / 60
	var segundos = tiempo_restante % 60

	time_label.text = "%02d:%02d" % [minutos, segundos]

# ---------------- SCORE ----------------

func sumar_score(value):

	Gamemanager.score += value

	actualizar_score()

	audio_score.play()

	mostrar_popup_score(value)

	print("Score actual:", Gamemanager.score)

func actualizar_score():

	if score_label:

		score_label.text = str(Gamemanager.score)

func set_completable():

	completable = true

	print("Completable")

# ---------------- RECARGA ----------------
func recargar():

	if recargando:

		return

	if Gamemanager.reserva_balas <= 0:

		return

	if Gamemanager.cargador == Gamemanager.cargador_max:

		return

	recargando = true

	apuntando = false

	if audio_recarga:

		audio_recarga.play()

	await get_tree().create_timer(1.5).timeout

	var faltan = Gamemanager.cargador_max - Gamemanager.cargador

	var cantidad_a_recargar = min(faltan, Gamemanager.reserva_balas)

	Gamemanager.cargador += cantidad_a_recargar
	Gamemanager.reserva_balas -= cantidad_a_recargar

	actualizar_hud()

	recargando = false

# ---------------- DISPARAR ----------------
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

	# Verificar si existe la barra
	if hp_bar != null:

		hp_bar.value = hp

	invulnerable = true

	screen_shake()

	await get_tree().create_timer(1).timeout

	invulnerable = false

	if hp <= 0:

		morir()

	return cantidad

# ---------------- SHAKE DE LA CAMARA ----------------
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

	var game_over = game_over_scene.instantiate()

	Gamemanager.reproducir_muerte()

	game_over.visible = true

	get_tree().current_scene.add_child(game_over)

	get_tree().paused = true

func mostrar_popup_score(cantidad):

	var popup = popup_scene.instantiate()

	popup.global_position = global_position + Vector2(0, -40)

	popup.setup("+" + str(cantidad))

	get_tree().current_scene.add_child(popup)
