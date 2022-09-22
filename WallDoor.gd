extends AnimatedSprite

onready var doorCollision : StaticBody2D = $DoorCollision

func _ready():
	play("closed")

func OpenDoor():
	play("open")
	if doorCollision:
		doorCollision.set_collision_layer_bit(0, false)
		doorCollision.set_collision_mask_bit(0, false)
