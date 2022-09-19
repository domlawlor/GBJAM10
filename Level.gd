extends Node2D

# To be shared by all levels. Don't put anything level specific in here

onready var m_bombPuzzles : Node = $BombPuzzles 

var m_puzzleNodes = null
var m_puzzlesCompleted : int = 0

var m_activePuzzle : Node2D = null

# Called when the node enters the scene tree for the first time.
func _ready():
	Events.connect("bomb_puzzle_complete", self, "_on_bomb_puzzle_complete")
	
	Events.connect("view_bomb_puzzle", self, "_on_view_bomb_puzzle")
	
	# parse puzzles from tree
	assert(m_bombPuzzles, "Must have a BombPuzzles child containing all the puzzles for this level")
	m_puzzleNodes = m_bombPuzzles.get_children()

func _exit():
	Events.disconnect("bomb_puzzle_complete", self, "_on_bomb_puzzle_complete")


func _on_bomb_puzzle_complete():
	assert(m_puzzleNodes)
	
	m_activePuzzle.visible = false
	m_activePuzzle = null
	
	m_puzzlesCompleted += 1
	if m_puzzlesCompleted == m_puzzleNodes.size():
		print("Level Complete!")
		Events.emit_signal("level_complete")
		


func _on_view_bomb_puzzle(puzzleName):
	#find existing or first unused puzzle slot
	for puzzleNode in m_puzzleNodes:
		if !puzzleNode.m_loadedPuzzleName or puzzleName == puzzleNode.m_loadedPuzzleName:
			puzzleNode.LoadRealPuzzle(puzzleName)
			puzzleNode.visible = true
			m_activePuzzle = puzzleNode
			return
	assert(false, "If we reach here, not enough puzzles for all the bombs!")

