extends Control

@onready var main_scene : PackedScene = load("res://main/main.tscn")

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://main/main.tscn")
