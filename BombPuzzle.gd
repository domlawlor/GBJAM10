extends Node2D

var STATE = Global.State

var wireLayer = preload("res://WireLayer.tscn")

onready var WireLayers = $WireLayers
onready var GridHighlight = $GridHighlight
onready var Foreground = $Foreground
onready var Symbols = $Symbols
onready var DebugOutput = $DebugOutput
onready var LevelSlotDisplay = $LevelSlot

onready var ExitTimer = $ExitTimer

enum Mode {
	IDLE
	WIRE_NEW 		#f1
	WIRE_DELETE		#f2
	WIRE_LAYERDOWN	#f3
	WIRE_LAYERUP	#f4
	SAVE_LEVEL		#f5
	LOAD_LEVEL		#f6
	WIRE_TYPE		#f7
	WIRE_CUTORDER	#f9
	SYMBOL_EDIT		#f10
	GAMEPLAY		#f12
}

var m_mode = Mode.IDLE
var m_wireLayers = []
var m_highlightPos = Vector2.ZERO
var m_cutProgress = 0
var m_cutList = []
var m_currentCutIndex = 0

var m_timingVisibleFive : bool = false
var m_timingVisibleFour : bool = false

# editor
var m_wireInProgress = null
var m_wireComplete = false

func _ready():
	Events.connect("view_bomb_puzzle", self, "_on_view_bomb_puzzle")
	Events.connect("hide_bomb_puzzle", self, "_on_hide_bomb_puzzle")
	Events.connect("fade_to_dark_complete", self, "_on_fade_to_dark_complete")
	
	Events.connect("timing_five_visibility_changed", self, "_on_timing_five_visibility_changed")
	Events.connect("timing_four_visibility_changed", self, "_on_timing_four_visibility_changed")

	GridHighlight.visible = false
	GridHighlight.play("default")

func _exit():
	Events.disconnect("view_bomb_puzzle", self, "_on_view_bomb_puzzle")
	Events.disconnect("hide_bomb_puzzle", self, "_on_hide_bomb_puzzle")
	Events.disconnect("fade_to_dark_complete", self, "_on_fade_to_dark_complete")
	
	Events.disconnect("timing_five_visibility_changed", self, "_on_timing_five_visibility_changed")
	Events.disconnect("timing_four_visibility_changed", self, "_on_timing_four_visibility_changed")

func _on_view_bomb_puzzle(puzzleName):
	Global.state = STATE.ENTERING_PUZZLE
	LoadRealPuzzle(puzzleName)
	Events.emit_signal("fade_to_dark_request")

func _on_hide_bomb_puzzle():
	Events.emit_signal("fade_to_dark_request")

func _on_fade_to_dark_complete():
	match (Global.state):
		STATE.ENTERING_PUZZLE:
			Global.state = STATE.PUZZLE
			visible = true
			Events.emit_signal("fade_from_dark_request")
		STATE.PUZZLE:
			Global.state = STATE.OVERWORLD
			visible = false
			Events.emit_signal("fade_from_dark_request")

