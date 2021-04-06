extends KinematicBody2D

const EnemyDeathEffect = preload("res://Effects/EnemyDeathEffect.tscn")

var knockback = Vector2.ZERO
var velocity = Vector2.ZERO

export var ACCELLERATION = 300
export var MAX_SPEED = 60
export var FRICTION = 200
export var WANDER_TARGET_MINIMUM = 6
enum {
	IDLE,
	WANDER,
	CHASE
}

var state = CHASE

onready var sprite = $AnimatedSprite
onready var stats = $Stats
onready var playerDetectionZone = $PlayerDetectionZone
onready var hurtBox = $Hurtbox
onready var softCollision = $SoftCollision
onready var wanderController = $WanderController
onready var animationPlayer = $AnimationPlayer

func _ready():
	state = pick_random_state([IDLE, WANDER])
	print("%s/%s" % [stats.health,stats.max_health])

func _physics_process(delta):
	knockback = knockback.move_toward(Vector2.ZERO, FRICTION * delta)
	knockback = move_and_slide(knockback)
	match state:
		IDLE:
			velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
			seek_player()
			if wanderController.get_time_left() == 0:
				state = choose_stance_and_timer(state)
			
		WANDER:
			seek_player()
			if wanderController.get_time_left() == 0:
				state = choose_stance_and_timer(state)
			accellerate_towards_point(wanderController.target_position,delta)
			if global_position.distance_to(wanderController.target_position) <= WANDER_TARGET_MINIMUM:
				state = choose_stance_and_timer(state)
			
		CHASE:
			var player = playerDetectionZone.player
			if player != null:
				accellerate_towards_point(player.global_position,delta)
			else:
				state = IDLE
	if softCollision.is_colliding():
		velocity += softCollision.get_push_vector() * delta * 400
	velocity = move_and_slide(velocity)


func accellerate_towards_point(point, delta):
	var direction = global_position.direction_to(point)
	velocity = velocity.move_toward(direction * MAX_SPEED, ACCELLERATION * delta)
	sprite.flip_h = velocity.x < 0


func seek_player():
	if playerDetectionZone.can_see_player():
		state = CHASE


func choose_stance_and_timer(current_state):
	var chosen_state = current_state
	#if wanderController.get_time_left() == 0 || global_position.distance_to(wanderController.target_position) <= WANDER_TARGET_MINIMUM:
	chosen_state = pick_random_state([IDLE, WANDER])
	wanderController.start_wander_timer(rand_range(1,3))
	return chosen_state


func pick_random_state(state_list:Array):
	state_list.shuffle()
	return state_list.pop_front()

func _on_Hurtbox_area_entered(area):
	knockback = area.knockback_vector * 130
	print("Bat: OW!!!")
	stats.health -= area.damage
	hurtBox.start_invinvibility(0.5)
	hurtBox.create_hit_effect()
	hurtBox.start_invinvibility(0.4)
	


func _on_Stats_no_health():
	print("Bat: I have been defeated, farewell!")
	queue_free()
	var enemyDeathEffect = EnemyDeathEffect.instance()
	enemyDeathEffect.global_position = global_position
	get_parent().add_child(enemyDeathEffect)


func _on_Hurtbox_invincibility_started():
	animationPlayer.play("Start")


func _on_Hurtbox_invincibility_ended():
	animationPlayer.play("Stop")
