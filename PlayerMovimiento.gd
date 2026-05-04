extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0

@onready var animacion_de_jugador=$AnimationPlayer
@onready var sprite2d=$Sprite2D
# --- HP ---
var hp_max: int = 100
var hp: int = 100
var invulnerable: bool = false
@onready var hp_label: Label = $"../../CanvasLayer/Label"  # ← ajustá esta ruta

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	# Movimiento combinado
	var direction := Input.get_axis("ui_left", "ui_right") + Input.get_axis("mizquierda", "mderecha")
	direction = clamp(direction, -1, 1)
	hp_label.text = "HP: " + str(hp)
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

	if direction == 1:
		sprite2d.flip_h = false
	elif direction == -1:
		sprite2d.flip_h = true


func _on_portal_escalera_body_entered(body: Node2D) -> void:
	hp_label.text = "HP: " + str(hp)

func recibir_daño(cantidad: int) -> void:
	if invulnerable:
		return
	hp -= cantidad
	hp = max(hp, 0)
	invulnerable = true
	await get_tree().create_timer(0.5).timeout
	invulnerable = false
	if hp <= 0:
		morir()

func morir() -> void:
	print("Moriste")
