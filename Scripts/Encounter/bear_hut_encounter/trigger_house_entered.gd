extends Area3D

@export var encounter_id: String = "bear_hut"

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		GameManager.set_flag(encounter_id, "entered", true)
