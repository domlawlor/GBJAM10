extends Node2D

var STATE = Global.State

onready var Explosion = $Explosion
onready var Defuse = $Defuse
onready var OpenDoor = $OpenDoor
onready var Cut = $Cut
onready var Navigate = $Navigate
onready var GameplayNormal = $GameplayNormal
onready var Title = $Title

func _ready():
	Events.connect("play_audio", self, "_on_play_audio")
	Events.connect("wire_cut", self, "_on_wire_cut")
	Events.connect("bomb_explode", self, "_on_bomb_explode")
	Events.connect("fade_from_dark_complete", self, "_on_fade_from_dark_complete")
	Events.connect("trigger_title_music", self, "_on_trigger_title_music")
	Events.connect("end_of_story", self, "_on_end_of_story")
	Events.connect("end_of_win", self, "_on_end_of_win")
	Events.connect("trigger_final_music", self, "_on_trigger_final_music")
	
func _exit():
	Events.disconnect("play_audio", self, "_on_play_audio")
	Events.disconnect("wire_cut", self, "_on_wire_cut")
	Events.disconnect("bomb_explode", self, "_on_bomb_explode")
	Events.disconnect("fade_from_dark_complete", self, "_on_fade_from_dark_complete")
	Events.disconnect("trigger_title_music", self, "_on_trigger_title_music")
	Events.disconnect("end_of_story", self, "_on_end_of_story")
	Events.disconnect("end_of_win", self, "_on_end_of_win")
	Events.disconnect("trigger_final_music", self, "_on_trigger_final_music")

func PlayGameplayNormal():
	if !GameplayNormal.playing:
		GameplayNormal.play()

func _on_play_audio(name):
	match name:
		"explosion":
			Explosion.play()
		"defuse":
			Defuse.play()
		"opendoor":
			OpenDoor.play()
		"cut":
			Cut.play()
		"navigate":
			Navigate.play()
		_:
			assert(false, "audio event does not exist")

func _on_wire_cut():
	Cut.play()
	
func _on_bomb_explode():
	GameplayNormal.stop()
	Explosion.play()

func _on_fade_from_dark_complete():
	if Global.state == STATE.CHANGING_LEVEL:
		PlayGameplayNormal()
	elif Global.state == STATE.RESTARTING_FROM_DEATH:
		PlayGameplayNormal()

func _on_end_of_story():
	Title.stop()

func _on_end_of_win():
	Title.stop()

func _on_trigger_title_music():
	Title.play()
	
func _on_trigger_final_music():
	GameplayNormal.stop()
	Title.play()
