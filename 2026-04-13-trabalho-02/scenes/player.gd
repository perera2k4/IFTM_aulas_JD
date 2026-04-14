extends CharacterBody2D

class_name Player

@onready var weapon: Node2D = $weapon
@onready var spawn_timer_label: Label = $Camera2D/HBoxContainer/Label
@export var bullet_scene: PackedScene

var speed = 150
var spawn_timer: Timer

func _ready() -> void:
	spawn_timer = get_parent().get_node_or_null("SpawnTimer") as Timer
	_update_spawn_timer_label()


func _process(_delta: float) -> void:
	_update_spawn_timer_label()

func _physics_process(delta: float) -> void:
	if _is_game_over():
		velocity = Vector2.ZERO
		return

	var direction = Input.get_vector("walk_left", "walk_right", "walk_up", "walk_down")
	velocity = direction * speed
	
	var mouse = get_global_mouse_position()
	weapon.look_at(mouse)
	
	# Se apertão o botão esquerdo do mouse irá disparar
	if Input.is_action_just_pressed("shoot"):
		fire()
	
	move_and_collide(velocity * delta)

func fire():
	var bullet = bullet_scene.instantiate()
	bullet.global_position = weapon.global_position + Vector2(10, 0)
	bullet.rotation_degrees = weapon.rotation_degrees
	get_tree().root.add_child(bullet)


func _update_spawn_timer_label() -> void:
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


func _is_game_over() -> bool:
	var main_node = get_parent()
	if main_node and main_node.has_method("is_game_over_state"):
		return main_node.is_game_over_state()

	return false
