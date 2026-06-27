extends BaseMeleeAI

@export var encounter_id: String = "bear_hut"

func die():
	super()
	GameManager.set_flag(encounter_id, "npc_owner_killed", true)
	print("Hut owner diead")
