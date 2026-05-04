extends CharacterBody2D

@export var speed := 100
var player: Node2D = null

func _ready():
	player = get_tree().get_first_node_in_group("player")

func _physics_process(delta):
	if player == null:
		return
		
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	var direction = (player.global_position - global_position).normalized()
	velocity.x = direction.x * speed
	
	move_and_slide()
