extends Node2D

@onready var lane_manager: Node2D = $LaneManager
@onready var player: CharacterBody2D = $Player
@onready var camera: Camera2D = $Player/Camera2D
@onready var score_label: Label = $UI/ScoreLabel

var score := 0
var best_score := 0

func _ready() -> void:
	player.add_to_group("player")
	player.set("cell_size", lane_manager.get("cell_size"))
	player.set("lane_height", lane_manager.get("lane_height"))
	lane_manager.call("initialize", player)
	lane_manager.connect("player_hit", _on_player_hit)
	_update_score(0)
	_update_camera_limits(0)

func _process(_delta: float) -> void:
	var lane_height: float = lane_manager.get("lane_height")
	if lane_height <= 0.0:
		return
	var row := int(round(-player.global_position.y / lane_height))
	if row > score:
		_update_score(row)
	_update_camera_limits(row)

func _update_score(value: int) -> void:
	score = value
	best_score = max(best_score, score)
	

func _update_camera_limits(row: int) -> void:
	if camera == null:
		return
	var limits: Rect2 = lane_manager.call("get_camera_limits", row)
	camera.limit_left = limits.position.x
	camera.limit_top = limits.position.y
	camera.limit_right = limits.position.x + limits.size.x
	camera.limit_bottom = limits.position.y + limits.size.y

func _on_player_hit() -> void:
	best_score = max(best_score, score)
	score = 0
	lane_manager.call("reset_world")
	player.global_position = Vector2(0, 0)
	_update_score(0)
