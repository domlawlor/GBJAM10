extends Control

onready var timeDisplay : TileMap = $TimerDisplay
onready var timer : Timer = $Timer

func _ready():
	timer.set_one_shot(true)
	
	var timeSeconds = 30
	InitTimeLeft(timeSeconds)
	StartTimer()

func _process(delta):
	var timeLeft = timer.get_time_left()
	var timeLeftMsec = timeLeft * 1000
	
	var timeLeftString = Global.MSecToTimeString(timeLeftMsec, false)
	timeDisplay.SetTimerText(timeLeftString)

func InitTimeLeft(time):
	assert(timer.is_stopped(), "Stop timer before setting new one")
	timer.set_wait_time(time)

func StartTimer():
	UnpauseTimer()
	timer.start()

func PauseTimer():
	timer.set_paused(true)

func UnpauseTimer():
	timer.set_paused(false)

func _on_Timer_timeout():
	Events.emit_signal("bomb_timer_finished")
