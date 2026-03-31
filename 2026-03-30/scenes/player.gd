extends CharacterBody2D

var speed = 150
@onready var weapon: Node2D = $weapon

func _process(delta: float) -> void:
	var direction = Input.get_vector("walk_left", "walk_right", "walk_up", "walk_down")
	velocity = direction * speed
	
	var mouse = get_global_mouse_position()
	weapon.look_at(mouse)
	
	move_and_collide(velocity * delta)
