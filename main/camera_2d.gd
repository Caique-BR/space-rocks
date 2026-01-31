extends Camera2D

@export var player : Player
@onready var screensize_normalized : Vector2 = get_viewport().get_visible_rect().size / 2

func _process(_delta: float) -> void:
	position = player.global_position / 10