func _input(event):
	if event.is_action_pressed("debug_f12"):
		if m_mode == Mode.IDLE and m_wireLayers.size() > 0:
			StartGameplay()
		elif m_mode == Mode.GAMEPLAY:
			ReturnToEditMode()
	
	if !(Global.state == STATE.PUZZLE or Global.state == STATE.PUZZLE_EDIT) or !Global.InputActive:
		return
	
	if event.is_action_pressed("debug_f1"):
		if m_mode == Mode.IDLE:
			SetMode(Mode.WIRE_NEW)
			var newWireLayer = wireLayer.instance()
			WireLayers.add_child(newWireLayer)
			m_wireInProgress = newWireLayer
			m_wireLayers.push_back(newWireLayer)
		elif m_mode == Mode.WIRE_NEW and m_wireComplete:
			SetMode(Mode.IDLE)
			m_wireComplete = false
	
	elif event.is_action_pressed("debug_f2"):
		if m_mode == Mode.IDLE and m_wireLayers.size() > 0:
			SetMode(Mode.WIRE_DELETE)
		elif m_mode == Mode.WIRE_DELETE:
			SetMode(Mode.IDLE)
	
	elif event.is_action_pressed("debug_f3"):
		if m_mode == Mode.IDLE and m_wireLayers.size() > 1:
			SetMode(Mode.WIRE_LAYERDOWN)
		elif m_mode == Mode.WIRE_LAYERDOWN:
			SetMode(Mode.IDLE)
		
	elif event.is_action_pressed("debug_f4"):
		if m_mode == Mode.IDLE and m_wireLayers.size() > 1:
			SetMode(Mode.WIRE_LAYERUP)
		elif m_mode == Mode.WIRE_LAYERUP:
			SetMode(Mode.IDLE)
	
	elif event.is_action_pressed("debug_f5"):
		if m_mode == Mode.IDLE:
			SetMode(Mode.SAVE_LEVEL)
		elif m_mode == Mode.SAVE_LEVEL:
			SetMode(Mode.IDLE)
	
	elif event.is_action_pressed("debug_f6"):
		if m_mode == Mode.IDLE:
			SetMode(Mode.LOAD_LEVEL)
		elif m_mode == Mode.LOAD_LEVEL:
			SetMode(Mode.IDLE)
	
	elif event.is_action_pressed("debug_f7"):
		if m_mode == Mode.IDLE:
			SetMode(Mode.WIRE_TYPE)
		elif m_mode == Mode.WIRE_TYPE:
			SetMode(Mode.IDLE)
	
	elif event.is_action_pressed("debug_f9") or event.is_action_pressed("debug_wireOrder"):
		if m_mode == Mode.IDLE and m_wireLayers.size() > 0:
			SetMode(Mode.WIRE_CUTORDER)
			m_currentCutIndex = 0
			for child in WireLayers.get_children():
				child.SetCutIndex(-1)
		elif m_mode == Mode.WIRE_CUTORDER:
			SetMode(Mode.IDLE)
			CreateCutList()
	
	elif event.is_action_pressed("debug_f10"):
		if m_mode == Mode.IDLE:
			SetMode(Mode.SYMBOL_EDIT)
		elif m_mode == Mode.SYMBOL_EDIT:
			SetMode(Mode.IDLE)
	
	elif event.is_action_pressed("debug_numpad1"):
		SaveOrLoadLevel(1)
	elif event.is_action_pressed("debug_numpad2"):
		SaveOrLoadLevel(2)
	elif event.is_action_pressed("debug_numpad3"):
		SaveOrLoadLevel(3)
	elif event.is_action_pressed("debug_numpad4"):
		SaveOrLoadLevel(4)
	elif event.is_action_pressed("debug_numpad5"):
		SaveOrLoadLevel(5)
	elif event.is_action_pressed("debug_numpad6"):
		SaveOrLoadLevel(6)
	elif event.is_action_pressed("debug_numpad7"):
		SaveOrLoadLevel(7)
	elif event.is_action_pressed("debug_numpad8"):
		SaveOrLoadLevel(8)
	elif event.is_action_pressed("debug_numpad9"):
		SaveOrLoadLevel(9)
	
	elif event.is_action_pressed("debug_leftclick"):
		var localPos = to_local(event.position)
		var gridX = floor(localPos.x / Global.GRIDSIZE)
		var gridY = floor(localPos.y / Global.GRIDSIZE)
		var gridPos = Vector2(gridX, gridY)
		if not (gridX >= 0 and gridX < Global.LOGICGRID_WIDTH and gridY >= 0 and gridY < Global.LOGICGRID_HEIGHT):
			return
		
		var pickedWire = null
		var pickedIndex = -1
		for i in range(m_wireLayers.size()):
			var wire = m_wireLayers[i]
			if wire.IsWireAtPos(gridPos):
				pickedWire = wire
				pickedIndex = i
		
		if m_mode == Mode.WIRE_NEW:
			m_wireComplete = m_wireInProgress.PlaceWire(gridPos)
		elif m_mode == Mode.WIRE_DELETE:
			if pickedWire:
				WireLayers.remove_child(pickedWire)
				pickedWire.queue_free()
				SetMode(Mode.IDLE)
				m_wireLayers.pop_at(pickedIndex)
		elif m_mode == Mode.WIRE_LAYERDOWN:
			if pickedWire:
				var orderIndex = pickedWire.get_index()
				if orderIndex > 0:
					WireLayers.move_child(pickedWire, orderIndex - 1)
		elif m_mode == Mode.WIRE_LAYERUP:
			if pickedWire:
				var orderIndex = pickedWire.get_index()
				if orderIndex < m_wireLayers.size():
					WireLayers.move_child(pickedWire, orderIndex + 1)
		elif m_mode == Mode.WIRE_TYPE:
			if pickedWire:
				pickedWire.ChangeWireType()
		elif m_mode == Mode.WIRE_CUTORDER:
			if pickedWire and pickedWire.m_cutIndex == -1:
				var timing = -1
				if Input.is_action_pressed("debug_numpad5"):
					timing = 5
				elif Input.is_action_pressed("debug_numpad4"):
					timing = 4
				pickedWire.SetCutIndex(m_currentCutIndex, timing)
				m_currentCutIndex += 1
		elif m_mode == Mode.SYMBOL_EDIT:
			EditSymbol(gridPos, 1)
	
	elif event.is_action_pressed("debug_rightclick"):
		var localPos = to_local(event.position)
		var gridX = floor(localPos.x / Global.GRIDSIZE)
		var gridY = floor(localPos.y / Global.GRIDSIZE)
		var gridPos = Vector2(gridX, gridY)
		if not (gridX >= 0 and gridX < Global.LOGICGRID_WIDTH and gridY >= 0 and gridY < Global.LOGICGRID_HEIGHT):
			return

		if m_mode == Mode.SYMBOL_EDIT:
			EditSymbol(gridPos, -1)

	elif event.is_action_pressed("moveLeft"):
		if m_mode == Mode.GAMEPLAY:
			MoveHighlightLeft()
	elif event.is_action_pressed("moveRight"):
		if m_mode == Mode.GAMEPLAY:
			MoveHighlightRight()
	elif event.is_action_pressed("moveUp"):
		if m_mode == Mode.GAMEPLAY:
			MoveHighlightUp()
	elif event.is_action_pressed("moveDown"):
		if m_mode == Mode.GAMEPLAY:
			MoveHighlightDown()
	elif event.is_action_pressed("gameboy_a"):
		if m_mode == Mode.GAMEPLAY:
			CutWires()

