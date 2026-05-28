# res://gamemanager2.gd
extends Node

@onready var death_music = $deathmusic
@onready var ambient_audio = $AmbientAudio
@onready var music_audio = $MusicAudio

@export var sonidos_ambiente : Array[AudioStream]

var tiempo := 280.0
var player = null

var cargador_max := 6
var cargador := 6
var reserva_balas := 12

# SCORE GLOBAL
var score := 0


func _ready():

	randomize()

	music_audio.play()

	# Guarda el score inicial
	get_tree().set_meta("score", score)

	ambiente_loop()


func _process(delta):

	# Actualiza el score global
	get_tree().set_meta("score", score)

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

	# Reinicia el score global
	get_tree().set_meta("score", score)


func reproducir_muerte():

	music_audio.stop()

	death_music.play()


func bonus_tiempo():

	var bonus = int(tiempo) * 10

	score += bonus

	# Actualiza el meta inmediatamente
	get_tree().set_meta("score", score)

	return bonus
