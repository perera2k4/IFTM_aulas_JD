extends CharacterBody2D

class_name enemy

@onready var nav: NavigationAgent2D = $NavigationAgent2D
@onready var health_bar: ProgressBar = $ProgressBar
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

var speed = 100
var target
var health_percent := 100.0
var damage_per_hit := 50.0

# inicia o alvo e sincroniza a barra de vida.
func _ready() -> void:
	## Busca o alvo, no caso o g_player
	target = get_tree().get_first_node_in_group("g_player")
	if target:
		nav.target_position = target.global_position
		
	_update_health_bar()
	
# persegue o player e finaliza o jogo se encostar nele
func _physics_process(delta: float) -> void:
	var main_node = get_parent()
	if main_node and main_node.has_method("is_game_over_state") and main_node.is_game_over_state():
		velocity = Vector2.ZERO
		return

	if !target:
		target = get_tree().get_first_node_in_group("g_player")
		if !target:
			velocity = Vector2.ZERO
			return

	## atualiza a posição do alvo
	nav.target_position = target.global_position
	
	## caso não tenha chegado no alvo continua procurando
	if !nav.is_target_reached():
		var next_point = nav.get_next_path_position()
		var direction = (next_point - global_position).normalized()
		if direction.x < 0.0:
			anim.flip_h = true
		elif direction.x > 0.0:
			anim.flip_h = false
		velocity = direction * speed
		var collision = move_and_collide(velocity * delta)
		if collision:
			var collider = collision.get_collider()
			if collider is Player:
				_trigger_game_over()
	else:
		velocity = Vector2.ZERO
		
# recebe dano de tiros, atualiza vida e remove inimigo ao morrer
func _on_area_damaged_area_entered(area: Area2D) -> void:
	if area is Bullet:
		health_percent = max(0.0, health_percent - damage_per_hit)
		_update_health_bar()
		area.queue_free()
		
		if health_percent <= 0:
			queue_free()
			
# evento ao entrar em contato com o player
func _on_area_damaged_body_entered(body: Node2D) -> void:
	if body is Player:
		print("Atingiu o player")
		
# mostra o percentual de vida na barra
func _update_health_bar() -> void:
	health_bar.value = health_percent
	
# notifica a cena principal para encerrar a partida
func _trigger_game_over() -> void:
	var main_node = get_parent()
	if main_node and main_node.has_method("trigger_game_over"):
		main_node.trigger_game_over()
		
