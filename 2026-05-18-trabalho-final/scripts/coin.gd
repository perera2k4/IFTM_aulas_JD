extends Area2D

var coin_type := COIN_BUFF
var _bob_time := 0.0

signal collected(coin_type: int)

const COIN_BUFF := 0
const COIN_DEBUFF := 1
const FRAME_SIZE := Vector2(16, 16)
const ATLAS_COLUMNS := 12
const BUFF_FRAME := Vector2(5, 4)
const DEBUFF_FRAME := Vector2(0, 0)

@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	_update_sprite()

func setup(type: int) -> void:
	coin_type = type
	if is_inside_tree():
		_update_sprite()
	else:
		call_deferred("_update_sprite")

func _process(delta: float) -> void:
	_bob_time += delta * 3.0
	if sprite != null:
		sprite.position.y = sin(_bob_time) * 3.0

func _update_sprite() -> void:
	if sprite == null:
		return
	var frame_pos: Vector2
	if coin_type == COIN_BUFF:
		frame_pos = BUFF_FRAME
	else:
		frame_pos = DEBUFF_FRAME
	sprite.region_enabled = true
	sprite.region_rect = Rect2(
		frame_pos.x * FRAME_SIZE.x,
		frame_pos.y * FRAME_SIZE.y,
		FRAME_SIZE.x,
		FRAME_SIZE.y
	)
	sprite.scale = Vector2(2.0, 2.0)
	
	if coin_type == COIN_BUFF:
		sprite.modulate = Color(0.3, 1.0, 0.5, 1.0)
	else:
		sprite.modulate = Color(1.0, 0.3, 0.3, 1.0)

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		emit_signal("collected", coin_type)
		_play_collect_effect()

func _play_collect_effect() -> void:
	set_deferred("monitoring", false)
	var col_shape = get_node_or_null("CollisionShape2D")
	if col_shape:
		col_shape.set_deferred("disabled", true)
	
	if sprite == null:
		queue_free()
		return
	
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(sprite, "scale", Vector2(3.5, 3.5), 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(sprite, "modulate:a", 0.0, 0.3).set_trans(Tween.TRANS_SINE)
	tween.tween_property(sprite, "position:y", sprite.position.y - 20.0, 0.3).set_trans(Tween.TRANS_SINE)
	tween.chain().tween_callback(queue_free)
