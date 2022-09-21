extends Node

signal bomb_timer_start(waitTime)
signal bomb_timer_pause(setPaused)
signal bomb_timer_stop()
signal bomb_explode()
signal bomb_puzzle_complete()

signal timing_two_visibility_changed(showing)
signal timing_four_visibility_changed(showing)

signal select_bomb(bombNum, puzzleName)

signal view_bomb_puzzle(puzzleName)
signal hide_bomb_puzzle()

signal fade_to_dark_request()
signal fade_from_dark_request()
signal fade_to_dark_complete()
signal dark_to_fade_complete()

signal view_manual_page(pageNum)
signal hide_manual_page()

signal exit_level_door()

signal update_position(position)
signal editmode_active()
