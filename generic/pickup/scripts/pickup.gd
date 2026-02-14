@tool
class_name Pickup
extends Area2D

## Pickup Data
@export var pickup_data : PickupData

## Pickup Nodes
@export var sprite_2d : Sprite2D
@export var audio_stream_player : AudioStreamPlayer
@export var particles : GPUParticles2D
@export var collision : CollisionShape2D

var tween_magnet : Tween
var delta_count : float = 0.0

func pick_up() -> void:
	audio_stream_player.play()
	tween_magnet = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	tween_magnet.tween_property(self, "scale", Vector2.ZERO, 0.5)
	await tween_magnet.finished
	queue_free()

## Built-in

func _ready() -> void:
	sprite_2d.texture = pickup_data.texture
	var shape = CircleShape2D.new()
	shape.radius = sprite_2d.texture.get_size().x
	
	if pickup_data.magnetic:
		shape.radius = 64
	
	collision.shape = shape

	if pickup_data.particles:
		particles.show()
	else:
		particles.hide()
		particles.emitting = false

func _process(delta) -> void:
	delta_count += delta
	sprite_2d.rotation = sin(delta_count * 2) / 10

## Handlers

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		set_deferred("monitoring", false)
		pick_up()
		pickup_data.apply(body)
		audio_stream_player.play()
