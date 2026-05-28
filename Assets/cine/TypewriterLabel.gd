extends RichTextLabel

## TypewriterLabel.gd
signal typing_finished

@export var full_text: String = "La nieve empezó un martes.\n
En Argentina eso ya era raro. Pero lo peor no fue el frío. Lo peor fue ver a la gente caer apenas la tocaba.\n
El rescate nunca llegó.\n
Ni militares, ni sirenas, ni una sola voz en la radio después del tercer día. Solo silencio… y esas cosas caminando por las calles vacías de Córdoba durante la noche.\n
Mis amigos y yo nos refugiamos juntos al principio. Franco decía que todo iba a pasar rápido. Lucía no dejaba de mirar por la ventana. Después nos separamos corriendo cuando algo entró al edificio.\n
No los volví a ver.\n
Ahora camino solo entre autos abandonados y departamentos oscuros buscándolos, esperando encontrar aunque sea una señal de que siguen vivos.\n
Porque afuera ya no queda país.\n
Solo nieve… y algo observándonos desde ella.\n
Entonces me decidi que si nadie nos vendria a salvar...\n
Yo y mi rifle lo haran."
@export var chars_per_second: float = 30.0
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
