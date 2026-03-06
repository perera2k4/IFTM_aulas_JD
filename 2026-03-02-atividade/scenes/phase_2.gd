extends Node2D
@onready var ghost: AnimatedSprite2D = $ghost

func _ready() -> void:
	ghost.play("ghost")
	pass
	
func _process(delta: float) -> void:
	pass
