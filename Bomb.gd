extends Node2D

export var puzzleName : String = "1-1"
export var bombOrderNumber : int = -1

export var bombIsInTheDark : bool = false

onready var bomb : AnimatedSprite = $Bomb

func _ready():
	Events.connect("bomb_number_solved", self, "_on_bomb_number_solved")
	
	assert(bombOrderNumber != -1, "Each bomb needs to be in a sequence order")
	
	if bombIsInTheDark:
		bomb.play("unlit")
	else:
		bomb.play("lit")
	
func _exit():
	Events.disconnect("bomb_number_solved", self, "_on_bomb_number_solved")
	
func _on_InteractDetect_body_entered(body: Node):
	if body.name == "Player":
		body.SetNearbyBomb(self)

func _on_InteractDetect_body_exited(body: Node):
	if body.name == "Player":
		body.ClearNearbyBomb(self)

func _on_bomb_number_solved(bombNum):
	if bombNum == bombOrderNumber:
		if bombIsInTheDark:
			bomb.play("unlit_solved")
		else:
			bomb.play("lit_solved")

