extends Area3D

@export var encounter_id: String = "bear_hut"
@export var bear: Node3D
@export var npc: Node3D

func _on_body_entered(body: Node3D) -> void:
	var bear_killed: bool = GameManager.get_flag(encounter_id, "bear_killed", false)
	var npc_killed: bool = GameManager.get_flag(encounter_id, "npc_owner_killed", false)
	var house_entered: bool = GameManager.get_flag(encounter_id, "entered", false)
	
	if body.is_in_group("player") and not bear_killed and not npc_killed and not house_entered:
		if is_instance_valid(bear) and is_instance_valid(npc):
			npc.is_brave = true
			npc.aggressive = true
			npc.set_target(bear)
		
	if body.is_in_group("player") and not bear_killed and not npc_killed and house_entered:
		if is_instance_valid(bear) and is_instance_valid(npc):
			bear.aggressive = true
			bear.set_target(npc)
