class_name Camera
extends Camera2D

@export var player : Player
@onready var screensize : Vector2 = get_viewport().get_visible_rect().size

var shake_intensity : float = 0.0
var active_shake_time : float = 0.0

var shake_decay : float = 5.0

var shake_time : float = 0.0
var shake_time_speed : float = 20.0

var tween_bounce : Tween

var noise : FastNoiseLite = FastNoiseLite.new()

func screen_shake(intensity: int, time: float):
	randomize()
	noise.seed = randi()
	noise.frequency = 2.0
	
	shake_intensity = intensity
	active_shake_time = time
	shake_time = 0.0

func zoom_bounce() -> void:
	if tween_bounce: tween_bounce.kill()
	
	zoom = Vector2(0.96, 0.96)
	
	tween_bounce = create_tween().set_ease(Tween.EASE_OUT).set_trans		(Tween.TRANS_ELASTIC)
	tween_bounce.tween_property(self, "zoom", Vector2.ONE, 1)		

## Built-in

func _process(delta: float) -> void:
	if active_shake_time > 0:
		shake_time += delta * shake_time_speed
		active_shake_time -= delta
	
		offset = Vector2(
			noise.get_noise_2d(shake_time, 0) * shake_intensity,
			noise.get_noise_2d(0, shake_time) * shake_intensity,
		)
	
		shake_intensity = max(shake_intensity - shake_decay * delta, 0)
	else:
		offset = lerp(offset, Vector2.ZERO, 10.5 * delta)
	
	position = player.global_position
