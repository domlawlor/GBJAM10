extends Node2D

onready var textNode : RichTextLabel = $RichTextLabel
onready var pageNumTextLabel : RichTextLabel = $PageNumLabel

var pagesText = {
	0 : """\n\n\nThose who have but one path to choose shall fear not the reaper\n\nAnd remember, the vigilant servants of heaven will always take action before the sinful prisoners of hell""",
	1 : """\n\nOn the first day, god created the light and destroyed the sun\n\nOn the second day, god created the sky and destroyed the moon\n\nOn the third day, god created the plants and destroyed the stars""",
	2: """\nThe path to righteousness begins in the light and ends in darkness\n\nThose touched by the book of god shall remain unsullied\n\nBut the lord can be petulant. Be there no sacrifices offered, He shall crush the heart of life""",
	3: """\n\n\nWhen the path is unclear, salvation is found moving backwards through time\n\n\nAs the suns holy light covered the entire land, Gods divine rays blinded those that see""",
	4: """\n\n\nWhen the devil saw two, he bore his wroth upon the almighty Hand of God\n\nAnd then when the devil saw four, the forces of madness compelled him to sever his own weapon in twain""",
}

var m_unlockedPages = []
var m_inPauseMenu : bool = false
var m_pauseMenuPageNum : int = 0

func _ready():
	Events.connect("clear_unlocked_pages", self, "_on_clear_unlocked_pages")
	Events.connect("unlock_pages_for_level_num", self, "_on_unlock_pages_for_level_num")
	Events.connect("show_pause_manual", self, "_on_show_pause_manual")
	
	Events.connect("view_manual_page", self, "_on_view_manual_page")
	Events.connect("hide_manual_page", self, "_on_hide_manual_page")
	Events.connect("fade_to_dark_complete", self, "_on_fade_to_dark_complete")
	assert(textNode)

func _exit():
	Events.disconnect("clear_unlocked_pages", self, "_on_clear_unlocked_pages")
	Events.disconnect("unlock_pages_for_level_num", self, "_on_unlock_pages_for_level_num")
	Events.disconnect("show_pause_manual", self, "_on_show_pause_manual")
	
	Events.disconnect("view_manual_page", self, "_on_view_manual_page")
	Events.disconnect("hide_manual_page", self, "_on_hide_manual_page")
	Events.disconnect("fade_to_dark_complete", self, "_on_fade_to_dark_complete")

func _process(delta):
	if Global.state != Global.State.MANUAL or !Global.InputActive:
		return
	
	if m_inPauseMenu:
		if Input.is_action_just_pressed("gameboy_start"):
			Events.emit_signal("hide_manual_page")
		elif Input.is_action_just_pressed("gameboy_a"):
			m_pauseMenuPageNum += 1
			if m_pauseMenuPageNum == m_unlockedPages.size():
				Events.emit_signal("hide_manual_page")
			else:
				SelectPage(m_pauseMenuPageNum)
	else:
		if Input.is_action_just_pressed("gameboy_a"):
			Events.emit_signal("hide_manual_page")

func SelectPage(pageNum):
	assert(pageNum < pagesText.size())
	var pageText = pagesText[pageNum]
	
	textNode.text = ""
	
	var BBCODE_CENTER = "[center]"
	textNode.bbcode_text = BBCODE_CENTER + pageText
	
	if m_inPauseMenu:
		pageNumTextLabel.text = str(pageNum+1) + "/" + str(m_unlockedPages.size())
	else:
		pageNumTextLabel.text = ""

func _on_clear_unlocked_pages():
	m_unlockedPages.clear()

func UnlockPage(pageNum):
	if !m_unlockedPages.has(pageNum):
		m_unlockedPages.push_back(pageNum)

func _on_unlock_pages_for_level_num(levelNum):
	if levelNum > 1:
		UnlockPage(0)
	if levelNum > 2:
		UnlockPage(1)
	if levelNum > 3:
		UnlockPage(2)
	if levelNum > 4:
		UnlockPage(3)
		UnlockPage(4)

func _on_show_pause_manual():
	if m_unlockedPages.size() > 0:
		m_inPauseMenu = true
		m_pauseMenuPageNum = 0
		Events.emit_signal("view_manual_page", m_pauseMenuPageNum)

func _on_view_manual_page(pageNum):
	UnlockPage(pageNum)
	
	Global.state = Global.State.ENTERING_MANUAL
	SelectPage(pageNum)
	Events.emit_signal("fade_to_dark_request")

func _on_hide_manual_page():
	m_inPauseMenu = false
	m_pauseMenuPageNum = 0
	Events.emit_signal("fade_to_dark_request")

func _on_fade_to_dark_complete():
	match (Global.state):
		Global.State.ENTERING_MANUAL:
			Global.state = Global.State.MANUAL
			visible = true
			Events.emit_signal("fade_from_dark_request")
		Global.State.MANUAL:
			Global.state = Global.State.OVERWORLD
			visible = false
			Events.emit_signal("fade_from_dark_request")

