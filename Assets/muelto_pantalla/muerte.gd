extends CanvasLayer


@onready var boton = $Button
@onready var audio_boton = $Button/audio_boton
func _ready():

	boton.disabled = true

	await get_tree().create_timer(2.5, true).timeout

	boton.disabled = false

func _on_button_pressed():

	audio_boton.play()

	await audio_boton.finished

	Gamemanager.death_music.stop()

	get_tree().paused = false

	Gamemanager.resetear_datos()

	get_tree().change_scene_to_file("res://MenuPrincipal.tscn")
