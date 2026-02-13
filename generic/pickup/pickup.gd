@tool
class_name Pickup
extends Area2D

@export var pickup_data : PickupData
@export var audio_stream_player : AudioStreamPlayer

var tween_magnet : Tween

func pick_up() -> void:
	audio_stream_player.play()
	tween_magnet = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	tween_magnet.tween_property(self, "scale", Vector2.ZERO, 0.5)
	await tween_magnet.finished
	queue_free()

## Built-in

func _ready() -> void:
	pass

## Handlers

func _on_body_entered(body: Node2D) -> void:
	if body is Player: 
		pickup_data.apply(body)
