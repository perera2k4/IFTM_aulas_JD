extends Area2D

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	anim.play("moranguinho")
	# Conectar o sinal quando algo entra na área
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	# Verificar se é o player que colidiu
	if body.name == "player":
		print("Player coletou o moranguinho")
		# Trocar para a fase 2
		get_tree().change_scene_to_file("res://scenes/phase_2.tscn")
