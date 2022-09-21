extends Node2D

onready var sprite = $Sprite
onready var animationPlayer = $AnimationPlayer

func _ready():
	Events.connect("fade_to_dark_request", self, "_on_fade_to_dark_request")
	Events.connect("fade_from_dark_request", self, "_on_fade_from_dark_request")

func _exit():
	Events.disconnect("fade_to_dark_request", self, "_on_fade_to_dark_request")
	Events.disconnect("fade_from_dark_request", self, "_on_fade_from_dark_request")

func fade_to_dark_complete():
	Events.emit_signal("fade_to_dark_complete")

func dark_to_fade_complete():
	Events.emit_signal("dark_to_fade_complete")

func _on_fade_to_dark_request(pos):
	position = pos
	animationPlayer.play("NormToDark")

func _on_fade_from_dark_request(pos):
	position = pos
	animationPlayer.play("DarkToNorm")