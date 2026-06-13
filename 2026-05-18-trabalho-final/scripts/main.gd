extends Node2D

@onready var lane_manager: Node2D = $LaneManager
@onready var player: CharacterBody2D = $Player
@onready var camera: Camera2D = $Player/Camera2D
@onready var score_label: Label = $UI/HudAnchor/HudCenter/HudPanel/HBoxContainer/ScoreLabel
@onready var best_label: Label = $UI/HudAnchor/HudCenter/HudPanel/HBoxContainer/BestLabel
@onready var buff_panel: PanelContainer = $UI/HudAnchor/HudCenter/HudPanel/HBoxContainer/BuffPanel
@onready var buff_timer_label: Label = $UI/HudAnchor/HudCenter/HudPanel/HBoxContainer/BuffPanel/BuffTimerLabel
@onready var lily_panel: PanelContainer = $UI/HudAnchor/HudCenter/HudPanel/HBoxContainer/LilyPanel
@onready var lily_timer_label: Label = $UI/HudAnchor/HudCenter/HudPanel/HBoxContainer/LilyPanel/LilyTimerLabel
@onready var game_over_overlay: Control = $UI/GameOverOverlay

var _is_game_over := false
var score := 0
var best_score := 0
var _effect_timer := 0.0
var _active_effect := -1 
var _warmup_timer := 0.0

const COIN_BUFF := 0
const COIN_DEBUFF := 1
const EFFECT_DURATION := 5.0
const BUFF_SPEED_MULTIPLIER := 0.5
const DEBUFF_SPEED_MULTIPLIER := 1.8
const WARMUP_DURATION := 0.3
const WARMUP_MULTIPLIER := 100.0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	lane_manager.process_mode = Node.PROCESS_MODE_PAUSABLE
	player.process_mode = Node.PROCESS_MODE_PAUSABLE
	
	player.add_to_group("player")
	player.set("cell_size", lane_manager.get("cell_size"))
	player.set("lane_height", lane_manager.get("lane_height"))
	lane_manager.call("initialize", player)
	lane_manager.connect("player_hit", _on_player_hit)
	if lane_manager.has_signal("coin_collected"):
		lane_manager.connect("coin_collected", _on_coin_collected)
	_update_score(0)
	_update_camera_limits(0)
	_update_buff_label()
	_start_warmup()

func _process(delta: float) -> void:
	if _is_game_over or get_tree().paused:
		return
		
	var lane_height: float = lane_manager.get("lane_height")
	if lane_height <= 0.0:
		return
	var row := int(round(-player.global_position.y / lane_height))
	if row > score:
		_update_score(row)
	_update_camera_limits(row)
	
	if _active_effect >= 0:
		_effect_timer -= delta
		if _effect_timer <= 0.0:
			_clear_effect()
		else:
			_update_buff_label()
	
	if _warmup_timer > 0.0:
		_warmup_timer -= delta
		if _warmup_timer <= 0.0:
			Vehicle.warmup_multiplier = 1.0
	
	_update_lily_label()

func _update_score(value: int) -> void:
	score = value
	best_score = max(best_score, score)
	if score_label != null:
		score_label.text = "🏆 %d" % score
	if best_label != null:
		best_label.text = "⭐ %d" % best_score

func _update_camera_limits(row: int) -> void:
	if camera == null:
		return
	var limits: Rect2 = lane_manager.call("get_camera_limits", row)
	camera.limit_left = limits.position.x
	camera.limit_top = limits.position.y
	camera.limit_right = limits.position.x + limits.size.x
	camera.limit_bottom = limits.position.y + limits.size.y

func _on_player_hit() -> void:
	if _is_game_over:
		return
	
	_is_game_over = true
	best_score = max(best_score, score)
	
	if game_over_overlay != null:
		game_over_overlay.visible = true
	
	get_tree().paused = true

func _unhandled_input(event: InputEvent) -> void:
	if not _is_game_over:
		return
		
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_R:
			_restart_game()
		elif event.keycode == KEY_ESCAPE:
			get_tree().paused = false
			get_tree().change_scene_to_file("res://scenes/Menu.tscn")

func _restart_game() -> void:
	_is_game_over = false
	game_over_overlay.visible = false
	get_tree().paused = false
	
	score = 0
	_clear_effect()
	lane_manager.call("reset_world")
	player.global_position = Vector2(0, 0)
	_start_warmup()
	_update_score(0)

func _on_coin_collected(coin_type: int) -> void:
	_active_effect = coin_type
	_effect_timer = EFFECT_DURATION
	
	if coin_type == COIN_BUFF:
		Vehicle.speed_modifier = BUFF_SPEED_MULTIPLIER
	else:
		Vehicle.speed_modifier = DEBUFF_SPEED_MULTIPLIER
	
	_update_buff_label()

func _clear_effect() -> void:
	_active_effect = -1
	_effect_timer = 0.0
	Vehicle.speed_modifier = 1.0
	_update_buff_label()

func _update_buff_label() -> void:
	if buff_timer_label == null or buff_panel == null:
		return
	
	if _active_effect < 0:
		buff_panel.visible = false
		return
	
	buff_panel.visible = true
	var time_left := ceili(_effect_timer)
	
	if _active_effect == COIN_BUFF:
		buff_timer_label.text = "🟢 Carros lentos %ds" % time_left
		buff_timer_label.add_theme_color_override("font_color", Color(0.2, 1.0, 0.4, 1.0))
	else:
		buff_timer_label.text = "🔴 Carros rápidos %ds" % time_left
		buff_timer_label.add_theme_color_override("font_color", Color(1.0, 0.3, 0.3, 1.0))

func _update_lily_label() -> void:
	if lily_timer_label == null or lily_panel == null:
		return
	
	var time_left: float = lane_manager.call("get_water_lily_time_left")
	
	if time_left < 0.0:
		lily_panel.visible = false
		return
	
	lily_panel.visible = true
	var display_time: float = snapped(time_left, 0.1)
	lily_timer_label.text = "🍃 Vitória-régia: %.1fs" % display_time
	
	var ratio := time_left / 2.0
	var color := Color(1.0, ratio, 0.0, 1.0)
	lily_timer_label.add_theme_color_override("font_color", color)

func _start_warmup() -> void:
	_warmup_timer = WARMUP_DURATION
	Vehicle.warmup_multiplier = WARMUP_MULTIPLIER
