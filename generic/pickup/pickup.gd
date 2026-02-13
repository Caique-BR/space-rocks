class_name Pickup
extends Area2D

@export var texture : Texture2D

var tween_magnet : Tween
var moving_towards : bool = false
var player : Player

func pick_up() -> void:
	tween_magnet = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	tween_magnet.tween_property(self, "scale", Vector2.ZERO, 0.25)
	player.pickup_item(self)
	await tween_magnet.finished
	queue_free()

## Built-in

func _process(_delta: float) -> void:
	if moving_towards:
		global_position = global_position.lerp(player.global_position, 0.05)
		Utilily.print_on_screen((player.global_position - global_position).length())
		if (player.global_position - global_position).length() < 30:
			moving_towards = false
			pick_up()
			

## Handlers

func _on_body_entered(body: Node2D) -> void:
	if body is Player: 
		moving_towards = true
		player = body
