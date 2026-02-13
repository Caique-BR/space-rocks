class_name AimLine
extends Line2D

func _process(_delta: float) -> void:
	var mouse_pos = get_global_mouse_position()
	points[1].x = (mouse_pos - global_position).length()
	
