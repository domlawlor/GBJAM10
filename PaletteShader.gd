extends TextureRect

onready var explodeTimer : Timer = $ExplodeTimer

var List = [
	{
		"name" : "default",
		"darkest" : { "r" : 15, "g" : 56, "b" : 15 },
		"dark" : { "r" : 48, "g" : 98, "b" : 48 },
		"light" : { "r" : 139, "g" : 172, "b" : 15 },
		"lightest" : { "r" : 155, "g" : 188, "b" : 15 },
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
	Events.connect("bomb_timer_finished", self, "_on_bomb_timer_finished")

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

	material.set_shader_param("color_darkest", DEF_DARKEST)
	material.set_shader_param("color_dark", DEF_DARK)
	material.set_shader_param("color_light", DEF_LIGHT)
	material.set_shader_param("color_lightest", DEF_LIGHTEST)

func _process(delta):
	if !explodeTimer.is_stopped():
		var FLASH_INTERVAL = 0.15
		var steps : int = floor(explodeTimer.time_left / FLASH_INTERVAL)
		SetInvert(steps % 2 == 0)

func _input(event):
	if event.is_action_pressed("switchPalette"):
		var i = wrapi(m_index+1, 0, List.size())
		m_index = i
		var new_darkest = Color()
		new_darkest.r8 = List[i].darkest.r
		new_darkest.g8 = List[i].darkest.g
		new_darkest.b8 = List[i].darkest.b
		var new_dark = Color()
		new_dark.r8 = List[i].dark.r
		new_dark.g8 = List[i].dark.g
		new_dark.b8 = List[i].dark.b
		var new_light = Color()
		new_light.r8 = List[i].light.r
		new_light.g8 = List[i].light.g
		new_light.b8 = List[i].light.b
		var new_lightest = Color()
		new_lightest.r8 = List[i].lightest.r
		new_lightest.g8 = List[i].lightest.g
		new_lightest.b8 = List[i].lightest.b
		
		material.set_shader_param("color_darkest", new_darkest)
		material.set_shader_param("color_dark", new_dark)
		material.set_shader_param("color_light", new_light)
		material.set_shader_param("color_lightest", new_lightest)
	
	elif event.is_action_pressed("invertPalette"):
		SetInvert(!m_invert)
	
	elif event.is_action_pressed("testBombFlash"):
		_on_bomb_timer_finished()

func SetInvert(isInvert):
	m_invert = isInvert
	material.set_shader_param("invert", m_invert)

func _on_bomb_timer_finished():
	explodeTimer.start()

func _on_ExplodeTimer_timeout():
	SetInvert(false)
