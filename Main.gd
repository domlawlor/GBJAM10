extends Node2D

func _ready():
	SetResolution()

func _exit():
	pass

func SetResolution():
	var native_screen = OS.get_screen_size()
	var max_scale_x = floor(native_screen.x / Global.LOGICAL_RES.x)
	var max_scale_y = floor(native_screen.y / Global.LOGICAL_RES.y)
	Global.SCALE = 4#min(max_scale_x, max_scale_y)

	var scaled_window = Vector2(Global.LOGICAL_RES.x * Global.SCALE, Global.LOGICAL_RES.y * Global.SCALE)
	OS.set_window_size(scaled_window)
