extends Node2D

var tween_spawn : Tween
var tween_move : Tween

func start() -> void:
	scale = Vector2.ZERO
	
	tween_spawn = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	tween_spawn.tween_property(self, "scale", Vector2.ONE, 1)

	tween_move = create_tween().set_parallel()
	tween_move.tween_property(self, "position:y", position.y - 100, 1)
	tween_move.tween_property(self, "modulate:a", 0.0, 1)
	

func _ready() -> void:
	start()
