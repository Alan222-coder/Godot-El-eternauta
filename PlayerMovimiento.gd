extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0

@onready var animacion_de_jugador=$AnimationPlayer
@onready var sprite2d=$Sprite2D
func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Movimiento combinado
	var direction := Input.get_axis("ui_left", "ui_right") + Input.get_axis("mizquierda", "mderecha")
	direction = clamp(direction, -1, 1)

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
	pass # Replace with function body.
