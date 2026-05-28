extends RichTextLabel

## TypewriterLabel.gd
signal typing_finished

@export var full_text: String = "Los encontré.\nDespués de semanas caminando entre ruinas, nieve y silencio… los encontré vivos.\nÉramos pocos, pero suficientes para seguir adelante.\nPor primera vez desde que empezó todo, sentí que tal vez podíamos sobrevivir.\n
Pero mientras volvíamos con todos vivos...\nEl gurvo apareció entre los edificios destruidos, enorme, arrastrándose como una montaña viva.\nY detrás de él… cientos de cascarudos.\nNo había forma de pelear contra eso.\nAsí que hice lo único que podía hacer.\nSalí corriendo hacia la calle y empecé a disparar.\nLos cascarudos cambiaron de dirección al instante.\nEscuché a los demás gritar mientras escapaban de regreso a la base.\n
Y por un momento… supe que lo habían logrado.\nDespués dejaron de importar el frío, el dolor y los disparos.\n
Porque mientras esas cosas me despedazaban bajo la nieve… entendí que al menos alguien sobreviviría para contar lo que pasó en Argentina.\n
EL FIN."

@export var chars_per_second: float = 15.0
@export var fast_chars_per_second: float = 1000.0

## Fracción del ancho del viewport que ocupa la caja (debe coincidir con los márgenes de la escena)
@export var box_width_fraction: float = 0.7
## Tamaño de letra base cada 1000px de ancho de viewport
@export var font_size_per_1000px: float = 20.0
## Límites del tamaño de letra
@export var font_size_min: int = 14
@export var font_size_max: int = 28

var _timer: float = 0.0
var _char_index: int = 0
var _is_finished: bool = false
var _is_fast: bool = false

func _ready() -> void:
	bbcode_enabled = true
	fit_content = true          # el label crece con el contenido
	scroll_active = false
	autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	text = ""
	visible_characters = 0
	_apply_font_size()
	get_viewport().size_changed.connect(_apply_font_size)

func _apply_font_size() -> void:
	var vp_width := get_viewport().get_visible_rect().size.x
	var size := int(vp_width / 1000.0 * font_size_per_1000px)
	size = clamp(size, font_size_min, font_size_max)
	add_theme_font_size_override("normal_font_size", size)

func start_typing() -> void:
	text = full_text
	visible_characters = 0
	_char_index = 0
	_is_finished = false
	_is_fast = false
	_timer = 0.0
	set_process(true)

func skip_to_end() -> void:
	if _is_finished:
		return
	_is_fast = true

func _process(delta: float) -> void:
	if _is_finished:
		set_process(false)
		return
	var speed := fast_chars_per_second if _is_fast else chars_per_second
	_timer += delta * speed
	var new_index := int(_timer)
	if new_index >= len(full_text):
		visible_characters = -1
		_is_finished = true
		set_process(false)
		typing_finished.emit()
		return
	if new_index != _char_index:
		_char_index = new_index
		visible_characters = _char_index
