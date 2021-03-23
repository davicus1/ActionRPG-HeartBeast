extends Node2D

const GrassEffect = preload("res://Effects/GrassEffect.tscn")

func create_grass_effect():
		var grass_effect = GrassEffect.instance()
		var world = get_tree().current_scene
		grass_effect.global_position = global_position
		get_parent().add_child(grass_effect)



func _on_Hurtbox_area_entered(area):
	create_grass_effect()
	queue_free()
