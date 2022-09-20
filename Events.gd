extends Node

signal bomb_timer_start(waitTime)
signal bomb_explode()
signal bomb_puzzle_complete()

signal timing_two_visibility_changed(showing)
signal timing_four_visibility_changed(showing)

signal view_bomb_puzzle(puzzleName, position)

signal view_manual_page(pageNum, position)
signal exit_manual_page()

signal exit_level_door()

signal set_overworld_paused(isPaused)

signal editmode_active()
