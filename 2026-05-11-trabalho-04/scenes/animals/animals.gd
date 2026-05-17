extends CharacterBody2D

class_name Animals

@export var speed: float = 70.0

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var navigation_agent_2d: NavigationAgent2D = $NavigationAgent2D
@onready var action_timer: Timer = $ActionTimer

var _current_action: StringName = &"idle"
var _rng := RandomNumberGenerator.new()
var _actions := [&"walk", &"walk", &"walk", &"idle", &"sleep", &"lift", &"sit", &"eat"]

func _ready() -> void:
	_rng.randomize()
	action_timer.timeout.connect(_on_action_timer_timeout)
	_pick_random_action()

func _physics_process(delta: float) -> void:
	if _current_action != &"walk":
		velocity = Vector2.ZERO
		move_and_slide()
		return

	if navigation_agent_2d.is_navigation_finished():
		velocity = Vector2.ZERO
		move_and_slide()
		return

	var next_pos = navigation_agent_2d.get_next_path_position()
	var direction = (next_pos - global_position).normalized()
	velocity = direction * speed
	if velocity.x != 0.0:
		animated_sprite_2d.flip_h = velocity.x < 0.0
	move_and_slide()

func _on_action_timer_timeout() -> void:
	_pick_random_action()

func _pick_random_action() -> void:
	var index = _rng.randi_range(0, _actions.size() - 1)
	_current_action = _actions[index]
	animated_sprite_2d.play(_current_action)
	if _current_action == &"walk":
		_pick_random_target()

func _pick_random_target() -> void:
	var nav_map := navigation_agent_2d.get_navigation_map()
	if nav_map == RID():
		navigation_agent_2d.target_position = global_position
		return

	var target = NavigationServer2D.map_get_random_point(
		nav_map,
		navigation_agent_2d.navigation_layers,
		false
	)
	navigation_agent_2d.target_position = target
