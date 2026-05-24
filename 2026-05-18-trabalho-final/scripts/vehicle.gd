extends Area2D

signal player_hit

@onready var sprite_2d: Sprite2D = $Sprite2D

@export var speed := 150.0
@export var direction := 1
@export var length := 96.0
@export var height := 40.0
@export var vehicle_texture: Texture2D
@export var car_frame_size := Vector2(96, 96)
@export var car_frame_count := 20
@export var car_frame_columns := 1

var _lane_width := 900.0

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	_pick_car_frame()
	_update_sprite()
	queue_redraw()

func configure(dir: int, new_speed: float, new_length: float, new_height: float, lane_width: float) -> void:
	direction = dir
	speed = new_speed
	length = new_length
	height = new_height
	_lane_width = lane_width
	var shape := $CollisionShape2D.shape as RectangleShape2D
	if shape != null:
		shape.size = Vector2(length, height)
	_pick_car_frame()
	if is_inside_tree():
		_update_sprite()
	else:
		call_deferred("_update_sprite")
	queue_redraw()

func _physics_process(delta: float) -> void:
	position.x += speed * direction * delta
	if position.x < -_lane_width * 0.7 or position.x > _lane_width * 0.7:
		queue_free()

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		emit_signal("player_hit")

func _draw() -> void:
	return

func _update_sprite() -> void:
	if sprite_2d == null:
		return
	var tex := vehicle_texture if vehicle_texture != null else sprite_2d.texture
	if tex is AtlasTexture:
		var atlas := tex as AtlasTexture
		if atlas.atlas != null:
			tex = atlas.atlas
	if tex == null:
		return
	var tex_size := tex.get_size()
	if tex_size.x <= 0.0 or tex_size.y <= 0.0:
		return
	sprite_2d.texture = tex
	sprite_2d.position = Vector2.ZERO
	sprite_2d.rotation = 0.0
	sprite_2d.flip_h = direction < 0
	sprite_2d.flip_v = false
	sprite_2d.region_enabled = true
	var base_size := tex_size
	if sprite_2d.region_enabled:
		base_size = sprite_2d.region_rect.size
	if base_size.x <= 0.0 or base_size.y <= 0.0:
		return
	sprite_2d.scale = Vector2(length / base_size.x, height / base_size.y)

func _pick_car_frame() -> void:
	if sprite_2d == null:
		return
	if car_frame_count <= 0:
		return
	if car_frame_size.x <= 0.0 or car_frame_size.y <= 0.0:
		return
	var columns: int = max(1, car_frame_columns)
	var index: int = int(randi() % car_frame_count)
	var col: int = index % columns
	var row: int = index / columns
	var region_pos := Vector2(col * car_frame_size.x, row * car_frame_size.y)
	sprite_2d.region_enabled = true
	sprite_2d.region_rect = Rect2(region_pos, car_frame_size)
