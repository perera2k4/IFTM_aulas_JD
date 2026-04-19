extends CharacterBody2D

class_name Player

@onready var weapon: Node2D = $weapon
@onready var spawn_timer_label: Label = $Camera2D/HBoxContainer/Label
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@export var bullet_scene: PackedScene

var speed = 150
var spawn_timer: Timer
var player_navigation_region_rid: RID

# inicia a area permitida de movimento
func _ready() -> void:
	spawn_timer = get_parent().get_node_or_null("SpawnTimer") as Timer
	var player_nav_region := get_parent().get_node_or_null("PlayerNavigationRegion2D") as NavigationRegion2D
	if player_nav_region:
		player_navigation_region_rid = player_nav_region.get_rid()
	_update_spawn_timer_label()

# atualiza o texto da interface
func _process(_delta: float) -> void:
	_update_spawn_timer_label()

# processa movimento, rotacao da arma e disparo do player
func _physics_process(delta: float) -> void:
	if _is_game_over():
		velocity = Vector2.ZERO
		return

	var direction = Input.get_vector("walk_left", "walk_right", "walk_up", "walk_down")
	velocity = direction * speed
	var movement := velocity * delta
	
	# troca de direção ao clicar esquerda/direita
	if direction.x < 0.0:
		anim.flip_h = true
		weapon.scale.y = -1.0
	elif direction.x > 0.0:
		anim.flip_h = false
		weapon.scale.y = 1.0

	if player_navigation_region_rid.is_valid():
		var desired_position := global_position + movement
		var clamped_position := NavigationServer2D.region_get_closest_point(
			player_navigation_region_rid,
			desired_position
		)
		movement = clamped_position - global_position
	
	var mouse = get_global_mouse_position()
	weapon.look_at(mouse)
	
	# se apertão o botao esquerdo do mouse ira disparar
	if Input.is_action_just_pressed("shoot"):
		fire()
		
	move_and_collide(movement)
	
# faz o tiro na ponta da arma
func fire():
	var bullet = bullet_scene.instantiate()
	bullet.global_position = weapon.global_position + Vector2(10, 0)
	bullet.rotation_degrees = weapon.rotation_degrees
	get_tree().root.add_child(bullet)
	
# mostra o status da partida e cronometro na hud
func _update_spawn_timer_label() -> void:
	if _is_victory():
		spawn_timer_label.text = "VITORIA"
		return
		
	if _is_game_over():
		spawn_timer_label.text = "GAME OVER"
		return
		
	if spawn_timer == null:
		spawn_timer_label.text = "--s"
		return
		
	var seconds_left = ceili(spawn_timer.time_left)
	if spawn_timer.is_stopped():
		seconds_left = ceili(spawn_timer.wait_time)
		
	spawn_timer_label.text = "%ds" % seconds_left
	
# verifica se a partida terminou por derrota
func _is_game_over() -> bool:
	var main_node = get_parent()
	if main_node and main_node.has_method("is_game_over_state"):
		return main_node.is_game_over_state()
		
	return false
	
# verifica se a partida terminou por vitoria
func _is_victory() -> bool:
	var main_node = get_parent()
	if main_node and main_node.has_method("is_victory_state"):
		return main_node.is_victory_state()
		
	return false
	
