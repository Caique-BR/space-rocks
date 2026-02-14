@abstract
class_name PickupData
extends Resource

@export var texture : Texture2D
@export var string_id :  String
@export var particles : bool
@export var particles_color : Color
@export var magnetic : bool 

func apply(target: Player) -> void:
	pass;
