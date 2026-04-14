extends CharacterBody2D

class_name enemy

@onready var nav: NavigationAgent2D = $NavigationAgent2D
@onready var health_bar: ProgressBar = $ProgressBar

var speed = 100
var target
var health_percent := 100.0
var damage_per_hit := 50.0

func _ready() -> void:
	## Busca o alvo, no caso o g_player
	target = get_tree().get_first_node_in_group("g_player")
	if target:
		nav.target_position = target.global_position

	_update_health_bar()

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

	## Atualiza a posição do alvo
	nav.target_position = target.global_position
	
	## Caso não tenha chegado no alvo continua procurando	
	if !nav.is_target_reached():
		var next_point = nav.get_next_path_position()
		var direction = (next_point - global_position).normalized()
		velocity = direction * speed
		var collision = move_and_collide(velocity * delta)
		if collision:
			var collider = collision.get_collider()
			if collider is Player:
				_trigger_game_over()
	else:
		velocity = Vector2.ZERO


func _on_area_damaged_area_entered(area: Area2D) -> void:
	if area is Bullet:
		health_percent = max(0.0, health_percent - damage_per_hit)
		_update_health_bar()
		area.queue_free()

		if health_percent <= 0:
			queue_free()
			
func _on_area_damaged_body_entered(body: Node2D) -> void:
	if body is Player:
		print("Atingiu o player")

func _update_health_bar() -> void:
	health_bar.value = health_percent


func _trigger_game_over() -> void:
	var main_node = get_parent()
	if main_node and main_node.has_method("trigger_game_over"):
		main_node.trigger_game_over()
