extends Node2D

@onready var robot: Sprite2D = $robot


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Função executada sempre que o componente é carregado na memória
	print("Cena principal totalmente carregada")
	
	robot.position.x = 200
	robot.position.y = 200
	
	# Pode ser alterado a posição por vetores com:
	# robot.position = Vector2(x, y)
	
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Um dos métodos para sincronização da taxa de quadros por segundo (fps)
	#var vel = 0.016/0.008
	
	# Fazer a imagem se mover 1x por segundo
	#robot.position.x = robot.position.x + vel
	
	# Construção de uma ação de movimento
	# Mover para a direita
	if Input.is_action_pressed("ui_right"):
		robot.position.x += 10
	
	# Mover para a esquerda
	if Input.is_action_pressed("ui_left"):
		robot.position.x -= 10
		
	# Mover para a cima
	if Input.is_action_pressed("ui_up"):
		robot.position.y -= 10
		
	# Mover para a baixo
	if Input.is_action_pressed("ui_down"):
		robot.position.y += 10
	
	pass
