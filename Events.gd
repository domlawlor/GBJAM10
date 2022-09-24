extends Node

signal end_of_story()
signal end_of_win()
signal trigger_title_music()
signal trigger_final_music()

signal bomb_timer_start(waitTime)
signal bomb_timer_pause(setPaused)
signal bomb_timer_stop()
signal wire_cut()
signal bomb_explode()
signal bomb_puzzle_complete()

signal bomb_number_solved(bombNum)

signal timing_five_visibility_changed(showing)
signal timing_four_visibility_changed(showing)

signal select_bomb(bombNum, puzzleName)
signal reset_bombs(bombNumberToResetFrom)

signal view_bomb_puzzle(puzzleName)
signal hide_bomb_puzzle()

signal fade_to_dark_request()
signal fade_from_dark_request()
signal fade_to_dark_complete()
signal fade_from_dark_complete()

signal restart_from_death()

signal view_manual_page(pageNum)
signal hide_manual_page()

signal exit_level_door()
signal restart_game()

signal play_audio(name)

signal update_position(pos)
signal editmode_active()
