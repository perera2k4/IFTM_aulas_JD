extends Node2D

@onready var ghost: AnimatedSprite2D = $ghost
var points = 0

func _ready() -> void:
	ghost.play("ghost")
	
	var all_fruits = get_tree().get_nodes_in_group("g_fruits")
	for fruit in all_fruits:
		print(fruit)
		fruit.fruit_collected.connect(_on_fruit_collected)
	
func _process(_delta: float) -> void:
	pass
	
func _on_fruit_collected():
	points += 1
	print("Pontos: ", points)
