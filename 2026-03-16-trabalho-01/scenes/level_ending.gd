extends Node2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

signal level_passed

func _ready() -> void :
	animated_sprite_2d.play("default")
	
func _process(delta: float) -> void:
	pass
	
func _on_area_2d_area_entered(area: Area2D) -> void:
	level_passed.emit()
	# Troca para proxima cena
	get_tree().change_scene_to_file("res://scenes/levels/level_2.tscn")
