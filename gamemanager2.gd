extends Node
@onready var death_music = $deathmusic
@onready var ambient_audio = $AmbientAudio
@onready var music_audio = $MusicAudio
@export var sonidos_ambiente : Array[AudioStream]
@export var score = "res://Assets/niveles/scorecoll.gd"
var tiempo := 240.0
var player = null
var cargador_max := 6
var cargador := 6
var reserva_balas := 12
func _ready():

	randomize()
	music_audio.play()

	ambiente_loop()

func _process(delta):

	if tiempo > 0:

		tiempo -= delta

		tiempo = max(tiempo, 0)

	if tiempo <= 0 and player != null:

		player.morir()

func ambiente_loop():

	while true:

		var espera = randf_range(10.0, 30.0)

		await get_tree().create_timer(espera).timeout

		ambient_audio.stream = sonidos_ambiente.pick_random()

		ambient_audio.play()

		await ambient_audio.finished

func resetear_datos():

	tiempo = 240.0

	cargador = 6

	reserva_balas = 12

	score = 0
func reproducir_muerte():
	music_audio.stop()

	death_music.play()
