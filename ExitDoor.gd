extends Sprite

var STATE = Global.State

onready var doorCollision : StaticBody2D = $DoorCollision
onready var delayTimer : Timer = $DelayTimer
onready var audioTimer : Timer = $AudioTimer

var m_finalDoor = false

func OpenDoor():
	delayTimer.start()
	audioTimer.start()

func _on_Area2D_body_entered(body):
	if body.name == "Player":
		Global.state = STATE.CHANGING_LEVEL
		Events.emit_signal("fade_to_dark_request")
		body.visible = false

func _on_DelayTimer_timeout():
	visible = false # hide the closed door, tilemap will have open door behind it
	doorCollision.set_collision_layer_bit(0, false)
	doorCollision.set_collision_mask_bit(0, false) 

func _on_AudioTimer_timeout():
	Events.emit_signal("play_audio", "opendoor")
	if m_finalDoor:
		Events.emit_signal("trigger_final_music")
