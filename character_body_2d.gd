extends CharacterBody2D

signal moved  # fired once, the first time the player moves after a (re)start

const SPEED = 800.0
const JUMP_VELOCITY = -900.0

var start_position: Vector2
var has_moved := false


func _ready() -> void:
	start_position = global_position
	add_to_group("player")


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	var jumped := Input.is_action_just_pressed("jump") and is_on_floor()
	if jumped:
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	var direction := Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	if not has_moved and (direction != 0.0 or jumped):
		has_moved = true
		moved.emit()

	move_and_slide()


func reset_to_start() -> void:
	global_position = start_position
	velocity = Vector2.ZERO
	has_moved = false
