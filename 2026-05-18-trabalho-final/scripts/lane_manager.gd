extends Node2D

signal player_hit

@export var lane_height := 64.0
@export var cell_size := 48.0
@export var lanes_ahead := 12
@export var lanes_behind := 6
@export var road_chance := 0.6

const LANE_GRASS := 0
const LANE_ROAD := 1
const LANE_WATER := 2
const MAX_ROAD_STREAK := 4

var _lane_scene := preload("res://scenes/Lane.tscn")
var _lanes: Dictionary = {}
var _lane_types: Dictionary = {}
var _player: CharacterBody2D
var _rng := RandomNumberGenerator.new()
var _world_half_width := 480.0

func _ready() -> void:
	_rng.randomize()
	_update_world_width()

func initialize(player: CharacterBody2D) -> void:
	_player = player
	_reset_state()
	_ensure_lanes(_current_row())
	_player.call("set_bounds", -_world_half_width + cell_size * 0.5, _world_half_width - cell_size * 0.5)

func reset_world() -> void:
	_reset_state()
	_ensure_lanes(_current_row())

func _process(_delta: float) -> void:
	if _player == null:
		return
	_ensure_lanes(_current_row())

func _update_world_width() -> void:
	_world_half_width = get_viewport_rect().size.x * 0.5 + 120.0

func _current_row() -> int:
	return int(round(-_player.global_position.y / lane_height))

func _ensure_lanes(center_row: int) -> void:
	_update_world_width()
	var min_row := center_row - lanes_behind
	var min_row_clamped: int = maxi(min_row, 0)
	var max_row := center_row + lanes_ahead
	for row in range(min_row_clamped, max_row + 1):
		if not _lanes.has(row):
			_create_lane(row)

	var to_remove: Array = []
	for row in _lanes.keys():
		if row < min_row_clamped - 2 or row > max_row + 2:
			to_remove.append(row)
	for row in to_remove:
		_lanes[row].queue_free()
		_lanes.erase(row)

func _create_lane(row: int) -> void:
	var lane_type := _get_lane_type(row)
	var lane: Node2D = _lane_scene.instantiate()
	lane.call("setup", lane_type, row, lane_height, _world_half_width * 2.0, _rng, _player)
	lane.connect("player_hit", _on_lane_player_hit)
	add_child(lane)
	_lanes[row] = lane

func _get_lane_type(row: int) -> int:
	if _lane_types.has(row):
		return _lane_types[row]
	if row == 0:
		_lane_types[row] = LANE_GRASS
		return LANE_GRASS

	var prev_row := row - 1
	var prev_type: int = int(_lane_types.get(prev_row, LANE_GRASS))

	# Never place two consecutive water lanes
	if prev_type != LANE_WATER and _rng.randf() < 0.1:
		_lane_types[row] = LANE_WATER
		return LANE_WATER

	var road_streak := 0
	var check_row := prev_row
	while _lane_types.has(check_row) and _lane_types[check_row] == LANE_ROAD:
		road_streak += 1
		check_row -= 1

	var next_type := LANE_GRASS
	if prev_type == LANE_ROAD and road_streak >= MAX_ROAD_STREAK:
		next_type = LANE_GRASS
	elif prev_type == LANE_ROAD:
		next_type = LANE_ROAD if _rng.randf() < road_chance * 0.5 else LANE_GRASS
	else:
		next_type = LANE_ROAD if _rng.randf() < road_chance else LANE_GRASS
	_lane_types[row] = next_type
	return next_type

func _reset_state() -> void:
	for lane in _lanes.values():
		lane.queue_free()
	_lanes.clear()
	_lane_types.clear()

func _on_lane_player_hit() -> void:
	emit_signal("player_hit")

func get_camera_limits(center_row: int) -> Rect2:
	_update_world_width()
	var min_row := center_row - lanes_behind
	var max_row := center_row + lanes_ahead
	var top := -max_row * lane_height
	var bottom := lane_height  # fixed: never scroll below start row
	var left := -_world_half_width
	var right := _world_half_width
	return Rect2(Vector2(left, top), Vector2(right - left, bottom - top))
