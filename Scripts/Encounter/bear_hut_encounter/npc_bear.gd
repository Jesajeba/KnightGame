extends BaseMeleeAI

@export var encounter_id: String = "bear_hut"

func die():
	super()
	GameManager.set_flag(encounter_id, "bear_killed", true)
	print("Bear died")
