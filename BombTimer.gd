extends Node2D

onready var timeDisplay : TileMap = get_node("Display/TimerDisplay")
onready var timer : Timer = $Timer

var m_fiveShowing = false
var m_fourShowing = false

func _ready():
	Events.connect("bomb_timer_start", self, "_on_bomb_timer_start")
	Events.connect("bomb_timer_pause", self, "_on_bomb_timer_pause")
	Events.connect("bomb_timer_stop", self, "_on_bomb_timer_stop")
	Events.connect("editmode_active", self, "_on_editmode_active")
	Events.connect("bomb_explode", self, "_on_bomb_explode")
	timer.set_one_shot(true)

func _exit():
	Events.disconnect("bomb_timer_start", self, "_on_bomb_timer_start")
	Events.discconnect("bomb_timer_pause", self, "_on_bomb_timer_pause")
	Events.discconnect("bomb_timer_stop", self, "_on_bomb_timer_stop")
	Events.disconnect("editmode_active", self, "_on_editmode_active")
	Events.disconnect("bomb_explode", self, "_on_bomb_explode")

func _process(_delta):
	var timeLeft = timer.get_time_left()
	var timeLeftMsec = timeLeft * 1000
	
	var fiveShowing = GetDigitShowing(timeLeftMsec, 5)
	if fiveShowing != m_fiveShowing:
		Events.emit_signal("timing_five_visibility_changed", fiveShowing)
		m_fiveShowing = fiveShowing
	var fourShowing = GetDigitShowing(timeLeftMsec, 4)
	if fourShowing != m_fourShowing:
		Events.emit_signal("timing_four_visibility_changed", fourShowing)
		m_fourShowing = fourShowing

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

func GetDigitShowing(timeLeft : int, digit : int):
	timeLeft += 1000 # time displayed is rounded up but calcs here are rounded down
	var msComp = timeLeft % 1000
	timeLeft = (timeLeft - msComp) / 1000
	
	var secComp = timeLeft % 60
	timeLeft = (timeLeft - secComp) / 60
	var minComp = timeLeft
	if minComp == digit: # assume that all puzzles are less than 10 minutes long
		return true
	var secOnes = secComp % 10
	if secOnes == digit:
		return true
	var secTens = (secComp - secOnes) / 10
	if secTens == digit:
		return true
	return false

func _on_bomb_timer_start(waitTime):
	InitTimeLeft(waitTime)
	StartTimer()
	
func _on_bomb_timer_pause(setPaused):
	if setPaused:
		PauseTimer()
	else:
		UnpauseTimer()
	
func _on_bomb_timer_stop():
	timer.stop()

func _on_bomb_explode():
	Events.emit_signal("bomb_timer_pause", true)
	
func _on_Timer_timeout():
	Events.emit_signal("bomb_explode")

func _on_editmode_active():
	#PauseTimer()
	#visible = false
	pass
