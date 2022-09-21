extends Node2D

export var puzzleName : String = "1-1"
export var bombOrderNumber : int = -1

export var bombIsInTheDark : bool = false

onready var litBomb : Sprite = $LitBomb

func _ready():
	assert(bombOrderNumber != -1, "Each bomb needs to be in a sequence order")
	
	if bombIsInTheDark:
		litBomb.visible = false
	
func _on_InteractDetect_body_entered(body: Node):
	if body.name == "Player":
		body.SetNearbyBomb(self)

func _on_InteractDetect_body_exited(body: Node):
	if body.name == "Player":
		body.ClearNearbyBomb(self)
