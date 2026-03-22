extends Node2D

# Nomeando esse elemento
class_name Spike

signal damaged

func _on_area_2d_area_entered(area: Area2D) -> void:
	damaged.emit()
	
