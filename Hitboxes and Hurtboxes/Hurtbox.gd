extends Area2D

const HitEffect = preload("res://Effects/HitEffect.tscn")
onready var timer = $Timer
onready var collisionShape = $CollisionShape2D


var invincible = false setget set_invincible

signal invincibility_started
signal invincibility_ended

func set_invincible(value):
	invincible = value
	if invincible:
		emit_signal("invincibility_started")
	else:
		emit_signal("invincibility_ended")


func start_invinvibility(duration):
	self.invincible = true
	timer.start(duration)
	
func create_hit_effect():
	var effect = HitEffect.instance()
	var main = get_tree().current_scene
	effect.global_position = global_position
	main.add_child(effect)


func _on_Timer_timeout():
	self.invincible = false


func _on_Hurtbox_invincibility_started():
	collisionShape.set_deferred("disabled", true)


func _on_Hurtbox_invincibility_ended():
	collisionShape.disabled = false
