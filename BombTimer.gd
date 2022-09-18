extends Control

onready var timeDisplay : TileMap = $TimerDisplay
onready var timer : Timer = $Timer

func _ready():
	Events.connect("bomb_timer_start", self, "_on_bomb_timer_start")
	Events.connect("editmode_active", self, "_on_editmode_active")
	timer.set_one_shot(true)
	visible = false

func _process(delta):
	var timeLeft = timer.get_time_left()
	var timeLeftMsec = timeLeft * 1000
	
	var timeLeftString = Global.MSecToTimeString(timeLeftMsec, false)
	timeDisplay.SetTimerText(timeLeftString)

func InitTimeLeft(time):
	if !timer.is_stopped():
		timer.stop()
	timer.set_wait_time(time)

func StartTimer():
	UnpauseTimer()
	timer.start()

func PauseTimer():
	timer.set_paused(true)

func UnpauseTimer():
	timer.set_paused(false)

func _on_bomb_timer_start(waitTime):
	InitTimeLeft(waitTime)
	StartTimer()
	visible = true

func _on_Timer_timeout():
	Events.emit_signal("bomb_explode")

func _on_editmode_active():
	PauseTimer()
	visible = false
