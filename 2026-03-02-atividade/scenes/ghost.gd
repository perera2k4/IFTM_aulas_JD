extends AnimatedSprite2D

@onready var ghost: AnimatedSprite2D = $"."

func _ready() -> void:
	anim.play("ghost")
	# Conectar o sinal quando algo entra na área
	

func _on_body_entered(body: Node2D) -> void:
	# Verificar se é o player que colidiu e troca a cena
	if body.name == "player":
		get_tree().change_scene_to_file("res://scenes/phase_2.tscn")
