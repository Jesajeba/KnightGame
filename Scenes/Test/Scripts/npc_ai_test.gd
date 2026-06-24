extends CharacterBody3D

# State machine
enum State { PASSIVE, IDLE, PATHFIND, ATTACK, DEAD }
var current_state: State = State.PASSIVE

# Variables
@export var detection_range := 10.0
@export var attack_range := 1.5
@export var move_speed := 3.0
@export var max_hp := 5.0

var hp = max_hp
var aggressive = false
var can_attack = true
var has_hit_this_swing = false
var target: Node3D = null

const BLOOD_EFFECT = preload("res://Scenes/blood_spray.tscn")

@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var hands = $Pivot/Hands
@onready var attack_hitbox: Area3D = $Pivot/Hands/Sword/Hitbox
@onready var pivot: Node3D = $Pivot
@onready var blood_pos: Node3D = $Pivot/BloodPos


func _ready() -> void:
	# Ensure hp is max on load
	hp = max_hp
	
func _physics_process(delta: float) -> void:
	# Add gravity
	if not is_on_floor():
		velocity += get_gravity() * delta * 2.0
	
	# Default to the player being the target
	if target == null:
		target = get_tree().get_first_node_in_group("player")
		return
		
	var distance = global_position.distance_to(target.global_position)
	update_state(distance)
	run_state(delta, distance)

# Updates state machine states
func update_state(distance: float):
	if current_state == State.DEAD:
		return
		
	if not aggressive:
		current_state = State.PASSIVE
		return
	
	# If target is dead, return to idle state - Does not reset aggressive flag so if player walks into range follow aggressive logic
	if target !=  null and target.has_method("get_hp") and target.get_hp() <= 0:
		target = null
		current_state = State.IDLE
		return
	
	match current_state:
		State.PASSIVE:
			current_state = State.IDLE
		State.IDLE:
			if distance <= detection_range:
				current_state = State.PATHFIND
		State.PATHFIND:
			if distance <= attack_range:
				current_state = State.ATTACK
			elif distance > detection_range:
				current_state = State.IDLE
		State.ATTACK:
			if distance > attack_range:
				current_state = State.PATHFIND

# The actual logic for each state in the state machine
func run_state(delta: float, distance: float):
	match current_state:
		State.PASSIVE:
			velocity = Vector3.ZERO
		
		State.IDLE:
			velocity = Vector3.ZERO
			
		State.PATHFIND:
			nav_agent.target_position = target.global_position
			
			if nav_agent.is_navigation_finished():
				velocity = Vector3.ZERO
			else:
				var next_point = nav_agent.get_next_path_position()
				var direction = (next_point - global_position)
				direction.y = 0
				direction = direction.normalized()
				velocity = direction * move_speed
				look_at(global_position + direction, Vector3.UP)
			
		State.ATTACK:
			velocity = Vector3.ZERO
			var attack_direction = (target.global_position - global_position)
			attack_direction.y = 0
			if attack_direction.length() > 0.01:
				look_at(global_position + attack_direction.normalized(), Vector3.UP)
			attack()
			
		State.DEAD:
			velocity = Vector3.ZERO
			
	move_and_slide()

# Attack funtion.. note placeholder animation and hitbox timing
func attack():
	if not can_attack:
		return
	can_attack = false
	has_hit_this_swing = false
	
	play_swing()
	print("NPC Attacks ", target)
	
	attack_hitbox.monitoring = true
	await get_tree().create_timer(0.4).timeout
	attack_hitbox.monitoring = false
	
	await  get_tree().create_timer(2.0).timeout
	can_attack = true
	
# Placeholder funtion that creates the attack animation
func play_swing():
	var tween = create_tween()
	tween.tween_property(hands, "rotation:x", -2, 0.2)
	tween.tween_property(hands, "rotation:x", 0.0, 0.2)
			

# Apply damage
func _on_hitbox_body_entered(body: Node3D) -> void:
	if has_hit_this_swing:
		return
	if body == target and body.has_method("take_damage"):
		has_hit_this_swing = true
		body.take_damage(1)
		
# Take damage
func take_damage(amount: int, source_position: Vector3 = global_position):
	if hp <= 0:
		return
	aggressive = true
	hp -= amount
	print("Eenemy HP: ", hp)
	if hp <= 0:
		die()

# Die funtion
func die():
	current_state = State.DEAD
	$BodyHitbox.disabled = true
	
	play_death_anim()
	
	# Instance blood particle effect and play it
	var blood = BLOOD_EFFECT.instantiate()
	blood_pos.add_child(blood)
	blood.position = Vector3.ZERO
	blood.play()

# Placeholder function that creates death animation
func play_death_anim():
	var tween = create_tween()
	tween.tween_property(pivot, "rotation:x", deg_to_rad(90), 0.5)
	tween.tween_property(hands, "rotation:x", deg_to_rad(90), 0.5)

# Funtion to set a new target
func set_target(new_target: Node3D):
	target = new_target
