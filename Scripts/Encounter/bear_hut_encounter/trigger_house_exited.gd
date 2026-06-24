extends Area3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("Bear hut exited: ", GameManager.bear_hut_exited)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		if GameManager.bear_hut_entered == false:
			GameManager.bear_hut_exited = false
		elif GameManager.bear_hut_entered == true:
			GameManager.bear_hut_exited = true
	
	print("Bear hut exited: ", GameManager.bear_hut_exited)
