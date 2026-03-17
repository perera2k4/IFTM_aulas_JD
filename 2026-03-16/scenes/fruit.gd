extends Node2D

signal fruit_collected

func _ready() -> void:
	print("Fruta Abacaxi")
	pass

func _on_area_2d_area_entered(area: Area2D) -> void:
	print("Pegou uma fruta")
	fruit_collected.emit()
	queue_free() #Remove este nó do jogo
