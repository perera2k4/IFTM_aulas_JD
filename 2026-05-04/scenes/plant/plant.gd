extends Node2D

@onready var timer: Timer = $Timer
@onready var sprite_2d: Sprite2D = $Sprite2D

var phase = 1

func _on_timer_timeout() -> void:
	if phase < 4:
		phase += 1
		sprite_2d.frame += 1
