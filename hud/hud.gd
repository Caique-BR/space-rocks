class_name HUD
extends CanvasLayer

@onready var health_bar : ProgressBar = get_node("HealthBar")
@onready var shield_bar : ProgressBar = get_node("ShieldBar")

var health_tween : Tween;
var shield_tween : Tween;

func update_health(health_ratio: float) -> void:
	health_bar.value = health_ratio * 100
	if health_tween: health_tween.kill()
	health_tween = health_bar.create_tween().set_ease(Tween.EASE_OUT)
	health_tween.tween_property($HealthBar/DamageBar, "value", health_bar.value, 1)

func update_shield(shield_ratio: float) -> void:
	shield_bar.value = shield_ratio * 100
	if shield_tween: shield_tween.kill()
	shield_tween = shield_bar.create_tween().set_ease(Tween.EASE_OUT)
	shield_tween.tween_property($ShieldBar/DamageBar, "value", shield_bar.value, 1)
	
