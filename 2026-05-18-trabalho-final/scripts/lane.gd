extends Node2D

signal player_hit
signal coin_collected(coin_type: int)

const LANE_GRASS := 0
const LANE_ROAD := 1
const LANE_WATER := 2
const WATER_LILY_DURATION := 2.0
const COIN_BUFF := 0
const COIN_DEBUFF := 1
const COIN_SPAWN_CHANCE := 0.10

@onready var grass_sprite: Sprite2D = $GrassSprite
@onready var road_sprite: Sprite2D = $RoadSprite
@onready var water_sprite: Sprite2D = $WaterSprite
@onready var water_lily_area: Area2D = $WaterLilyArea
@onready var water_lily_sprite: Sprite2D = $WaterLilyArea/WaterLilySprite
@onready var water_lily_collision: CollisionShape2D = $WaterLilyArea/CollisionShape2D
@onready var water_lily_timer: Timer = $WaterLilyTimer

@export var grass_texture: Texture2D
@export var road_texture: Texture2D
@export var water_texture: Texture2D
@export var water_lily_texture: Texture2D
@export var grass_tile_region: Rect2
@export var road_tile_region: Rect2
@export var water_tile_region: Rect2

var lane_type := LANE_GRASS
var row_index := 0
var lane_height := 64.0
var lane_width := 900.0
var _player: CharacterBody2D
var _rng := RandomNumberGenerator.new()
var _tile_texture_cache: Dictionary = {}
var _grass_tile_region_cache := Rect2()
var _road_tile_region_cache := Rect2()
var _water_tile_region_cache := Rect2()
var _vehicle_scene := preload("res://scenes/Vehicle.tscn")
var _coin_scene := preload("res://scenes/Coin.tscn")
var _spawn_timer := 0.0
var _spawn_interval := Vector2(0.8, 1.6)
var _direction := 1
var _water_lily_x := 0.0
var _water_lily_collapsed := false
var _death_emitted := false
var _water_lily_bump_played := false
var _coin_spawned := false

func setup(type: int, row: int, height: float, width: float, rng: RandomNumberGenerator, player: CharacterBody2D) -> void:
	lane_type = type
	row_index = row
	lane_height = height
	lane_width = width
	_rng = rng
	_player = player
	_direction = 1 if _rng.randf() < 0.5 else -1
	position = Vector2(0, -row_index * lane_height)
	_spawn_timer = _rng.randf_range(_spawn_interval.x, _spawn_interval.y)
	_water_lily_x = _rng.randf_range(-lane_width * 0.32, lane_width * 0.32)
	_water_lily_collapsed = false
	_death_emitted = false
	_water_lily_bump_played = false
	_coin_spawned = false
	if is_inside_tree():
		_apply_lane_configuration()
	else:
		call_deferred("_apply_lane_configuration")
	queue_redraw()

func _ready() -> void:
	_grass_tile_region_cache = _resolve_tile_region(grass_tile_region, grass_sprite)
	_road_tile_region_cache = _resolve_tile_region(road_tile_region, road_sprite)
	_water_tile_region_cache = _resolve_tile_region(water_tile_region, water_sprite)
	water_lily_timer.wait_time = WATER_LILY_DURATION
	water_lily_timer.one_shot = true
	water_lily_timer.timeout.connect(_on_water_lily_timer_timeout)
	_apply_lane_configuration()

func _process(delta: float) -> void:
	if lane_type == LANE_ROAD:
		_spawn_timer -= delta * Vehicle.warmup_multiplier
		if _spawn_timer <= 0.0:
			_spawn_vehicle()
			_spawn_timer = _rng.randf_range(_spawn_interval.x, _spawn_interval.y)
		return

	if lane_type == LANE_WATER:
		_update_water_lane_state()

