extends Sprite

var STATE = Global.State
	
onready var doorCollision : StaticBody2D = $DoorCollision

func _ready():
	Events.connect("fade_to_dark_complete", self, "_on_fade_to_dark_complete")

func _exit():
	Events.disconnect("fade_to_dark_complete", self, "_on_fade_to_dark_complete")

func OpenDoor():
	visible = false # hide the closed door, tilemap will have open door behind it
	doorCollision.set_collision_layer_bit(0, false)
	doorCollision.set_collision_mask_bit(0, false) 

func _on_Area2D_body_entered(body):
	if body.name == "Player":
		Global.state = STATE.CHANGING_LEVEL
		Events.emit_signal("fade_to_dark_request")
		body.visible = false
