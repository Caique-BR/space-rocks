extends Control

@onready var main_scene : PackedScene = load("res://main/main.tscn")

@export var start_button : Button
@export var animation_player : AnimationPlayer

var start_tween : Tween

func _ready() -> void:
	pass

func _on_start_button_pressed() -> void:
	animation_player.play("depart")

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	get_tree().change_scene_to_file("res://main/main.tscn")
	if start_tween: start_tween.kill()

func _on_start_button_mouse_entered() -> void:
	if start_tween: start_tween.kill()
	
	start_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO).set_parallel()
	start_tween.tween_property(start_button, "scale", Vector2.ONE * 1.05, 1)

func _on_start_button_mouse_exited() -> void:
	if start_tween: start_tween.kill()
	
	start_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	start_tween.tween_property(start_button, "scale", Vector2.ONE, 1)
