class_name Weapon
extends Node2D

@export var gun_left : Gun
@export var gun_right : Gun
@export var projectile_scene : PackedScene

var fire_rate : float
var recoil : float

func shoot() -> void:
	pass;
