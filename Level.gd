extends Node2D

# To be shared by all levels. Don't put anything level specific in here

var STATE = Global.State

onready var m_bombsNode : Node2D = $Bombs
onready var m_bombPuzzlesNode : Node2D = $BombPuzzles 
onready var m_bombTimer : Node2D = $BombTimer
onready var m_door : Sprite = $Door
onready var m_pageOverlay : Node2D = $PageOverlay

export var m_levelBombTimeSecond : float = 120.0 
var bombPuzzleScene = preload("res://BombPuzzle.tscn")

var m_bombsDefused : int = 0
var m_activePuzzle : Node2D = null
var m_activePageNum : int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	Events.connect("bomb_puzzle_complete", self, "_on_bomb_puzzle_complete")
	Events.connect("view_bomb_puzzle", self, "_on_view_bomb_puzzle")
	Events.connect("view_manual_page", self, "_on_view_manual_page")
	Events.connect("fade_to_dark_complete", self, "_on_fade_to_dark_complete")
	Events.connect("dark_to_fade_complete", self, "_on_dark_to_fade_complete")
	
	Events.emit_signal("bomb_timer_start", m_levelBombTimeSecond)
	
	# parse bombs for puzzle filenames and create puzzle instance for each
	assert(m_bombsNode, "Must have a Bombs node containing all bomb instances")
	for bomb in m_bombsNode.get_children():
		var puzzleName = bomb.puzzleName
		assert(!m_bombsNode.get_node(puzzleName), "Bomb with this puzzle already exists")
		
		var bombPuzzleInstance = bombPuzzleScene.instance()
		bombPuzzleInstance.name = puzzleName
		bombPuzzleInstance.m_bombOrderNumber = bomb.bombOrderNumber
		bombPuzzleInstance.visible = false
		bombPuzzleInstance.m_active = false
		m_bombPuzzlesNode.add_child(bombPuzzleInstance)

func _exit():
	Events.disconnect("bomb_puzzle_complete", self, "_on_bomb_puzzle_complete")
	Events.disconnect("view_bomb_puzzle", self, "_on_view_bomb_puzzle")
	Events.disconnect("view_manual_page", self, "_on_view_manual_page")
	Events.disconnect("fade_to_dark_complete", self, "_on_fade_to_dark_complete")
	Events.disconnect("dark_to_fade_complete", self, "_on_dark_to_fade_complete")

func _on_view_bomb_puzzle(puzzleName, pos):
	var puzzleNode = m_bombPuzzlesNode.get_node(puzzleName)
	assert(puzzleNode, "Puzzle does not exist")
	
	if puzzleNode.m_puzzleCompleted:
		return
	
	var nextBombToDefuse = m_bombsDefused
	
	if nextBombToDefuse != puzzleNode.m_bombOrderNumber:
		Events.emit_signal("bomb_explode")
	else:
		print("VIEW BOMB! puzzle=", puzzleName)
		Global.state = STATE.ENTERING_PUZZLE
		puzzleNode.position = pos
		puzzleNode.LoadRealPuzzle(puzzleName)
		m_activePuzzle = puzzleNode
		m_bombTimer.position = pos
		Events.emit_signal("fade_to_dark_request", pos)

func _on_fade_to_dark_complete():
	match (Global.state):
		STATE.ENTERING_PUZZLE:
			Global.state = STATE.PUZZLE
			m_activePuzzle.visible = true
			m_activePuzzle.m_active = true
			m_bombTimer.visible = true
			Events.emit_signal("fade_from_dark_request", m_activePuzzle.position)
		STATE.PUZZLE:
			Global.state = STATE.OVERWORLD
			assert(m_activePuzzle)
			m_activePuzzle.visible = false
			Events.emit_signal("fade_from_dark_request", m_activePuzzle.position)
			m_activePuzzle = null
			m_bombTimer.visible = false
			m_bombsDefused += 1
			if m_bombsDefused == m_bombPuzzlesNode.get_child_count():
				print("Level Complete!")
				Events.emit_signal("level_complete")
				m_door.OpenDoor()
		STATE.ENTERING_MANUAL:
			Global.state = STATE.MANUAL
			m_pageOverlay.ShowPage(m_activePageNum)
			Events.emit_signal("fade_from_dark_request", m_pageOverlay.position)
		STATE.MANUAL:
			Global.state = STATE.OVERWORLD
			m_pageOverlay.visible = false
			Events.emit_signal("fade_from_dark_request", m_pageOverlay.position)

func _on_view_manual_page(pageNum, pos):
	Global.state = STATE.ENTERING_MANUAL
	m_activePageNum = pageNum
	m_pageOverlay.position = pos
	Events.emit_signal("fade_to_dark_request", pos)
