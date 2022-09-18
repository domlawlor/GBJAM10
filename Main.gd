extends Node2D

var bombPuzzleScene = preload("res://BombPuzzle.tscn")

onready var levelList : VBoxContainer = $Menu/LevelList
onready var puzzleList : VBoxContainer = $Menu/PuzzleList
onready var main_2d : Node2D = $Main2D
onready var puzzle_2d : Node2D = $Puzzle2D

var level_instance : Node2D
var puzzle_instance : Node2D

func _ready():
	Events.connect("view_bomb", self, "_on_view_bomb")
	Events.connect("bomb_puzzle_complete", self, "_on_bomb_puzzle_complete")
	

	SetResolution()
	puzzle_instance = bombPuzzleScene.instance()
	#load_level("Level1")

func _exit():
	pass

func _on_view_bomb():
	Global.activeBombPuzzle.visible = true

func _on_bomb_puzzle_complete():
	Global.activeBombPuzzle.visible = false

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		unload_level()
		unload_puzzle()
		SetDebugMenuVisibility(true)

func SetResolution():
	var native_screen = OS.get_screen_size()
	var max_scale_x = floor(native_screen.x / Global.LOGICAL_RES.x)
	var max_scale_y = floor(native_screen.y / Global.LOGICAL_RES.y)
	Global.SCALE = 4#min(max_scale_x, max_scale_y)

	var scaled_window = Vector2(Global.LOGICAL_RES.x * Global.SCALE, Global.LOGICAL_RES.y * Global.SCALE)
	OS.set_window_size(scaled_window)

func unload_level():
	if (is_instance_valid(level_instance)):
		level_instance.queue_free()
		main_2d.call_deferred("remove_child", level_instance)
	level_instance = null

func load_level(level_name : String):
	unload_level()
	
	var level_path := "res://Levels/%s.tscn" % level_name
	var level_resource := load(level_path)
	if (level_resource):
		level_instance = level_resource.instance()
		main_2d.call_deferred("add_child", level_instance)
		SetDebugMenuVisibility(false)

func unload_puzzle():
	if (is_instance_valid(puzzle_instance)):
		puzzle_2d.call_deferred("remove_child", puzzle_instance)

func load_puzzle(level_name : String):
	unload_level()
	puzzle_2d.add_child(puzzle_instance)
	puzzle_instance.LoadRealPuzzle(level_name)
	SetDebugMenuVisibility(false)
	
func SetDebugMenuVisibility(show : bool):
	levelList.visible = show
	puzzleList.visible = show

func _on_LoadLevel1_pressed():
	load_level("Level1")

func _on_LoadLevel2_pressed():
	load_level("Level2")

func _on_LoadPuzzle11_pressed():
	load_puzzle("1-1")

# func _on_level_exited(num):
# 	match num:
# 		0:
# 			load_level("Level1")
# 		1:
# 			load_level("Level2")
# 		2:
# 			load_level("Level3")

# func _on_restart_game():
# 	timeLimit.stop()
# 	load_level("LevelTitle")

# func _on_start_game():
# 	StartGame()
	
# func StartGame():
# 	Global.WinTime = 0.0
# 	Global.DustCleaned = 0
# 	Global.NumberOfSweeps = 0
# 	animationPlayer.play("RESET")
# 	load_level("Level0")
# 	Events.emit_signal("start_time_limit")


# func _on_start_time_limit():
# 	timeLimit.start(TotalTimeLimitSec)
# 	Global.gameState = Global.GameState.PLAYING
	
# func _on_TimeLimit_timeout():
# 	Global.gameState = Global.GameState.DEAD
# 	Events.emit_signal("hit_time_limit")

# func TriggerPlayerDeathAnimation():
# 	Events.emit_signal("player_death_animation")

# func AllowRestartInput():
# 	Global.gameState = Global.GameState.BLOCKING_RESTART

# func _on_win_game():
# 	Global.WinTime = timeLimit.wait_time - timeLimit.time_left
# 	timeLimit.stop()

# func _on_show_death_screen():
# 	animationPlayer.play("deathScreen")
# 	timeLimit.stop()

# # sfx
# func _on_sfx_sweep():
# 	$SFX/Sweep.play()

# func _on_sfx_janitorStart():
# 	var r = randi() % 3
# 	if r == 0:
# 		$SFX/JanitorStart01.play()
# 	elif r == 1:
# 		$SFX/JanitorStart02.play()
# 	else:
# 		$SFX/JanitorStart03.play()

# func _on_sfx_grunt():
# 	var r = randi() % 4
# 	if r == 0:
# 		$SFX/JanitorGrunt01.play()
# 	elif r == 1:
# 		$SFX/JanitorGrunt02.play()
# 	elif r == 2:
# 		$SFX/JanitorGrunt03.play()
# 	else:
# 		$SFX/JanitorGrunt04.play()

# func _on_sfx_death():
# 	var r = randi() % 2
# 	if r == 0:
# 		$SFX/JanitorDeath01.play()
# 	elif r == 1:
# 		$SFX/JanitorDeath02.play()
