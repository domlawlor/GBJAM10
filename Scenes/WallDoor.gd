extends AnimatedSprite

onready var doorCollision : StaticBody2D = $DoorCollision
onready var delayTimer : Timer = $DelayTimer
onready var audioTimer : Timer = $AudioTimer

func _ready():
	play("closed")

func OpenDoor():
	assert(delayTimer)
	delayTimer.start()
	if audioTimer:
		audioTimer.start()

func _on_DelayTimer_timeout():
	play("open")
	if doorCollision:
		doorCollision.set_collision_layer_bit(0, false)
		doorCollision.set_collision_mask_bit(0, false)

func _on_AudioTimer_timeout():
	Events.emit_signal("play_audio", "opendoor")
