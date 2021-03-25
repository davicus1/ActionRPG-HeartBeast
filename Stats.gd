extends Node


export(int) var max_health = 1 setget set_max_health
var health = max_health setget set_health

signal no_health
signal health_changed(value)
signal max_health_changed(value)

func set_health(value):
	health = value
	emit_signal("health_changed", health)
	print("%s/%s" % [health,max_health])
	if health <= 0:
		emit_signal("no_health")


func set_max_health(value):
	max_health = value
	self.health = min(max_health,health)
	emit_signal("max_health_changed", max_health)


func _ready():
	self.health = max_health
