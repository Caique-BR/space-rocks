class_name HUD
extends CanvasLayer

@export var exp_bar : ProgressBar
@export var ship_damage : Control
@export var animation_player : AnimationPlayer

var exp_tween : Tween;

var delta_count : float = 0.0 
var intro_ended : bool = false

func _ready() -> void:
	await get_tree().create_timer(1).timeout
	animation_player.play("intro")
 
func _process(delta: float) -> void:
	if intro_ended:
		delta_count += delta
		ship_damage.position.y = 950.0  + sin(delta_count * 2) * 2.5

func update_health(ratio: float) -> void:
	var new_value = ratio * 100
	#if health_t ween: health_tween.kill()
	
	#health_tween = health_bar.create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	#health_tween.tween_property(health_bar, "value", new_value, 1)

func update_shield(ratio: float) -> void:
	var new_value = ratio * 100

	#if shield_tween: shield_tween.kill()
	#shield_tween = shield_bar.create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	#shield_tween.tween_property(shield_bar, "value", new_value, 1)

func update_experience(new_exp: int) -> void:
	if exp_tween: exp_tween.kill()
	exp_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO).set_parallel()
	exp_tween.tween_property(exp_bar.get_child(0), "value", new_exp, 1)
	exp_tween.tween_property(exp_bar, "value", new_exp, 2)

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "intro": intro_ended = true
