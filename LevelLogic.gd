extends Node2D

var wireLayer = preload("res://WireLayer.tscn")

onready var LevelData = $LevelData
onready var DebugOutput = $DebugOutput
onready var LevelSlotDisplay = $LevelSlot

enum Mode {
	IDLE
	WIRE_NEW 		#f1
	WIRE_DELETE		#f2
	WIRE_LAYERDOWN	#f3
	WIRE_LAYERUP	#f4
	SAVE_LEVEL		#f5
	LOAD_LEVEL		#f6
	WIRE_TYPE		#f7
}

var m_mode = Mode.IDLE
var m_wireLayers = []
var m_wireInProgress = null
var m_wireComplete = false

func _input(event):
	if event.is_action_pressed("debug_f1"):
		if m_mode == Mode.IDLE:
			SetMode(Mode.WIRE_NEW)
			var newWireLayer = wireLayer.instance()
			LevelData.add_child(newWireLayer)
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
				LevelData.remove_child(pickedWire)
				pickedWire.queue_free()
				SetMode(Mode.IDLE)
				m_wireLayers.pop_at(pickedIndex)
		elif m_mode == Mode.WIRE_LAYERDOWN:
			if pickedWire:
				var orderIndex = pickedWire.get_index()
				if orderIndex > 0:
					LevelData.move_child(pickedWire, orderIndex - 1)
		elif m_mode == Mode.WIRE_LAYERUP:
			if pickedWire:
				var orderIndex = pickedWire.get_index()
				if orderIndex < m_wireLayers.size():
					LevelData.move_child(pickedWire, orderIndex + 1)
		elif m_mode == Mode.WIRE_TYPE:
			if pickedWire:
				pickedWire.ChangeWireType()

func ResetLevel():
	m_wireLayers.clear()
	for child in LevelData.get_children():
		LevelData.remove_child(child)
		child.queue_free()

func SerializeLevelData():
	var levelData = {}
	levelData.wires = []
	for wire in LevelData.get_children():
		if wire.get_class() == "WireLayer":
			var wireData = wire.GetWireData()
			levelData.wires.push_back(wireData)
	return levelData

func UnserializeLevelData(levelData):
	for wireData in levelData.wires:
		var newWireLayer = wireLayer.instance()
		LevelData.add_child(newWireLayer)
		m_wireInProgress = newWireLayer
		m_wireLayers.push_back(newWireLayer)
		newWireLayer.SetWireData(wireData)

func SaveOrLoadLevel(num):
	if m_mode != Mode.SAVE_LEVEL and m_mode != Mode.LOAD_LEVEL:
		return
	
	var slot = str(num)
	if m_mode == Mode.SAVE_LEVEL:
		var levelData = SerializeLevelData()
		LevelJsonHelper.Save(slot, levelData)
	elif m_mode == Mode.LOAD_LEVEL:
		ResetLevel()
		var levelData = LevelJsonHelper.Load(slot)
		UnserializeLevelData(levelData)
	SetMode(Mode.IDLE)
	LevelSlotDisplay.text = slot

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