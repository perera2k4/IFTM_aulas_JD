extends CharacterBody2D

class_name enemy
@onready var nav: NavigationAgent2D = $NavigationAgent2D

var speed = 100
var target

func _ready() -> void:
	## Busca o alvo, no caso o g_player
	target = get_tree().get_first_node_in_group("g_player")
	nav.target_position = target.global_position

func _physics_process(delta: float) -> void:
	## Atualiza a posição do alvo
	if target:
		nav.target_position = target.global_position
	
	## Caso não tenha chegado no alvo continua procurando	
	if !nav.is_target_reached():
		var next_point = nav.get_next_path_position()
		var direction = (next_point - global_position).normalized()
		velocity = direction * speed
		move_and_collide(velocity * delta)
