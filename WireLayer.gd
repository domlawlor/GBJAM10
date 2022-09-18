extends Node2D
class_name WireLayer

func get_class():
	return "WireLayer"

func is_class(value):
	return value == "WireLayer"

var sprite = preload("res://WireSprite.tscn")
var spriteTextureNormal = preload("res://Art/Wire_Light.png")
var spriteTextureCoated = preload("res://Art/Wire_Coated.png")

enum WireState {
	NONE
	WIRE
	CUTWIRE
}

enum DirFlags {
	LEFT = 1 << 0, # Bit 0
	RIGHT = 1 << 1, # Bit 1
	UP = 1 << 2, # Bit 2
	DOWN = 1 << 3, # Bit 3
}

enum WireType {
	NORMAL
	COATED
}

var m_grid = []
var m_gridSprites = []
var m_firstWirePlaced = false
var m_wirePath = []
var m_wireType = WireType.NORMAL
var m_cutIndex = -1 # -1 means don't cut

func _ready():
	for x in range(Global.LOGICGRID_WIDTH):
		m_grid.append([])
		m_gridSprites.append([])
		for y in range(Global.LOGICGRID_HEIGHT):
			m_grid[x].append(WireState.NONE)
			m_gridSprites[x].append(sprite.instance())
			var wireSprite = m_gridSprites[x][y]
			add_child(wireSprite)
			wireSprite.position.x = Global.GRIDSIZE * x
			wireSprite.position.y = Global.GRIDSIZE * y
			wireSprite.visible = false

func PlaceWire(targetPos):
	var x = targetPos.x
	var y = targetPos.y
	if !m_firstWirePlaced: # first wire placed has to be at an edge
		if !(x > 0 and x < Global.LOGICGRID_WIDTH-1 and y > 0 and y < Global.LOGICGRID_HEIGHT-1):
			m_firstWirePlaced = true
			m_wirePath.append(targetPos)
			m_grid[x][y] = WireState.WIRE
	else:
		var headPos = m_wirePath[m_wirePath.size()-1]
		var newPos = targetPos
		if newPos == headPos:
			m_grid[x][y] = WireState.NONE
			m_wirePath.pop_back()
			if m_wirePath.size() == 0:
				m_firstWirePlaced = false
		else:
			var validPositions = GetValidWirePositions(headPos)
			for pos in validPositions:
				if pos == newPos:
					m_wirePath.append(pos)
					m_grid[x][y] = WireState.WIRE
	var wireComplete = UpdateGraphics()
	return wireComplete

func CutWire(pos):
	assert(m_grid[pos.x][pos.y] != WireState.NONE)
	m_grid[pos.x][pos.y] = WireState.CUTWIRE
	UpdateGraphics()

func GetValidWirePositions(pos):
	var validPositions = []
	var x = pos.x
	var y = pos.y
	if x > 0:
		if m_grid[x-1][y] == WireState.NONE:
			validPositions.append(Vector2(x-1, y))
	if x < Global.LOGICGRID_WIDTH-1:
		if m_grid[x+1][y] == WireState.NONE:
			validPositions.append(Vector2(x+1, y))
	if y > 0:
		if m_grid[x][y-1] == WireState.NONE:
			validPositions.append(Vector2(x, y-1))
	if y < Global.LOGICGRID_HEIGHT-1:
		if m_grid[x][y+1] == WireState.NONE:
			validPositions.append(Vector2(x, y+1))
	return validPositions

func UpdateGraphics():
	var wireComplete = false
	for x in range(Global.LOGICGRID_WIDTH):
		for y in range(Global.LOGICGRID_HEIGHT):
			var spriteNode = m_gridSprites[x][y]
			spriteNode.visible = false
	var prevPos = null
	for i in m_wirePath.size():
		var currentPos = m_wirePath[i]
		var nextPos = null
		if i < m_wirePath.size()-1:
			nextPos = m_wirePath[i+1]

		var dirBit = 0
		var edgeDir = GetEdgeDir(currentPos)
		if !prevPos:
			dirBit |= edgeDir
		else:
			dirBit |= GetNextDir(currentPos, prevPos)
		if !nextPos:
			if edgeDir > 0:
				dirBit |= edgeDir
				wireComplete = true
		else:
			dirBit |= GetNextDir(currentPos, nextPos)

		prevPos = currentPos
		var x = currentPos.x
		var y = currentPos.y
		var spriteNode = m_gridSprites[x][y]
		spriteNode.visible = true

		var isCut = m_grid[x][y] == WireState.CUTWIRE
		spriteNode.frame = GetWireSpriteFrame(dirBit, isCut)
	return wireComplete

func GetEdgeDir(currentPos):
	var x = currentPos.x
	var y = currentPos.y
	if x == 0:
		return DirFlags.LEFT
	elif x == Global.LOGICGRID_WIDTH-1:
		return DirFlags.RIGHT
	if y == 0:
		return DirFlags.UP
	elif y == Global.LOGICGRID_HEIGHT-1:
		return DirFlags.DOWN
	else:
		return 0

func GetNextDir(currentPos, nextPos):
	if nextPos.x < currentPos.x:
		return DirFlags.LEFT
	if nextPos.x > currentPos.x:
		return DirFlags.RIGHT
	if nextPos.y < currentPos.y:
		return DirFlags.UP
	if nextPos.y > currentPos.y:
		return DirFlags.DOWN
	else:
		return 0

func GetWireSpriteFrame(dirBit, isCut):
	var left = (dirBit & DirFlags.LEFT) > 0
	var right = (dirBit & DirFlags.RIGHT) > 0
	var up = (dirBit & DirFlags.UP) > 0
	var down = (dirBit & DirFlags.DOWN) > 0
	
	var cutOffset = 6 if isCut else 0

	if left and right:
		return 0 + cutOffset
	elif up and down:
		return 1 + cutOffset
	elif left and down:
		return 2 + cutOffset
	elif left and up:
		return 3 + cutOffset
	elif right and down:
		return 4 + cutOffset
	elif right and up:
		return 5 + cutOffset
	elif left or right:
		return 0 + cutOffset
	else:
		return 1 + cutOffset

func ChangeWireType(forceType=null):
	var tex = null
	if forceType != null:
		m_wireType = forceType
	else:
		if m_wireType == WireType.NORMAL:
			m_wireType = WireType.COATED
		elif m_wireType == WireType.COATED:
			m_wireType = WireType.NORMAL
	
	if m_wireType == WireType.NORMAL:
		tex = spriteTextureNormal
	elif m_wireType == WireType.COATED:
		tex = spriteTextureCoated
	
	for x in range(Global.LOGICGRID_WIDTH):
		for y in range(Global.LOGICGRID_HEIGHT):
			m_gridSprites[x][y].texture = tex
	UpdateGraphics()

func SetCutIndex(i):
	m_cutIndex = i

func IsWireAtPos(pos):
	return m_grid[pos.x][pos.y] != WireState.NONE		

func GetWireData():
	var wireStrArray = []
	for wirePos in m_wirePath:
		var wirePosStr = var2str(wirePos)
		wireStrArray.push_back(wirePosStr)
	return {
		"wireType" : var2str(m_wireType),
		"wirePath" : wireStrArray,
		"cutIndex" : var2str(m_cutIndex),
	}

func SetWireData(wireData):
	m_wireType = str2var(wireData.wireType)
	ChangeWireType(m_wireType)
	m_cutIndex = str2var(wireData.cutIndex)
	for wirePosStr in wireData.wirePath:
		var wirePos = str2var(wirePosStr)
		PlaceWire(wirePos)
