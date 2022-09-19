extends KinematicBody2D

signal update_position(pos)

onready var animatedSprite : AnimatedSprite = $PixelLockedSprite

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
var m_vel : Vector2 = Vector2.ZERO
var m_faceDir = FaceDir.DOWN

var m_nearbyBomb : Node2D = null


func _ready():
	Events.connect("bomb_puzzle_complete", self, "_on_bomb_puzzle_complete")

	set_process_input(true)
	animatedSprite.set_animation("down")

func _exit():
	Events.disconnect("bomb_puzzle_complete", self, "_on_bomb_puzzle_complete")

func _on_bomb_puzzle_complete():
	m_frozen = false

func _physics_process(delta):
	if m_frozen:
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
	elif !Input.is_action_pressed("moveLeft") and !Input.is_action_pressed("moveRight"):
		m_vel.x = 0
	
	if Input.is_action_pressed("moveUp"):
		m_vel.y = -VELOCITY_Y
		m_faceDir = FaceDir.UP
		animatedSprite.set_animation("up")
	elif Input.is_action_pressed("moveDown"):
		m_vel.y = VELOCITY_Y
		animatedSprite.set_animation("down")
		m_faceDir = FaceDir.DOWN
	elif !Input.is_action_pressed("moveUp") and !Input.is_action_pressed("moveDown"):
		m_vel.y = 0

	if m_vel.length() > 0:
		animatedSprite.play()
	else:
		animatedSprite.stop()
		animatedSprite.set_frame(0) # set to default idle frame for facing direction

	move_and_collide(m_vel * delta)

	emit_signal("update_position", position)

func SetNearbyBomb(bomb: Node2D):
	print("SetNearbyBomb - ", bomb)
	m_nearbyBomb = bomb

func ClearNearbyBomb(bomb: Node2D):
	print("ClearNearbyBomb - ", bomb)

	if bomb != m_nearbyBomb:
		print("ClearNearbyBomb called with non active nearbyBomb - active=", m_nearbyBomb, ", tryingToClear=", bomb)
		return

	m_nearbyBomb = null

func FacingNearbyBomb(bomb: Node2D):
	var playerPosition = self.position
	var bombPosition = bomb.position
	
	var toBomb = bombPosition - playerPosition
	var toBombAbs = toBomb.abs()

	var facingBomb = false

	match m_faceDir:
		FaceDir.UP:
			facingBomb = toBomb.y < 0 and toBombAbs.y >= toBombAbs.x
		FaceDir.DOWN:
			facingBomb = toBomb.y > 0 and toBombAbs.y >= toBombAbs.x
		FaceDir.LEFT:
			facingBomb = toBomb.x < 0 and toBombAbs.x >= toBombAbs.y
		FaceDir.RIGHT:
			facingBomb = toBomb.x > 0 and toBombAbs.x >= toBombAbs.y	
	return facingBomb



func InteractPressed():
	if m_nearbyBomb and FacingNearbyBomb(m_nearbyBomb):
		print("VIEW BOMB! puzzle=", m_nearbyBomb.puzzleNameToOpen)
		#m_frozen = true
		Events.emit_signal("view_bomb_puzzle", m_nearbyBomb.puzzleNameToOpen)

