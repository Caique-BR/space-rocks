class_name PlayerInputComponent
extends Node

signal shoot
signal move(movement_vector: Vector2)
signal aim(aim_vector: Vector2)

func get_input(): # reads the player input and applies it to the ship
	var movement_vector : Vector2 = Input.get_vector("left_left", "left_right", "left_up", "left_down")
	var aim_vector : Vector2 = Input.get_vector("right_left", "right_right", "right_up", "right_down")

	if aim_vector: emit_signal("aim", aim_vector)
	else: emit_signal("aim", Vector2.ZERO)
	
	if movement_vector: emit_signal("move", movement_vector)
	else: emit_signal("move", Vector2.ZERO)
	
	if Input.is_action_pressed("shoot"): emit_signal("shoot")

## BUILT-IN

func _process(_delta: float) -> void:
	get_input()
