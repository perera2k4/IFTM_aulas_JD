extends CharacterBody2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

@export var cell_size := 48.0
@export var lane_height := 64.0
@export var move_duration := 0.18

var _is_moving := false
var _target_pos := Vector2.ZERO
var _min_x := -400.0
var _max_x := 400.0
var _min_y := 0

func _ready() -> void:
	animated_sprite_2d.play("idle")
	_target_pos = global_position
	_update_bounds_from_viewport()
	queue_redraw()

func set_bounds(min_x: float, max_x: float) -> void:
	_min_x = min_x
	_max_x = max_x

func set_min_y(min_y: float) -> void:
	_min_y = min_y

func _unhandled_input(_event: InputEvent) -> void:
	if _is_moving:
		return
	var move := Vector2.ZERO
	if Input.is_action_just_pressed("ui_up"):
		animated_sprite_2d.play("up")
		move = Vector2(0, -lane_height)
	elif Input.is_action_just_pressed("ui_down"):
		if global_position.y >= _min_y:
			return
		animated_sprite_2d.play("down")
		move = Vector2(0, lane_height)
	elif Input.is_action_just_pressed("ui_left"):
		animated_sprite_2d.play("left")
		move = Vector2(-cell_size, 0)
	elif Input.is_action_just_pressed("ui_right"):
		animated_sprite_2d.play("right")
		move = Vector2(cell_size, 0)

	if move == Vector2.ZERO:
		return

	var raw: Vector2 = global_position + move
	var clamped_x: float = clampf(raw.x, _min_x, _max_x)
	var clamped_y: float = clampf(raw.y, -1e9, _min_y)
	_target_pos = Vector2(clamped_x, clamped_y)
	_is_moving = true
	var tween := create_tween()
	tween.tween_property(self, "global_position", _target_pos, move_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.finished.connect(_on_move_finished)

func _on_move_finished() -> void:
	_is_moving = false
	animated_sprite_2d.play("idle")

func is_moving() -> bool:
	return _is_moving

func _update_bounds_from_viewport() -> void:
	var half_width := get_viewport_rect().size.x * 0.5
	_min_x = -half_width + cell_size * 0.5
	_max_x = half_width - cell_size * 0.5
