extends Node2D

# To be shared by all levels. Don't put anything level specific in here

var STATE = Global.State

onready var m_bombsNode : Node2D = $Bombs
onready var m_door : Sprite = $Door

export var m_levelBombTimeSecond : float = 120.0 

var m_nextBombNum : int = 0
var m_bombTotalCount : int = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	Events.connect("select_bomb", self, "_on_select_bomb")
	Events.connect("bomb_puzzle_complete", self, "_on_bomb_puzzle_complete")
	
	Events.connect("fade_to_dark_complete", self, "_on_fade_to_dark_complete")
	Events.connect("fade_from_dark_complete", self, "_on_fade_from_dark_complete")
	
	Events.emit_signal("bomb_timer_start", m_levelBombTimeSecond)
	
	m_bombTotalCount = m_bombsNode.get_child_count()

func _exit():
	Events.disconnect("bomb_puzzle_complete", self, "_on_bomb_puzzle_complete")
	Events.disconnect("select_bomb", self, "_on_select_bomb")
	Events.disconnect("view_bomb_puzzle", self, "_on_view_bomb_puzzle")
	
	Events.disconnect("fade_to_dark_complete", self, "_on_fade_to_dark_complete")
	Events.disconnect("fade_from_dark_complete", self, "_on_fade_from_dark_complete")

func _on_select_bomb(bombNum, puzzleName):
	if bombNum < m_nextBombNum:
		# already completed this bomb, move on
		return
	elif bombNum != m_nextBombNum: # not the right order, explode
		Events.emit_signal("bomb_explode")
	else:
		print("VIEW BOMB! puzzle=", puzzleName)
		Events.emit_signal("view_bomb_puzzle", puzzleName)
		

func _on_bomb_puzzle_complete():
	var bombNumSolved = m_nextBombNum
	Events.emit_signal("bomb_number_solved", bombNumSolved)
	
	m_nextBombNum += 1
	if m_nextBombNum == m_bombTotalCount:
		print("Level Complete!")
		Events.emit_signal("bomb_timer_pause", true)
		m_door.OpenDoor()

func _on_fade_from_dark_complete():
	if Global.state == STATE.CHANGING_LEVEL:
		Global.state = STATE.OVERWORLD

