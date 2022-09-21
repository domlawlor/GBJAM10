extends Node

signal bomb_timer_start(waitTime)
signal bomb_explode()
signal bomb_puzzle_complete()

signal timing_two_visibility_changed(showing)
signal timing_four_visibility_changed(showing)

signal view_bomb_puzzle(puzzleName, pos)

signal fade_to_dark_request(pos)
signal fade_from_dark_request(pos)
signal fade_to_dark_complete()
signal dark_to_fade_complete()

signal view_manual_page(pageNum, pos)
signal exit_manual_page()

signal exit_level_door()

signal set_overworld_paused(isPaused)

signal editmode_active()
