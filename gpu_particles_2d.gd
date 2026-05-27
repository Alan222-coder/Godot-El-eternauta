extends Node2D

func _ready():
	var particles = $GPUParticles2D
	var material = ParticleProcessMaterial.new()
	
	# Movimiento de caída
	material.direction = Vector3(0, 1, 0)
	material.gravity = Vector3(0, 98, 0)
	material.initial_velocity_min = 50.0
	material.initial_velocity_max = 100.0
	
	# Dispersión horizontal (viento)
	material.spread = 15.0
	
	# COLISIÓN - clave para no traspasar tilemap
	material.collision_mode = ParticleProcessMaterial.COLLISION_HIDE_ON_CONTACT
	material.collision_bounce = 0.0
	material.collision_friction = 1.0
	
	particles.process_material = material
	particles.amount = 200
