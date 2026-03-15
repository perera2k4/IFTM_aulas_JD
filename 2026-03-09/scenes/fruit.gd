extends Node2D

signal fruit_collected

func _ready() -> void:
	pass
	
func _on_area_2d_area_entered(_area: Area2D) -> void:
	# Emite o sinal de que o item foi coletado (Nesse caso algo entrou na sua area 2d)
	fruit_collected.emit()
	queue_free() # Remove este nó do jogo
