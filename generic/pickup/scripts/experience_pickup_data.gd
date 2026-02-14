class_name ExperiencePickupData
extends PickupData

@export var experience_amount : int

func apply(target: Player) -> void:
	target.apply_experience(experience_amount)
