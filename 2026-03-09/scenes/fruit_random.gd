extends Node2D

signal fruit_random_collected

@export var types_fruit: SpriteFrames

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	pass
	
func _on_area_2d_2_area_entered(_area: Area2D) -> void:
	print("PEGOU UMA FRUTA")
	fruit_random_collected.emit()
	queue_free()
