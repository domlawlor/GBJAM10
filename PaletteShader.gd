extends TextureRect

var STATE = Global.State

onready var explodeTimer : Timer = $ExplodeTimer
onready var titleExplodeTimer : Timer = $TitleExplodeTimer

export var DefaultColorPaletteIndex : int = 1 

var List = [
	{
		"name" : "default",
		"darkest" : { "r" : 15, "g" : 56, "b" : 15 },
		"dark" : { "r" : 48, "g" : 98, "b" : 48 },
		"light" : { "r" : 139, "g" : 172, "b" : 15 },
		"lightest" : { "r" : 155, "g" : 188, "b" : 15 },
	},
	{
		"name" : "green_with_more_contrast",
		"darkest" : { "r" : 0, "g" : 19, "b" : 26 },
		"dark" : { "r" : 61, "g" : 128, "b" : 38 },
		"light" : { "r" : 171, "g" : 204, "b" : 71 },
		"lightest" : { "r" : 250, "g" : 255, "b" : 179 },
	},
	{
		"name" : "ice_cream",
		"darkest" : { "r" : 124, "g" : 63, "b" : 88 },
		"dark" : { "r" : 235, "g" : 107, "b" : 111 },
		"light" : { "r" : 249, "g" : 168, "b" : 117 },
		"lightest" : { "r" : 255, "g" : 246, "b" : 211 },
	},
	{
		"name" : "wish",
		"darkest" : { "r" : 98, "g" : 46, "b" : 76 },
		"dark" : { "r" : 117, "g" : 80, "b" : 232 },
		"light" : { "r" : 96, "g" : 143, "b" : 207 },
		"lightest" : { "r" : 139, "g" : 229, "b" : 255 },
	},
]

var DEF_DARKEST : Color
var DEF_DARK : Color
var DEF_LIGHT : Color
var DEF_LIGHTEST : Color

var m_index = 0
var m_invert : bool = false

func _ready():
	Events.connect("bomb_explode", self, "_on_bomb_explode")
	Events.connect("fade_to_dark_complete", self, "_on_fade_to_dark_complete")
	Events.connect("end_of_story", self, "_on_end_of_story")

	DEF_DARKEST = Color()
	DEF_DARKEST.r8 = List[0].darkest.r
	DEF_DARKEST.g8 = List[0].darkest.g
	DEF_DARKEST.b8 = List[0].darkest.b
	DEF_DARK = Color()
	DEF_DARK.r8 = List[0].dark.r
	DEF_DARK.g8 = List[0].dark.g
	DEF_DARK.b8 = List[0].dark.b
	DEF_LIGHT = Color()
	DEF_LIGHT.r8 = List[0].light.r
	DEF_LIGHT.g8 = List[0].light.g
	DEF_LIGHT.b8 = List[0].light.b
	DEF_LIGHTEST = Color()
	DEF_LIGHTEST.r8 = List[0].lightest.r
	DEF_LIGHTEST.g8 = List[0].lightest.g
	DEF_LIGHTEST.b8 = List[0].lightest.b
	
	material.set_shader_param("default_darkest", DEF_DARKEST)
	material.set_shader_param("default_dark", DEF_DARK)
	material.set_shader_param("default_light", DEF_LIGHT)
	material.set_shader_param("default_lightest", DEF_LIGHTEST)
	
	SetColoursByPaletteIndex(DefaultColorPaletteIndex)

func _exit():
	Events.disconnect("bomb_explode", self, "_on_bomb_explode")
	Events.disconnect("fade_to_dark_complete", self, "_on_fade_to_dark_complete")
	Events.disconnect("end_of_story", self, "_on_end_of_story")

func _process(_delta):
	if !explodeTimer.is_stopped():
		var FLASH_INTERVAL = 0.12
		var steps : int = floor(explodeTimer.time_left / FLASH_INTERVAL)
		SetInvert(steps % 2 == 0)
	elif !titleExplodeTimer.is_stopped():
		var FLASH_INTERVAL = 0.12
		var steps : int = floor(titleExplodeTimer.time_left / FLASH_INTERVAL)
		SetInvert(steps % 2 == 0)

func _input(event):
	if Global.state == STATE.DEAD:
		if event.is_action_pressed("gameboy_a"):
			Events.emit_signal("restart_game")
	
	if event.is_action_pressed("gameboy_select"):
		var i = wrapi(m_index+1, 0, List.size())
		SetColoursByPaletteIndex(i)
	
	elif event.is_action_pressed("invertPalette"):
		SetInvert(!m_invert)
	
	elif event.is_action_pressed("testBombFlash"):
		_on_bomb_explode()

func SetColoursByPaletteIndex(index):
	if index < 0 or index > List.size():
		push_error("Palette Index outside range of colours")
		return
	
	m_index = index
	var new_darkest = Color()
	new_darkest.r8 = List[index].darkest.r
	new_darkest.g8 = List[index].darkest.g
	new_darkest.b8 = List[index].darkest.b
	var new_dark = Color()
	new_dark.r8 = List[index].dark.r
	new_dark.g8 = List[index].dark.g
	new_dark.b8 = List[index].dark.b
	var new_light = Color()
	new_light.r8 = List[index].light.r
	new_light.g8 = List[index].light.g
	new_light.b8 = List[index].light.b
	var new_lightest = Color()
	new_lightest.r8 = List[index].lightest.r
	new_lightest.g8 = List[index].lightest.g
	new_lightest.b8 = List[index].lightest.b
	
	material.set_shader_param("color_darkest", new_darkest)
	material.set_shader_param("color_dark", new_dark)
	material.set_shader_param("color_light", new_light)
	material.set_shader_param("color_lightest", new_lightest)

func SetInvert(isInvert):
	m_invert = isInvert
	material.set_shader_param("invert", m_invert)

func _on_bomb_explode():
	explodeTimer.start()

func _on_ExplodeTimer_timeout():
	SetInvert(true)
	Events.emit_signal("fade_to_dark_request")

func _on_fade_to_dark_complete():
	if Global.state == STATE.EXPLOSION:
		Global.state = STATE.DEAD

func _on_TitleExplodeTimer_timeout():
	SetInvert(false)

func _on_end_of_story():
	titleExplodeTimer.start()
