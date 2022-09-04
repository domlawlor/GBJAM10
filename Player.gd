extends KinematicBody2D

signal update_position(pos)

var VELOCITY_X : float = 100.0
var VELOCITY_Y : float = 100.0

var m_vel : Vector2 = Vector2.ZERO

func _ready():
	set_process_input(true)

func _unhandled_input(event):
	if event.is_action("moveLeft"):
		m_vel.x = -VELOCITY_X
	elif event.is_action("moveRight"):
		m_vel.x = VELOCITY_X
	elif !Input.is_action_pressed("moveLeft") and !Input.is_action_pressed("moveRight"):
		m_vel.x = 0
	
	if event.is_action("moveUp"):
		m_vel.y = -VELOCITY_Y
	elif event.is_action("moveDown"):
		m_vel.y = VELOCITY_Y
	elif !Input.is_action_pressed("moveUp") and !Input.is_action_pressed("moveDown"):
		m_vel.y = 0

func _physics_process(delta):
	move_and_collide(m_vel * delta)

	emit_signal("update_position", position)
