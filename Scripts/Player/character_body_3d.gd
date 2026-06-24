extends CharacterBody3D

# Player variables
const SPEED = 8.0
const JUMP_VELOCITY = 4.5
@export var max_hp = 10.0
var hp = max_hp

# Sensitivity 
const SENSITIVITY = 0.001

# Head bob variables
const BOB_FREQUENCY = 3.0
const BOB_AMPLITUDE = 0.05
var bob_time = 0.0

# Attack variables
var can_attack : bool = true

# Onready variables
@onready var upper_body_pivot = $UpperBodyPivot
@onready var camera = $UpperBodyPivot/Camera3D
@onready var hitbox = $UpperBodyPivot/Hands/Sword/Hitbox
@onready var hands = $UpperBodyPivot/Hands

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event: InputEvent) -> void:
	# Input for quitting the game
	if Input.is_action_pressed("Exit"):
		get_tree().quit()
	
	if event is InputEventMouseMotion:
		# 1. Rotate the WHOLE player horizontally on the Y axis
		rotate_y(-event.relative.x * SENSITIVITY)
		
		# 2. Rotate ONLY the camera pivot vertically on the X axis
		upper_body_pivot.rotate_x(-event.relative.y * SENSITIVITY)
		upper_body_pivot.rotation.x = clamp(upper_body_pivot.rotation.x, deg_to_rad(-90), deg_to_rad(90))
		
	if event.is_action_pressed("Attack") and can_attack:
		attack()
		print("attack")
		
		
# Attack function
func attack():
	play_swing()
	can_attack = false
	hitbox.monitoring = true
	
	# How long the hitbox is live on attack
	await get_tree().create_timer(0.2).timeout
	hitbox.monitoring = false
	
	# Attack cooldown
	await get_tree().create_timer(0.4).timeout
	can_attack = true

# Dealing damage
func _on_hitbox_body_entered(body: Node):
	print("Sword hit: ", body.name, " | has take_damage: ", body.has_method("take_damage"))
	if body.is_in_group("enemy") and body.has_method("take_damage"):
		body.take_damage(1)
		
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
			velocity.x = lerp(velocity.x, direction.x * SPEED, delta * 5.0)
			velocity.z = lerp(velocity.z, direction.z * SPEED, delta * 5.0)
		else:
			velocity.x = lerp(velocity.x, 0.0, delta * 7.0)
			velocity.z = lerp(velocity.z, 0.0, delta * 7.0)
	else:
		velocity.x = lerp(velocity.x, direction.x * SPEED, delta * 2.0)
		velocity.z = lerp(velocity.z, direction.z * SPEED, delta * 2.0)
		
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
	
func take_damage(amount: int):
	hp -= amount
	print("Player HP: ", hp)
	if hp <= 0:
		die()

func die():
	print("Player Died")
	# Game over/respawn logic goes here
	
func get_hp() -> float:
	return hp
