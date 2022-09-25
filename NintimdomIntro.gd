extends Node2D

onready var animationPlayer = $AnimationPlayer

func _ready():
	animationPlayer.play("Intro")

func StartGame():
	visible = false
	Global.state = Global.State.TITLE
	Events.emit_signal("start_game")
