extends Node2D

signal fruit_collected

func _ready() -> void:
	pass

func _on_area_2d_area_entered(area: Area2D) -> void:
	fruit_collected.emit()
	queue_free() #Remove este nó do jogo
