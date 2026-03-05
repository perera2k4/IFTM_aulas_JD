extends Area2D

func _ready():
	body_entered.connect(_on_body_entered)
	
func _on_body_entered(body):
	if body.name == "player" or body is CharacterBody2D:
		print("Player coletou o morango!")
		queue_free() # Remove o strawberry
