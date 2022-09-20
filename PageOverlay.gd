extends Node2D

onready var textNode : RichTextLabel = get_node("Control/RichTextLabel") 
onready var textNode2 : RichTextLabel = get_node("Control/RichTextLabel2") 

var m_textPagesToShowTotal : int = 1
var m_currentPageNum : int = 1

var pagesText = {
	0 : ["""Test page text"""],
	1 : ["""Those who have but one path to choose shall fear not the reaper\n\n
	And have faith that the vigilant servants of heaven will always 
	take action before the slothful prisoners of hell"""],
	2 : ["""On the first day, god created the light and destroyed the sun\n\n
	On the second day, god created the sky and destroyed the moon\n\n
	On the third day, god created the plants and destroyed the stars"""],
	3: ["""The path to righteousness begins in the light and ends in darkness\n\n
	Those touched by the book of god shall remain unsullied\n\n
	But all shall remain vigilant. Be there no sacrifices offered the lord shall stop the heart of life"""],
	4: ["""When the path is unclear, salvation is found moving backwards through time\n
	As the suns holy light covered the entire land, Gods divine judgement blinded the demonic eye\n""",
	"""When the devil saw two, he bore his wroth upon the almighty Hand of God\n
	And then when the devil saw four, the forces of madness compelled him to sever his own weapon in twain"""],
}

func _ready():
	visible = false
	textNode.visible = false
	textNode2.visible = false

func _process(delta):
	# Early exit if not visible
	if !visible:
		return
	
	if Input.is_action_just_pressed("gameboy_b"):
		if m_currentPageNum == m_textPagesToShowTotal:
			visible = false
			Events.emit_signal("set_overworld_paused", false)
		else:
			textNode.visible = false
			textNode2.visible = true
			m_currentPageNum += 1

func ShowPage(pageNum):
	assert(pageNum < pagesText.size())
	var pageTextArray = pagesText[pageNum]
	
	Events.emit_signal("set_overworld_paused", true)

	m_textPagesToShowTotal = pageTextArray.size()
	m_currentPageNum = 1
	
	assert(m_textPagesToShowTotal > 0 and m_textPagesToShowTotal <= 2)
	
	visible = true
	
	textNode.text = pageTextArray[0]
	textNode.visible = true
	
	if m_textPagesToShowTotal > 1:
		textNode2.text = pageTextArray[1]
		textNode2.visible = false

