extends Area3D

@export var encounter_id: String = "bear_hut"
@export var npc_attacker: Node3D
@export var npc_target: Node3D

func _on_body_entered(body: Node3D) -> void:
	var bear_killed: bool = GameManager.get_flag(encounter_id, "bear_killed", false)
	var npc_killed: bool = GameManager.get_flag(encounter_id, "npc_owner_killed", false)
	
	if body.is_in_group("player") and not bear_killed and not npc_killed:
		if is_instance_valid(npc_attacker) and is_instance_valid(npc_target):
			npc_attacker.aggressive = true
			npc_attacker.set_target(npc_target)
