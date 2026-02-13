class_name WeaponModule
extends Node2D

@onready var gun_cooldown : Timer = get_node("GunCooldown")

@export var current_weapon : Weapon

## Methods

func equip_weapon(weapon_scene : PackedScene) -> void:
	var new_weapon : Weapon = weapon_scene.instantiate()
	current_weapon = new_weapon
	current_weapon.show()

## Built-in

func _ready() -> void:
	if current_weapon:
		current_weapon.show()

## Handlers

func _on_shoot() -> void:
	if gun_cooldown.time_left: return
	if current_weapon:
		current_weapon.shoot()
		gun_cooldown.start(current_weapon.fire_rate)
