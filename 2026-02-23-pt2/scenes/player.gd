extends CharacterBody2D

# Variáveis globais
var speed = 300
var gravity = 980
var jumpVelocity = -400
var attempJump = 0

func _ready() -> void:
	pass
	
func _process(delta: float) -> void:
	# Verificar se não está no chão e aplicar efeito da gravidade
	if not is_on_floor():
		velocity.y += gravity * delta

	# Executar movimentos laterais eixo X
	var direction = Input.get_axis("ui_left", "ui_right")
	velocity.x = direction * speed
	
	# Verificar se o personagem está no chão
	if is_on_floor():
		attempJump = 0
	
	# Pulo e pulo duplo
	if Input.is_action_just_pressed("ui_up"):
		attempJump += 1
		if attempJump <= 2:
			velocity.y = jumpVelocity
		else:
			print("Sem pulos restantes")

	move_and_slide()
