class_name Cannon
extends Weapon

var current_gun_index : int = 0

func _ready() -> void:
	fire_rate = 0.1

func shoot() -> void:
	var current_gun : Gun = [gun_left, gun_right][current_gun_index]
	current_gun.shoot()
	current_gun_index = 1 - current_gun_index
	audio_stream_player.play()

## BUILT-IN

func _process(_delta: float) -> void:
	var mouse_pos = get_global_mouse_position()
	
	_update_gun_rotation(gun_left, mouse_pos)
	_update_gun_rotation(gun_right, mouse_pos)

## PRIVATE

func _update_gun_rotation(gun: Node2D, mouse_pos: Vector2) -> void:
	var direction = gun.global_position.direction_to(mouse_pos)
	#gun.global_rotation = lerp_angle(gun.global_rotation, direction.angle(), 0.1)
	gun.global_rotation = direction.angle()
