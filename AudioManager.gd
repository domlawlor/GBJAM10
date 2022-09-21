extends Node2D

onready var Explosion = $Explosion
onready var Defuse = $Defuse

func _ready():
	Events.connect("play_audio", self, "_on_play_audio")
	Events.connect("bomb_explode", self, "_on_bomb_explode")
	
func _exit():
	Events.disconnect("play_audio", self, "_on_play_audio")
	Events.disconnect("bomb_explode", self, "_on_bomb_explode")

func _on_play_audio(name):
	match name:
		"explosion":
			Explosion.play()
		"defuse":
			Defuse.play()

func _on_bomb_explode():
	Explosion.play()
