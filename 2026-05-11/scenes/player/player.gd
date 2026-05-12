extends CharacterBody2D

class_name Player

var speed = 150
var dir = "down" ## down | up | left | right

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

func _physics_process(delta: float) -> void:
	var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = direction * speed
	
	if direction.y > 0:
		dir = "down"
	elif direction.y < 0:
		dir = "up"
	elif direction.x > 0:
		dir = "right"
	elif direction.x < 0:
		dir = "left"
		
	if direction.x == 0 and direction.y == 0:
		animated_sprite_2d.play("idle-" + dir)
	else:
		animated_sprite_2d.play("walk-" + dir)
	
	move_and_collide(velocity * delta)
