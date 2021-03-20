extends KinematicBody2D

# Called when the node enters the scene tree for the first time.
func _ready():
	animation_tree.active = true
	#Set Startup direction so that animations are in sync before the player moves the first time
	animation_tree.set("parameters/Idle/blend_position", roll_vector)
	animation_tree.set("parameters/Run/blend_position", roll_vector)
	animation_tree.set("parameters/Attack/blend_position", roll_vector)
	animation_tree.set("parameters/Roll/blend_position", roll_vector)
	swordHitBox.knockback_vector = roll_vector

const MAX_SPEED = 80
const ACCELERATION = 750
const FRICTION = 750
const ROLL_SPEED = MAX_SPEED * 1.25

enum {
	MOVE,
	ROLL,
	ATTACK
}

var state = MOVE
var velocity = Vector2.ZERO
var roll_vector = Vector2.LEFT

onready var animation_player = $AnimationPlayer
onready var animation_tree = $AnimationTree
onready var animation_state = animation_tree.get("parameters/playback")
onready var swordHitBox = $HitboxPivot/SwordHitbox

func _physics_process(delta):
	match state:
		MOVE:
			move_state(delta)
		ROLL:
			roll_state(delta)
		ATTACK:
			attack_state(delta)


func move_state(delta):	
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	
	if input_vector != Vector2.ZERO:
		input_vector = input_vector.normalized()
		roll_vector = input_vector
		swordHitBox.knockback_vector = roll_vector
		velocity = velocity.move_toward(input_vector * MAX_SPEED,  ACCELERATION * delta)
		animation_tree.set("parameters/Idle/blend_position", input_vector)
		animation_tree.set("parameters/Run/blend_position", input_vector)
		animation_tree.set("parameters/Attack/blend_position", input_vector)
		animation_tree.set("parameters/Roll/blend_position", input_vector)
		animation_state.travel("Run")
	else:
		animation_state.travel("Idle")
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	
	move()
	
	if Input.is_action_just_pressed("roll"):
		state = ROLL
	
	if Input.is_action_just_pressed("attack"):
		state = ATTACK

func attack_state(delta):
	velocity = Vector2.ZERO
	animation_state.travel("Attack")


func roll_state(delta):
	velocity = roll_vector * ROLL_SPEED
	animation_state.travel("Roll")
	move()


func move():
	#Save the velocity for the next frame to prevent sticking in corners
	velocity = move_and_slide(velocity)
	
func roll_animation_finished():
	velocity = velocity * .8
	state = MOVE


func attack_animation_finished():
	state = MOVE



