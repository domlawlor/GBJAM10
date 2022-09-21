extends Node2D

onready var textNode : RichTextLabel = $RichTextLabel

var pagesText = {
	0 : """Test page text""",
	1 : """\n\n\nThose who have but one path to choose shall fear not the reaper\n\nAnd remember, the vigilant servants of heaven will always take action before the sinful prisoners of hell""",
	2 : """\n\nOn the first day, god created the light and destroyed the sun\n\nOn the second day, god created the sky and destroyed the moon\n\nOn the third day, god created the plants and destroyed the stars""",
	3: """\nThe path to righteousness begins in the light and ends in darkness\n\nThose touched by the book of god shall remain unsullied\n\nBut the lord can be petulant. Be there no sacrifices offered, He shall crush the heart of life""",
	4: """\n\n\nWhen the path is unclear, salvation is found moving backwards through time\n\n\nAs the suns holy light covered the entire land, Gods divine rays blinded those that see""",
	5: """\n\n\nWhen the devil saw two, he bore his wroth upon the almighty Hand of God\n\nAnd then when the devil saw four, the forces of madness compelled him to sever his own weapon in twain""",
}

func _ready():
	Events.connect("view_manual_page", self, "_on_view_manual_page")
	Events.connect("hide_manual_page", self, "_on_hide_manual_page")
	Events.connect("fade_to_dark_complete", self, "_on_fade_to_dark_complete")
	assert(textNode)

func _exit():
	Events.disconnect("view_manual_page", self, "_on_view_manual_page")
	Events.disconnect("hide_manual_page", self, "_on_hide_manual_page")
	Events.disconnect("fade_to_dark_complete", self, "_on_fade_to_dark_complete")

func _process(delta):
	if Global.state != Global.State.MANUAL or !Global.InputActive:
		return
	
	if Input.is_action_just_pressed("gameboy_a") or Input.is_action_just_pressed("gameboy_b"):
		Events.emit_signal("hide_manual_page")

func SelectPage(pageNum):
	assert(pageNum < pagesText.size())
	var pageText = pagesText[pageNum]
	
	textNode.text = ""
	
	var BBCODE_CENTER = "[center]"
	textNode.bbcode_text = BBCODE_CENTER + pageText
	
	
func _on_view_manual_page(pageNum):
	Global.state = Global.State.ENTERING_MANUAL
	SelectPage(pageNum)
	Events.emit_signal("fade_to_dark_request")

func _on_hide_manual_page():
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

