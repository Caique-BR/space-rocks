class_name AimLine
extends Line2D

func _ready() -> void:
	pass # Replace with function body.

func _process(delta: float) -> void:
	var mouse_pos = get_global_mouse_position()
	#Utilily.print_on_screen(abs((mouse_pos - global_position).x))
	points[1].x = (mouse_pos - global_position).length()
	
