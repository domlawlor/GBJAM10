extends Node2D

var STATE = Global.State

export var start_level_num : int = 1
onready var current_level_num = start_level_num

var bombPuzzleScene = preload("res://BombPuzzle.tscn")

onready var debugMenu = $DebugLayer/Menu
onready var main_2d : Node2D = $Main2D
onready var puzzle_2d : Node2D = $UILayer/Puzzle2D
onready var BombPuzzle : Node2D = $UILayer/BombPuzzle
onready var PageOverlay : Node2D = $UILayer/PageOverlay
onready var bombTimer : Node2D = $UILayer/BombTimer
onready var paletteShader = $TopLayer/PaletteShader

var level_instance : Node2D
var puzzle_instance : Node2D

func _ready():
	Events.connect("fade_to_dark_complete", self, "_on_fade_to_dark_complete")
	Events.connect("exit_level_door", self, "_on_exit_level_door")
	Events.connect("bomb_explode", self, "_on_bomb_explode")
	Events.connect("restart_game", self, "_on_restart_game")
	
	SetResolution()
	puzzle_instance = bombPuzzleScene.instance()
	#load_level("Level1")

func _exit():
	Events.disconnect("fade_to_dark_complete", self, "_on_fade_to_dark_complete")
	Events.disconnect("exit_level_door", self, "_on_exit_level_door")
	Events.disconnect("bomb_explode", self, "_on_bomb_explode")

func _input(event):
	if !Global.InputActive:
		return
	
	if Global.state == STATE.TITLE:
		if event.is_action_pressed("gameboy_start") or event.is_action_pressed("gameboy_a"):
			Global.state = STATE.CHANGING_LEVEL
			current_level_num = 0 # this will increase to 1 at end of transition
			Events.emit_signal("fade_to_dark_request")
	
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
	debugMenu.visible = show

func _on_LoadLevel1_pressed():
	current_level_num = 1
	load_level("Level1")

func _on_LoadLevel2_pressed():
	current_level_num = 2
	load_level("Level2")

func _on_LoadLevel3_pressed():
	current_level_num = 3
	load_level("Level3")

func _on_LoadLevel4_pressed():
	current_level_num = 4
	load_level("Level4")

func _on_LoadPuzzle11_pressed():
	load_puzzle("1-1")
func _on_LoadPuzzle21_pressed():
	load_puzzle("2-1")
func _on_LoadPuzzle22_pressed():
	load_puzzle("2-2")
func _on_LoadPuzzle23_pressed():
	load_puzzle("2-3")
func _on_LoadPuzzle31_pressed():
	load_puzzle("3-1")
func _on_LoadPuzzle32_pressed():
	load_puzzle("3-2")
func _on_LoadPuzzle33_pressed():
	load_puzzle("3-3")
func _on_LoadPuzzle34_pressed():
	load_puzzle("3-4")
func _on_LoadPuzzle35_pressed():
	load_puzzle("3-5")
func _on_LoadPuzzle41_pressed():
	load_puzzle("4-1")
func _on_LoadPuzzle42_pressed():
	load_puzzle("4-2")
func _on_LoadPuzzle43_pressed():
	load_puzzle("4-3")
func _on_LoadPuzzle44_pressed():
	load_puzzle("4-4")
func _on_LoadPuzzle45_pressed():
	load_puzzle("4-5")	
func _on_LoadPuzzle46_pressed():
	load_puzzle("4-6")	
func _on_LoadPuzzle47_pressed():
	load_puzzle("4-7")	
func _on_LoadPuzzle48_pressed():
	load_puzzle("4-8")	

func _on_fade_to_dark_complete():
	if Global.state == STATE.RESTARTING_FROM_DEATH:
		bombTimer.visible = true # needed for coming from titles
		BombPuzzle.visible = false
		PageOverlay.visible = false
		
		Events.emit_signal("restart_from_death")
		Events.emit_signal("fade_from_dark_request")
		
	if Global.state == STATE.CHANGING_LEVEL:
		bombTimer.visible = true # needed for coming from titles
		BombPuzzle.visible = false
		PageOverlay.visible = false
		var levelExitedNum = current_level_num
		current_level_num += 1
	
		match levelExitedNum:
			0:
				load_level("Level1")
			1:
				load_level("Level2")
			2:
				load_level("Level3")
			3:
				load_level("Level4")
		Events.emit_signal("fade_from_dark_request")

func _on_bomb_explode():
	Global.state = STATE.EXPLOSION
	Global.InputActive = false

func _on_restart_game():
	paletteShader.SetInvert(false)
	Global.state = STATE.RESTARTING_FROM_DEATH
	_on_fade_to_dark_complete()

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
