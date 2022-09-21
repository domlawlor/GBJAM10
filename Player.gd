extends KinematicBody2D

signal update_position(pos)

onready var animatedSprite : AnimatedSprite = $PixelLockedSprite

onready var camera : Camera2D = $Camera2D

const SpriteSizeX = 16
const SpriteSizeY = 16

var VELOCITY_X : float = 65.0
var VELOCITY_Y : float = 65.0

enum FaceDir {
	UP,
	DOWN,
	LEFT,
	RIGHT
}

var m_frozen : bool = false
var m_justUnfrozen = false # quick 1 frame delay fix for stopping input hitting page/bomb and overworld
var m_vel : Vector2 = Vector2.ZERO
var m_faceDir = FaceDir.DOWN

enum InteractNodeType {
	NONE,
	BOMB,
	PAGE
}

var m_nearbyInteractNode : Node2D = null
var m_nearbyInteractType = InteractNodeType.NONE

func _ready():
	Events.connect("set_overworld_paused", self, "_on_set_overworld_paused")
	Events.connect("fade_to_dark_request", self, "_on_fade_to_dark_request")
	
	assert(camera, "a level camera must be a child of player")
	camera.make_current()
	
	set_process_input(true)
	animatedSprite.set_animation("down")

func _exit():
	Events.disconnect("set_overworld_paused", self, "_on_set_overworld_paused")
	Events.disconnect("fade_to_dark_request", self, "_on_fade_to_dark_request")

func _on_set_overworld_paused(isPaused):
	m_frozen = isPaused
	m_justUnfrozen = !isPaused

func _on_fade_to_dark_request():
	m_frozen = true

func _physics_process(delta):
	if m_frozen:
		return

	if m_justUnfrozen:
		m_justUnfrozen = false
		return

	m_vel = Vector2.ZERO

	if Input.is_action_just_pressed("gameboy_a"):
		InteractPressed()

	if Input.is_action_pressed("moveLeft"):
		m_vel.x = -VELOCITY_X
		m_faceDir = FaceDir.LEFT
		animatedSprite.set_animation("left")
	elif Input.is_action_pressed("moveRight"):
		m_vel.x = VELOCITY_X
		m_faceDir = FaceDir.RIGHT
		animatedSprite.set_animation("right")
	elif Input.is_action_pressed("moveUp"):
		m_vel.y = -VELOCITY_Y
		m_faceDir = FaceDir.UP
		animatedSprite.set_animation("up")
	elif Input.is_action_pressed("moveDown"):
		m_vel.y = VELOCITY_Y
		animatedSprite.set_animation("down")
		m_faceDir = FaceDir.DOWN
	else:
		m_vel.x = 0
		m_vel.y = 0

	if m_vel.length() > 0:
		animatedSprite.play()
	else:
		animatedSprite.stop()
		animatedSprite.set_frame(0) # set to default idle frame for facing direction

	move_and_collide(m_vel * delta)

	emit_signal("update_position", position)

func SetInteractNode(node, nodeType):
	if m_nearbyInteractNode:
		print("SetInteractNode - clearing a set m_nearbyInteractNode, shoud been cleared first. Or Node too close to another?")
		m_nearbyInteractNode = null

	m_nearbyInteractNode = node
	m_nearbyInteractType = nodeType

func ClearInteractNode(node):
	if node != m_nearbyInteractNode:
		print("ClearInteractNode - passed wrong active m_nearbyInteractNode to clear - active=", m_nearbyInteractNode, ", tryingToClear=", node)
		return
	m_nearbyInteractNode = null

func SetNearbyBomb(bomb: Node2D):
	SetInteractNode(bomb, InteractNodeType.BOMB)

func SetNearbyBookPage(bookPage : Node2D):
	SetInteractNode(bookPage, InteractNodeType.PAGE)

func ClearNearbyBomb(bomb: Node2D):
	ClearInteractNode(bomb)

func ClearNearbyBookPage(bookPage : Node2D):
	ClearInteractNode(bookPage)
	
func FacingNearbyNode(nearbyNode: Node2D):
	var playerPosition = self.position
	var nodePosition = nearbyNode.position
	
	var toNode = nodePosition - playerPosition
	var toNodeAbs = toNode.abs()
	var facingNode = false
	
	match m_faceDir:
		FaceDir.UP:
			facingNode = toNode.y < 0 and toNodeAbs.y >= toNodeAbs.x
		FaceDir.DOWN:
			facingNode = toNode.y > 0 and toNodeAbs.y >= toNodeAbs.x
		FaceDir.LEFT:
			facingNode = toNode.x < 0 and toNodeAbs.x >= toNodeAbs.y
		FaceDir.RIGHT:
			facingNode = toNode.x > 0 and toNodeAbs.x >= toNodeAbs.y	
	return facingNode

func GetCameraTopLeftPosition():
	var cameraCenter = camera.get_camera_screen_center()
	var cameraPos = cameraCenter - (Global.LOGICAL_RES / 2)
	return cameraPos
	
func InteractPressed():
	if m_nearbyInteractType == InteractNodeType.NONE:
		return
	assert(m_nearbyInteractNode, "InteractNode must be set if interact type is not NONE")
	
	var facingNode = FacingNearbyNode(m_nearbyInteractNode)
	if facingNode:
		var cameraTopLeft = GetCameraTopLeftPosition()	
		match m_nearbyInteractType:
			InteractNodeType.BOMB:
				Events.emit_signal("view_bomb_puzzle", m_nearbyInteractNode.puzzleName, cameraTopLeft)
			InteractNodeType.PAGE:
				Events.emit_signal("view_manual_page", m_nearbyInteractNode.pageNum, cameraTopLeft)
