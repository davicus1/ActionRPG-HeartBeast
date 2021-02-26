extends KinematicBody2D

# Called when the node enters the scene tree for the first time.
func _ready():
	print("Hello World Player...")

const MAX_SPEED = 80
const ACCELERATION = 750
const FRICTION = 750

var velocity = Vector2.ZERO

func _physics_process(delta):
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	
	if input_vector != Vector2.ZERO:
		input_vector = input_vector.normalized()
		velocity = velocity.move_toward(input_vector * MAX_SPEED,  ACCELERATION * delta)
		#velocity += input_vector * ACCELERATION * delta
		#velocity = velocity.clamped(MAX_SPEED * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	
	#Save the velocity for the next frame to prevent sticking in corners
	velocity = move_and_slide(velocity)