func _spawn_vehicle() -> void:
	var vehicle: Area2D = _vehicle_scene.instantiate()
	var height := lane_height * 0.55
	var length := height * 1.8
	var speed := _rng.randf_range(120.0, 220.0)
	vehicle.call("configure", _direction, speed, length, height, lane_width)
	var spawn_x := -lane_width * 0.5 - length * 0.6 if _direction > 0 else lane_width * 0.5 + length * 0.6
	vehicle.position = Vector2(spawn_x, 0)
	vehicle.connect("player_hit", _on_vehicle_player_hit)
	add_child(vehicle)

func _on_vehicle_player_hit() -> void:
	emit_signal("player_hit")

func _apply_lane_configuration() -> void:
	_update_sprites()
	_update_water_lily()
	_try_spawn_coin()

func _try_spawn_coin() -> void:
	if lane_type != LANE_GRASS:
		return
	if _coin_spawned:
		return
	if row_index == 0:
		return
	_coin_spawned = true
	
	var roll := _rng.randf()
	var coin_type := -1
	if roll < COIN_SPAWN_CHANCE:
		coin_type = COIN_BUFF
	elif roll < COIN_SPAWN_CHANCE * 2.0:
		coin_type = COIN_DEBUFF
	
	if coin_type < 0:
		return
	
	var coin: Area2D = _coin_scene.instantiate()
	coin.call("setup", coin_type)
	var coin_x := _rng.randf_range(-lane_width * 0.35, lane_width * 0.35)
	coin.position = Vector2(coin_x, 0)
	coin.connect("collected", _on_coin_collected)
	add_child(coin)

func _on_coin_collected(type: int) -> void:
	emit_signal("coin_collected", type)

func _update_sprites() -> void:
	var size := Vector2(lane_width, lane_height)
	var grass_tex := grass_texture if grass_texture != null else grass_sprite.texture
	var road_tex := road_texture if road_texture != null else road_sprite.texture
	var water_tex := water_texture if water_texture != null else water_sprite.texture
	var grass_region := _resolve_tile_region(grass_tile_region, grass_sprite, _grass_tile_region_cache)
	var road_region := _resolve_tile_region(road_tile_region, road_sprite, _road_tile_region_cache)
	var water_region := _resolve_tile_region(water_tile_region, water_sprite, _water_tile_region_cache)
	_update_sprite(grass_sprite, grass_tex, size, grass_region)
	_update_sprite(road_sprite, road_tex, size, road_region)
	_update_sprite(water_sprite, water_tex, size, water_region)

	grass_sprite.visible = lane_type == LANE_GRASS and grass_tex != null
	road_sprite.visible = lane_type == LANE_ROAD and road_tex != null
	water_sprite.visible = lane_type == LANE_WATER and water_tex != null

func _update_water_lily() -> void:
	if water_lily_area == null or water_lily_sprite == null or water_lily_collision == null or water_lily_timer == null:
		return

	if lane_type != LANE_WATER:
		water_lily_timer.stop()
		water_lily_area.monitoring = false
		water_lily_collision.disabled = true
		water_lily_sprite.visible = false
		return

	water_lily_area.position = Vector2(_water_lily_x, 0)
	water_lily_area.monitoring = true
	water_lily_collision.disabled = false
	water_lily_sprite.texture = water_lily_texture if water_lily_texture != null else water_lily_sprite.texture
	water_lily_sprite.visible = true

func _update_water_lane_state() -> void:
	if _player == null or water_lily_area == null or water_lily_timer == null:
		return
	if _death_emitted:
		return

	var on_lily := water_lily_area.overlaps_body(_player)
	var player_moving := bool(_player.call("is_moving"))

	if on_lily:
		if not player_moving and _water_lily_collapsed:
			emit_signal("player_hit")
			_death_emitted = true
		elif not player_moving and water_lily_timer.is_stopped():
			water_lily_timer.start(WATER_LILY_DURATION)
		if not player_moving and not _water_lily_bump_played:
			_water_lily_bump_played = true
			_play_water_lily_bump()
	else:
		if not water_lily_timer.is_stopped():
			water_lily_timer.stop()
		_water_lily_bump_played = false

	if not player_moving and _current_player_row() == row_index and not on_lily:
		_death_emitted = true
		emit_signal("player_hit")

