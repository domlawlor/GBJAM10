extends Sprite

var STATE = Global.State

onready var Text01 = $Text01
onready var Text02 = $Text02
onready var Text03 = $Text03

var textNum = 1

func _input(event):
	if !visible or Global.state != STATE.STORYSCREEN:
		return
	
	if event.is_action_pressed("gameboy_a"):
		textNum += 1
		if textNum == 2:
			Text02.visible = true
		elif textNum == 3:
			Text03.visible = true
		elif textNum == 4:
			Events.emit_signal("fade_to_dark_request")
			Global.state = STATE.CHANGING_LEVEL
