extends Sprite
	
onready var doorCollision : StaticBody2D = $DoorCollision

func OpenDoor():
	visible = false # hide the closed door, tilemap will have open door behind it
	doorCollision.set_collision_layer_bit(0, false)
	doorCollision.set_collision_mask_bit(0, false) 

func _on_Area2D_body_entered(body):
	if body.name == "Player":
		Events.emit_signal("exit_level_door")

