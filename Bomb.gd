extends Node2D

export var puzzleNameToOpen : String = "1-1"

func _on_InteractDetect_body_entered(body: Node):
	if body.name == "Player":
		body.SetNearbyBomb(self)

func _on_InteractDetect_body_exited(body: Node):
	if body.name == "Player":
		body.ClearNearbyBomb(self)
