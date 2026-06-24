extends Node

# =======================================================
# PLAYER REPUTATION / GLOBAL STATS
# Thins that are not tied to a single encounter
# =======================================================
var player_stats: Dictionary = {
	"honor_points": 0,
	"dishonor_points": 0,
	"ignore_count": 0,
}

# =======================================================
# ENCOUNTER STATE
# =======================================================
var encounter_state: Dictionary = {}


# =======================================================
# STAT API
# =======================================================

func add_stat(stat_name: String, amount: int) -> void:
	player_stats[stat_name] = player_stats.get(stat_name, 0) + amount
	
func get_stat(stat_name: String) -> int:
	return player_stats.get(stat_name, 0)
	
func set_stat(stat_name: String, value: int) -> void:
	player_stats[stat_name] = value


# =======================================================
# ENCOUNTER FLAG API
# =======================================================

func set_flag(encounter_id: String, key: String, value) -> void:
	if not encounter_state.has(encounter_id):
		encounter_state[encounter_id] = {}
	encounter_state[encounter_id][key] = value
	
func get_flag(encounter_id: String, key: String, default = null):
	if not encounter_state.has(encounter_id):
		return default
	return encounter_state[encounter_id].get(key, default)
	
func has_flag(encounter_id: String, key: String) -> bool:
	return encounter_state.has(encounter_id) and encounter_state[encounter_id].has(key)
	

# DEBUG
func debug_print_state() -> void:
	print("--- PLAYER STATS ---")
	print(JSON.stringify(player_stats, "\t"))
	print("--- ENCOUNTER STATE ---")
	print(JSON.stringify(encounter_state, "\t"))

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_select"):  # spacebar by default in Godot
		debug_print_state()
