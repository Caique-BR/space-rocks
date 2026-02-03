class_name Dreadnought
extends AnimatableBody2D

@export var health = 3
@export var checkpoints : Array[Vector2] ## 0 = enters screen, 1 = top left, 2 bot left, 3 top right, 4 bot right
var speed = 100
var current_pos : Vector2 = global_position
var tween_move : Tween 


func _ready() -> void:
	var next_position: Vector2 = checkpoints[0]
	move_to_spawn(next_position)


	
func move_to_spawn(to: Vector2): # boss arrives from outside the top center of the screen and stop a top mid of screen
	
		look_at(to)
		if tween_move: tween_move.kill()
		tween_move = create_tween()
		tween_move.tween_property(self, "position", to, 1)
		
		tween_move.finished.connect(move_to_top_left)
		
		
		
func move_to_top_left(): 
		print("finished")
		look_at(checkpoints[1])
		if tween_move: tween_move.kill()
		tween_move = create_tween()
		tween_move.tween_property(self, "position", checkpoints[1], 1)
		