func ResetLevel():
	m_wireLayers.clear()
	for child in WireLayers.get_children():
		WireLayers.remove_child(child)
		child.queue_free()

func SerializeLevelData():
	var levelData = {}
	levelData.wires = []
	for wire in WireLayers.get_children():
		if wire.get_class() == "WireLayer":
			var wireData = wire.GetWireData()
			levelData.wires.push_back(wireData)
	levelData.symbols = []
	for symbol in Symbols.get_children():
		var symbolData = {
			realPos = var2str(symbol.position),
			frame = symbol.frame,
		}
		levelData.symbols.push_back(symbolData)
	return levelData

func UnserializeLevelData(levelData):
	if !levelData:
		return 
		
	for wireData in levelData.wires:
		var newWireLayer = wireLayer.instance()
		WireLayers.add_child(newWireLayer)
		m_wireInProgress = newWireLayer
		m_wireLayers.push_back(newWireLayer)
		newWireLayer.SetWireData(wireData)
	CreateCutList()
	for symbolData in levelData.symbols:
		for symbol in Symbols.get_children():
			if str2var(symbolData.realPos) == symbol.position:
				symbol.frame = symbolData.frame

func SaveOrLoadLevel(num):
	if m_mode != Mode.SAVE_LEVEL and m_mode != Mode.LOAD_LEVEL:
		return
	
	var success = true
	
	var slot = str(num)
	if m_mode == Mode.SAVE_LEVEL:
		var levelData = SerializeLevelData()
		LevelJsonHelper.SaveDebug(slot, levelData)
	elif m_mode == Mode.LOAD_LEVEL:
		ResetLevel()
		var levelData = LevelJsonHelper.LoadDebug(slot)
		UnserializeLevelData(levelData)
		success = levelData != null
	SetMode(Mode.IDLE)
	
	if success:
		LevelSlotDisplay.text = slot
	else:
		LevelSlotDisplay.text = "!!!"

func EditSymbol(gridPos, move):
	for childSymbol in Symbols.get_children():
		if childSymbol.position  / Global.GRIDSIZE == gridPos:
			childSymbol.frame += move

func CreateCutList():
	m_cutList = []
	var currentIndex = 0
	var lookForNext = true
	while lookForNext:
		lookForNext = false
		var wiresToCut = []
		for wire in m_wireLayers:
			if wire.m_cutIndex == currentIndex:
				wiresToCut.append(wire)
				lookForNext = true
		currentIndex += 1
		if lookForNext:
			m_cutList.append(wiresToCut)

