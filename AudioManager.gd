extends Node2D

var STATE = Global.State

onready var Explosion = $Explosion
onready var Defuse = $Defuse
onready var Cut = $Cut
onready var GameplayNormal = $GameplayNormal

func _ready():
	Events.connect("play_audio", self, "_on_play_audio")
	Events.connect("wire_cut", self, "_on_wire_cut")
	Events.connect("bomb_explode", self, "_on_bomb_explode")
	Events.connect("fade_from_dark_complete", self, "_on_fade_from_dark_complete")
	
func _exit():
	Events.disconnect("play_audio", self, "_on_play_audio")
	Events.disconnect("wire_cut", self, "_on_wire_cut")
	Events.disconnect("bomb_explode", self, "_on_bomb_explode")
	Events.disconnect("fade_from_dark_complete", self, "_on_fade_from_dark_complete")

func PlayGameplayNormal():
	if !GameplayNormal.playing:
		GameplayNormal.play()

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
	GameplayNormal.stop()
	Explosion.play()

func _on_fade_from_dark_complete():
	print("gggg-" + str(Global.state))
	if Global.state == STATE.CHANGING_LEVEL:
		PlayGameplayNormal()
	elif Global.state == STATE.RESTARTING_FROM_DEATH:
		PlayGameplayNormal()