func _current_player_row() -> int:
	if _player == null:
		return -9999
	return int(round(-_player.global_position.y / lane_height))

func _on_water_lily_timer_timeout() -> void:
	if _player == null or water_lily_area == null:
		return
	_water_lily_collapsed = true
	water_lily_area.monitoring = false
	water_lily_collision.disabled = true
	water_lily_sprite.visible = false
	if _current_player_row() == row_index:
		_death_emitted = true
		emit_signal("player_hit")

func _play_water_lily_bump() -> void:
	if water_lily_sprite == null:
		return
	var tween := create_tween()
	tween.tween_property(water_lily_sprite, "scale", Vector2(0.3, 0.3), 0.08).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(water_lily_sprite, "scale", Vector2(0.3, 0.25), 0.12).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)

func _update_sprite(sprite: Sprite2D, texture: Texture2D, size: Vector2, tile_region: Rect2) -> void:
	if sprite == null:
		return
	if texture == null:
		return
	var tile_texture := _get_tile_texture(sprite, texture, tile_region)
	if tile_texture == null:
		return
	var tex_size := tile_texture.get_size()
	if tex_size.x <= 0.0 or tex_size.y <= 0.0:
		return
	sprite.texture = tile_texture
	sprite.position = Vector2.ZERO
	sprite.rotation = 0.0
	sprite.flip_h = false
	sprite.flip_v = false
	sprite.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	sprite.region_enabled = true
	sprite.region_rect = Rect2(Vector2.ZERO, size)
	sprite.scale = Vector2.ONE

func _get_tile_texture(_sprite: Sprite2D, texture: Texture2D, tile_region: Rect2) -> Texture2D:
	var region := tile_region

	if texture is AtlasTexture:
		var atlas := texture as AtlasTexture
		if atlas.atlas == null:
			return atlas
		var image := atlas.atlas.get_image()
		if image == null or image.is_empty():
			return atlas
		if region.size.x <= 0.0 or region.size.y <= 0.0:
			region = atlas.region
		if region.size.x <= 0.0 or region.size.y <= 0.0:
			return atlas.atlas
		var cache_key := str(atlas.atlas.get_rid()) + ":" + str(region)
		if _tile_texture_cache.has(cache_key):
			return _tile_texture_cache[cache_key]
		var sub_image := image.get_region(region)
		if sub_image.is_empty():
			return atlas.atlas
		var img_tex := ImageTexture.create_from_image(sub_image)
		_tile_texture_cache[cache_key] = img_tex
		return img_tex

	if region.size.x > 0.0 and region.size.y > 0.0:
		var base_image := texture.get_image()
		if base_image != null and not base_image.is_empty():
			var key := str(texture.get_rid()) + ":" + str(region)
			if _tile_texture_cache.has(key):
				return _tile_texture_cache[key]
			var sub := base_image.get_region(region)
			if not sub.is_empty():
				var sub_tex := ImageTexture.create_from_image(sub)
				_tile_texture_cache[key] = sub_tex
				return sub_tex

	return texture

func _resolve_tile_region(override: Rect2, sprite: Sprite2D, cached: Rect2 = Rect2()) -> Rect2:
	if override.size.x > 0.0 and override.size.y > 0.0:
		return override
	if cached.size.x > 0.0 and cached.size.y > 0.0:
		return cached
	if sprite != null and sprite.region_enabled and sprite.region_rect.size.x > 0.0 and sprite.region_rect.size.y > 0.0:
		return sprite.region_rect
	return Rect2()

func get_water_lily_time_left() -> float:
	if lane_type != LANE_WATER:
		return -1.0
	if water_lily_timer == null:
		return -1.0
	if _water_lily_collapsed:
		return 0.0
	if water_lily_timer.is_stopped():
		return -1.0
	return water_lily_timer.time_left

func _draw() -> void:
	return
