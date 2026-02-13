class_name HUD
extends CanvasLayer

@onready var health_bar : TextureProgressBar = get_node("HealthBar")
@onready var shield_bar : TextureProgressBar = get_node("ShieldBar")

var health_tween : Tween;
var shield_tween : Tween;

var delta_count : float = 0.0

func _process(delta: float) -> void:
	delta_count += delta
	offset.y = sin(delta_count * 2) * 2.5

func update_health(ratio: float) -> void:
	var new_value = ratio * 100
	if health_tween: health_tween.kill()
	
	health_tween = health_bar.create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	health_tween.tween_property(health_bar, "value", new_value, 1)

func update_shield(ratio: float) -> void:
	var new_value = ratio * 100
	Utilily.print_on_screen("shield")
	if shield_tween: shield_tween.kill()
	print(ratio)
	shield_tween = shield_bar.create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	shield_tween.tween_property(shield_bar, "value", new_value, 1)
	
