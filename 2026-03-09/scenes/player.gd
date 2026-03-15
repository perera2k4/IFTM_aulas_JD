extends CharacterBody2D

# Variáveis globais
var speed = 200
var gravity = 980
var jumpVelocity = -400
var attempJump = 0

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var object: TileMapLayer = $"../map/object"

func _ready() -> void:
	pass
	
func _process(delta: float) -> void:
	# Verificar se não está no chão e aplicar efeito da gravidade
	if not is_on_floor():
		velocity.y += gravity * delta

	# Executar movimentos laterais eixo X
	var direction = Input.get_axis("move_left", "move_right")
	velocity.x = direction * speed
	
	# Verificar se o personagem está no chão
	if is_on_floor():
		attempJump = 0
	
	# Pulo e pulo duplo
	if Input.is_action_just_pressed("jump"):
		attempJump += 1
		if attempJump <= 2:
			velocity.y = jumpVelocity
		else:
			print("Sem pulos restantes")

	move_and_slide()
	
	# Detectar colisões com áreas (strawberries)
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if collider and collider.is_in_group("collectibles"):
			print("Coletou:", collider.name)
			collider.queue_free()
	
	# Controle de animações
	if is_on_floor():
		if velocity.x == 0:
			anim.play("idle")
		else:
			anim.play("walk")
	else:
		if Input.is_action_pressed("jump"):
			anim.play("jump")
		elif velocity.y > 0:
			anim.play("fall")
	
	if direction < 0:
		anim.flip_h = true
	elif direction > 0:
		anim.flip_h = false

	# Verificar se caiu do mapa
	# if position.y >= 950 and get_tree().current_scene.name == "main":
	if position.y >= 950:
		get_tree().change_scene_to_file("res://scenes/main.tscn")
