extends Node2D

# To be shared by all levels. Don't put anything level specific in here

onready var m_bombsNode : Node2D = $Bombs
onready var m_bombPuzzlesNode : Node2D = $BombPuzzles 
onready var m_bombTimer : Node2D = $BombTimer
onready var m_door : Sprite = $Door

export var m_levelBombTimeSecond : float = 120.0 

var bombPuzzleScene = preload("res://BombPuzzle.tscn")

var m_bombsDefused : int = 0

var m_activePuzzle : Node2D = null

# Called when the node enters the scene tree for the first time.
func _ready():
	Events.connect("bomb_puzzle_complete", self, "_on_bomb_puzzle_complete")
	Events.connect("view_bomb_puzzle", self, "_on_view_bomb_puzzle")
	
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
		m_bombPuzzlesNode.add_child(bombPuzzleInstance)

func _exit():
	Events.disconnect("bomb_puzzle_complete", self, "_on_bomb_puzzle_complete")
	Events.disconnect("view_bomb_puzzle", self, "_on_view_bomb_puzzle")

func _on_bomb_puzzle_complete():
	assert(m_activePuzzle)
	
	m_activePuzzle.visible = false
	m_activePuzzle = null
	
	m_bombTimer.visible = false
	
	m_bombsDefused += 1
	if m_bombsDefused == m_bombPuzzlesNode.get_child_count():
		print("Level Complete!")
		Events.emit_signal("level_complete")
		m_door.OpenDoor()
	else:
		Events.emit_signal("set_overworld_paused", false)


func _on_view_bomb_puzzle(puzzleName, position):
	var puzzleNode = m_bombPuzzlesNode.get_node(puzzleName)
	assert(puzzleNode, "Puzzle does not exist")
	
	if puzzleNode.m_puzzleCompleted:
		return
	
	var nextBombToDefuse = m_bombsDefused
	
	if nextBombToDefuse != puzzleNode.m_bombOrderNumber:
		Events.emit_signal("bomb_explode")
	else:
		print("VIEW BOMB! puzzle=", puzzleName)
		Events.emit_signal("set_overworld_paused", true)
		puzzleNode.position = position
		puzzleNode.LoadRealPuzzle(puzzleName)
		puzzleNode.visible = true
		
		m_activePuzzle = puzzleNode
		
		m_bombTimer.position = position
		m_bombTimer.visible = true
		
		
