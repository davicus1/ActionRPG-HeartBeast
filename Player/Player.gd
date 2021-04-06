extends KinematicBody2D

const PlayerHurtSound = preload("res://Player/PlayerHurt.tscn")
const MAX_SPEED = 80
const ACCELERATION = 750
const FRICTION = 750
const ROLL_SPEED = MAX_SPEED * 1.25

enum PlayerState {
	MOVE,
	ROLL,
	ATTACK
}

var state = PlayerState.MOVE
var velocity = Vector2.ZERO
var roll_vector = Vector2.LEFT

var stats = PlayerStats

onready var animation_player = $AnimationPlayer
onready var animation_tree = $AnimationTree
onready var animation_state = animation_tree.get("parameters/playback")
onready var swordHitBox = $HitboxPivot/SwordHitbox
onready var hurtBox = $Hurtbox
onready var blinkAnimationPlayer = $BlinkAnimationPlayer

func _ready():
	#Set Starting Random SEED. Remove for TESTING
	randomize()
	stats.connect("no_health", self, "queue_free")
	animation_tree.active = true
	#Set Startup direction so that animations are in sync before the player moves the first time
	animation_tree.set("parameters/Idle/blend_position", roll_vector)
	animation_tree.set("parameters/Run/blend_position", roll_vector)
	animation_tree.set("parameters/Attack/blend_position", roll_vector)
	animation_tree.set("parameters/Roll/blend_position", roll_vector)
	swordHitBox.knockback_vector = roll_vector

func _physics_process(delta):
	match state:
		PlayerState.MOVE:
			move_state(delta)
		PlayerState.ROLL:
			roll_state(delta)
		PlayerState.ATTACK:
			attack_state(delta)


func move_state(delta):	
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength(PlayerInput.right()) - Input.get_action_strength(PlayerInput.left())
	input_vector.y = Input.get_action_strength(PlayerInput.down()) - Input.get_action_strength(PlayerInput.up())
	
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
	
	if Input.is_action_just_pressed(PlayerInput.roll()):
		state = PlayerState.ROLL
	
	if Input.is_action_just_pressed(PlayerInput.attack()):
		state = PlayerState.ATTACK

func attack_state(_delta):
	velocity = Vector2.ZERO
	animation_state.travel("Attack")


func roll_state(_delta):
	velocity = roll_vector * ROLL_SPEED
	animation_state.travel("Roll")
	move()


func move():
	#Save the velocity for the next frame to prevent sticking in corners
	velocity = move_and_slide(velocity)
	
func roll_animation_finished():
	velocity = velocity * .8
	state = PlayerState.MOVE


func attack_animation_finished():
	state = PlayerState.MOVE


func _on_Hurtbox_area_entered(area):
	stats.health -= area.damage
	hurtBox.start_invinvibility(0.6)
	hurtBox.create_hit_effect()
	var playerHurtSound = PlayerHurtSound.instance()
	get_tree().current_scene.add_child(playerHurtSound)


func _on_Hurtbox_invincibility_started():
	blinkAnimationPlayer.play("Start")


func _on_Hurtbox_invincibility_ended():
	blinkAnimationPlayer.play("Stop")
