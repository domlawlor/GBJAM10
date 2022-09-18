extends Area2D

export var puzzleNameToOpen : String = "1-1"

func _on_Bomb_body_entered(body: Node):
	var bombPuzzleNode = get_node("../BombPuzzle")
	assert(bombPuzzleNode)
		
	Global.activeBombPuzzle = bombPuzzleNode
	body.EnterBombInteractArea()
	pass

func _on_Bomb_body_exited(body: Node):
	body.ExitBombInteractArea()
	pass
