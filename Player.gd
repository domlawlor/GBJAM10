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

var m_nearbyBomb : Node2D = null
var m_nearbyPage : Node2D = null

func _ready():
	Events.connect("set_overworld_paused", self, "_on_set_overworld_paused")
	
	assert(camera, "a level camera must be a child of player")
	camera.make_current()
	
	set_process_input(true)
	animatedSprite.set_animation("down")

func _exit():
	Events.disconnect("set_overworld_paused", self, "_on_set_overworld_paused")

func _on_set_overworld_paused(isPaused):
	m_frozen = isPaused
	m_justUnfrozen = !isPaused

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

func SetNearbyBomb(bomb: Node2D):
	if m_nearbyPage:
		print("SetNearbyBomb - clearing set nearby page, this is probably an issue that they're too close")
		m_nearbyPage = null
	
	#print("SetNearbyBomb - ", bomb)
	m_nearbyBomb = bomb

func ClearNearbyBomb(bomb: Node2D):
	#print("ClearNearbyBomb - ", bomb)
	
	if bomb != m_nearbyBomb:
		print("ClearNearbyBomb called with non active nearbyBomb - active=", m_nearbyBomb, ", tryingToClear=", bomb)
		return
	
	m_nearbyBomb = null

func SetNearbyBookPage(bookPage : Node2D):
	if m_nearbyBomb:
		print("SetNearbyBookPage - clearing set nearby bomb, this is probably an issue that they're too close")
		m_nearbyBomb = null
	
	m_nearbyPage = bookPage

func ClearNearbyBookPage(bookPage : Node2D):
	if bookPage != m_nearbyPage:
		print("ClearNearbyBookPage called with non active nearbyPage - active=", m_nearbyPage, ", tryingToClear=", bookPage)
		return
	
	m_nearbyPage = null

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
	var cameraTopLeft = GetCameraTopLeftPosition()
	
	if m_nearbyBomb and FacingNearbyNode(m_nearbyBomb):
		Events.emit_signal("view_bomb_puzzle", m_nearbyBomb.puzzleName, cameraTopLeft)
	elif m_nearbyPage and FacingNearbyNode(m_nearbyPage):
		Events.emit_signal("view_manual_page", m_nearbyPage.pageNum, cameraTopLeft)
