extends Node2D

export var pageNum : int = 0

func _on_InteractArea_body_entered(body):
	if body.name == "Player":
		body.SetNearbyBookPage(self)

func _on_InteractArea_body_exited(body):
	if body.name == "Player":
		body.ClearNearbyBookPage(self)
