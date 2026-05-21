extends Node

@onready var ambient_audio = $AmbientAudio

@export var sonidos_ambiente : Array[AudioStream]

var tiempo := 420.0
var player = null

func _ready():

	randomize()

	ambiente_loop()

func _process(delta):

	if tiempo > 0:

		tiempo -= delta

		tiempo = max(tiempo, 0)

	if tiempo <= 0 and player != null:

		player.morir()

func ambiente_loop():

	while true:

		var espera = randf_range(5.0, 14.0)

		await get_tree().create_timer(espera).timeout

		ambient_audio.stream = sonidos_ambiente.pick_random()

		ambient_audio.play()

		await ambient_audio.finished
