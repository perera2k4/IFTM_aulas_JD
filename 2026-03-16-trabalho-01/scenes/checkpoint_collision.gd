extends Node2D

signal checkpoint_is_picked

func _ready() -> void :
	pass
	
func _process(delta: float) -> void:
	pass
	
func _on_area_2d_area_entered(area: Area2D) -> void:
	checkpoint_is_picked.emit()
	queue_free()
