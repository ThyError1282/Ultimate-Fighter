extends Node2D

func _on_top_area_entered(area: Area2D) -> void:
	area.get_parent().global_position = Vector2(area.get_parent().global_position.x, 974)


func _on_bottom_area_entered(area: Area2D) -> void:
	area.get_parent().global_position = Vector2(area.get_parent().global_position.x, 105)

func _on_right_area_entered(area: Area2D) -> void:
	area.get_parent().global_position = Vector2(102, area.get_parent().global_position.y)

func _on_left_area_entered(area: Area2D) -> void:
	area.get_parent().global_position = Vector2(1810, area.get_parent().global_position.y)
