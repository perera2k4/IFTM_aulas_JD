extends Node2D

@onready var guy: Sprite2D = $guy


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Função executada sempre que o componente é carregado na memória
	print("Cena principal totalmente carregada")
	
	guy.position.x = 200
	guy.position.y = 200
	
	# Pode ser alterado a posição por vetores com:
	# guy.position = Vector2(x, y)
	
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Um dos métodos para sincronização da taxa de quadros por segundo (fps)
	#var vel = 0.016/0.008
	
	# Fazer a imagem se mover 1x por segundo
	#guy.position.x = guy.position.x + vel
	
	# Construção de uma ação de movimento
	# Mover para a direita
	if Input.is_action_pressed("ui_right"):
		guy.position.x += 10
		
	
	# Mover para a esquerda
	if Input.is_action_pressed("ui_left"):
		guy.position.x -= 10
		
	# Mover para a cima
	if Input.is_action_pressed("ui_up"):
		guy.position.y -= 10
		
	# Mover para a baixo
	if Input.is_action_pressed("ui_down"):
		guy.position.y += 10

	# Dimensões da janela: 1152x648
	
	# Separando o tamanho do sprite para colidir com a parede
	var imgWidth = guy.texture.get_width() / 10
	var imgHeight = guy.texture.get_height() / 9
	
	# Limitar a resolução que ele pode andar
	# Limite da direta x+
	if guy.position.x >= 1152 - imgWidth:
		guy.position.x = 1152 - imgWidth
	# Limite da esqueda x-
	elif guy.position.x <= 0 + imgWidth:
		guy.position.x = 0 + imgWidth
		
	# Limite baixo y+
	if guy.position.y >= 648 - imgHeight:
		guy.position.y = 648 - imgHeight
	# Limite alto y-
	elif guy.position.y <= 0 + imgHeight:
		guy.position.y = 0  + imgHeight
	
	pass
