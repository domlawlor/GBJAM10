extends Node2D

onready var Explosion = $Explosion
onready var Defuse = $Defuse
onready var Cut = $Cut

func _ready():
	Events.connect("play_audio", self, "_on_play_audio")
	Events.connect("wire_cut", self, "_on_wire_cut")
	Events.connect("bomb_explode", self, "_on_bomb_explode")
	
func _exit():
	Events.disconnect("play_audio", self, "_on_play_audio")
	Events.disconnect("wire_cut", self, "_on_wire_cut")
	Events.disconnect("bomb_explode", self, "_on_bomb_explode")

func _on_play_audio(name):
	match name:
		"explosion":
			Explosion.play()
		"defuse":
			Defuse.play()
		"cut":
			Cut.play()

func _on_wire_cut():
	Cut.play()
	
func _on_bomb_explode():
	Explosion.play()
