extends KinematicBody2D

const EnemyDeathEffect = preload("res://Effects/EnemyDeathEffect.tscn")

var knockback = Vector2.ZERO

onready var stats = $Stats

func _ready():
	print("%s/%s" % [stats.health,stats.max_health])

func _physics_process(delta):
	knockback = knockback.move_toward(Vector2.ZERO, 200*delta)
	knockback = move_and_slide(knockback)


func _on_Hurtbox_area_entered(area):
	knockback = area.knockback_vector * 130
	print("Bat: OW!!!")
	stats.health -= area.damage
	


func _on_Stats_no_health():
	print("Bat: I have been defeated, farewell!")
	queue_free()
	var enemyDeathEffect = EnemyDeathEffect.instance()
	enemyDeathEffect.global_position = global_position
	get_parent().add_child(enemyDeathEffect)