func LoadRealPuzzle(puzzleName):
	m_mode = Mode.LOAD_LEVEL
	ResetLevel()
	var levelData = LevelJsonHelper.Load(puzzleName)
	if levelData:
		UnserializeLevelData(levelData)
		StartGameplay()

func StartGameplay():
	m_mode = Mode.SAVE_LEVEL
	SaveOrLoadLevel("temp")
	m_mode = Mode.GAMEPLAY
	m_cutProgress = 0
	m_highlightPos = Vector2(1, 1)
	UpdateGridHighlightPos()
	Foreground.set_modulate(Color(1, 1, 1, 1))
	DebugOutput.visible = false
	LevelSlotDisplay.visible = false
	GridHighlight.visible = true

func ReturnToEditMode():
	Global.state = STATE.PUZZLE_EDIT
	Events.emit_signal("editmode_active")
	Foreground.set_modulate(Color(1, 1, 1, 0.5))
	DebugOutput.visible = true
	LevelSlotDisplay.visible = true
	GridHighlight.visible = false
	m_mode = Mode.LOAD_LEVEL
	SaveOrLoadLevel("temp")

func MoveHighlightLeft():
	if m_highlightPos.x > 1:
		m_highlightPos.x -= 1
		UpdateGridHighlightPos()

func MoveHighlightRight():
	if m_highlightPos.x < Global.HIGHLIGHTGRID_WIDTH:
		m_highlightPos.x += 1
		UpdateGridHighlightPos()

func MoveHighlightUp():
	if m_highlightPos.y > 1:
		m_highlightPos.y -= 1
		UpdateGridHighlightPos()

func MoveHighlightDown():
	if m_highlightPos.y < Global.HIGHLIGHTGRID_HEIGHT:
		m_highlightPos.y += 1
		UpdateGridHighlightPos()

func UpdateGridHighlightPos():
	GridHighlight.position = m_highlightPos * Global.GRIDSIZE

func CutWires():
	var explode = false
	var pickedWires = []
	for i in range(m_wireLayers.size()):
		var wire = m_wireLayers[i]
		if wire.IsWireAtPos(m_highlightPos):
			pickedWires.push_back(wire)
	var pickedWiresCount = pickedWires.size()
	if pickedWiresCount == 0:
		return
	
	var targetCuts = m_cutList[m_cutProgress]
	if pickedWiresCount != targetCuts.size():
		explode = true

	for j in range(pickedWiresCount):
		pickedWires[j].CutWire(m_highlightPos)
		var timing = pickedWires[j].GetCutTiming()
		if timing == 5 and !m_timingVisibleFive:
			explode = true
		elif timing == 4 and !m_timingVisibleFour:
			explode = true
		if !explode and pickedWires[j] != m_cutList[m_cutProgress][j]:
			explode = true
	
	if explode:
		Events.emit_signal("bomb_explode")
	else:
		m_cutProgress += 1
		if m_cutProgress == m_cutList.size():
			print("puzzle complete!")
			Events.emit_signal("play_audio", "defuse")
			ExitTimer.start()

func _on_ExitTimer_timeout():
	Events.emit_signal("bomb_puzzle_complete")
	Events.emit_signal("hide_bomb_puzzle")
	Events.emit_signal("fade_to_dark_request")

func SetMode(mode):
	if mode == m_mode:
		return
	
	m_mode = mode
	match mode:
		Mode.IDLE:
			DebugOutput.text = "IDLE"
		Mode.WIRE_NEW:
			DebugOutput.text = "WIRE_NEW"
		Mode.WIRE_DELETE:
			DebugOutput.text = "WIRE_DELETE"
		Mode.WIRE_LAYERDOWN:
			DebugOutput.text = "WIRE_LAYERDOWN"
		Mode.WIRE_LAYERUP:
			DebugOutput.text = "WIRE_LAYERUP"
		Mode.SAVE_LEVEL:
			DebugOutput.text = "SAVE SLOT?"
		Mode.LOAD_LEVEL:
			DebugOutput.text = "LOAD SLOT?"
		Mode.WIRE_TYPE:
			DebugOutput.text = "WIRE_TYPE"
		Mode.WIRE_CUTORDER:
			DebugOutput.text = "WIRE_CUTORDER"
		Mode.SYMBOL_EDIT:
			DebugOutput.text = "SYMBOL_EDIT"

func _on_timing_five_visibility_changed(showing : bool):
	m_timingVisibleFive = showing

func _on_timing_four_visibility_changed(showing : bool):
	m_timingVisibleFour = showing
