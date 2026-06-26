extends CharacterBody3D

# Variables
@export var max_hp: float = 10.0
@export var damage: float = 1.0
@export var sensitivity: float = 0.001
@export var speed: float = 8.0

@onready var upper_body_pivot = $UpperBodyPivot
@onready var camera = $UpperBodyPivot/Camera3D
@onready var attack_hitbox = $UpperBodyPivot/Hands/Sword/AttackHitbox
@onready var hands = $UpperBodyPivot/Hands

var hp = max_hp
var can_attack : bool = true
var bob_time: float = 0.0

const JUMP_VELOCITY: float = 4.5
const BOB_FREQUENCY: float = 3.0
const BOB_AMPLITUDE: float = 0.05


# Start of logic
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event: InputEvent) -> void:
	# Input for quitting the game - PLACEHOLDER
	if Input.is_action_pressed("Exit"):
		get_tree().quit()
	
	if event is InputEventMouseMotion:
		# 1. Rotate the player horizontally on the Y axis
		rotate_y(-event.relative.x * sensitivity)
		
		# 2. Rotate UpperBodyPivot vertically on the X axis
		upper_body_pivot.rotate_x(-event.relative.y * sensitivity)
		upper_body_pivot.rotation.x = clamp(upper_body_pivot.rotation.x, deg_to_rad(-90), deg_to_rad(90))
	
	# Attack action
	if event.is_action_pressed("Attack") and can_attack:
		attack()
		print("attack")
		
		
# Attack function
func attack():
	play_swing()
	can_attack = false
	attack_hitbox.monitoring = true
	
	# How long the attack_hitbox is live on attack
	await get_tree().create_timer(0.2).timeout
	attack_hitbox.monitoring = false
	
	# Attack cooldown
	await get_tree().create_timer(0.4).timeout
	can_attack = true

# Dealing damage
func _on_attack_hitbox_body_entered(body: Node):
	if body.is_in_group("enemy") and body.has_method("take_damage"):
		body.take_damage(damage, self)
		
# Animation placeholder
func play_swing():
	var tween = create_tween()
	tween.tween_property(hands, "rotation:x", -2, 0.2)
	tween.tween_property(hands, "rotation:x", 0.0, 0.2)
	
func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta * 2.0

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction relative to the PLAYER transform basis
	var input_dir := Input.get_vector("Left", "Right", "Up", "Down")
	var direction : Vector3 = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if is_on_floor():
		if direction:
			velocity.x = lerp(velocity.x, direction.x * speed, delta * 5.0)
			velocity.z = lerp(velocity.z, direction.z * speed, delta * 5.0)
		else:
			velocity.x = lerp(velocity.x, 0.0, delta * 7.0)
			velocity.z = lerp(velocity.z, 0.0, delta * 7.0)
	else:
		velocity.x = lerp(velocity.x, direction.x * speed, delta * 2.0)
		velocity.z = lerp(velocity.z, direction.z * speed, delta * 2.0)
		
	# Head bobbing (Only bob if we are actually moving on the ground)
	if is_on_floor() and direction != Vector3.ZERO:
		bob_time += delta * velocity.length()
		camera.transform.origin = _headbob(bob_time)
	else:
		# Return camera smoothly to center when standing still or airborne
		camera.transform.origin = camera.transform.origin.lerp(Vector3.ZERO, delta * 10.0)
		
	move_and_slide()
	
func _headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * BOB_FREQUENCY) * BOB_AMPLITUDE
	pos.x = cos(time * BOB_FREQUENCY / 2) * BOB_AMPLITUDE
	return pos
	
func take_damage(amount: float, attacker: Node3D = null):
	hp -= amount
	print("Player HP: ", hp)
	if hp <= 0:
		die()

func die():
	print("Player Died")
	# Game over/respawn logic goes here
	
func get_hp() -> float:
	return hp
