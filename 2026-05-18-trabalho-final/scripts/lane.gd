extends Node2D

signal player_hit

const LANE_GRASS := 0
const LANE_ROAD := 1

@onready var grass_sprite: Sprite2D = $GrassSprite
@onready var road_sprite: Sprite2D = $RoadSprite

@export var grass_texture: Texture2D
@export var road_texture: Texture2D
@export var grass_tile_region: Rect2
@export var road_tile_region: Rect2

var lane_type := LANE_GRASS
var row_index := 0
var lane_height := 64.0
var lane_width := 900.0
var _rng := RandomNumberGenerator.new()
var _tile_texture_cache: Dictionary = {}
var _grass_tile_region_cache := Rect2()
var _road_tile_region_cache := Rect2()

var _vehicle_scene := preload("res://scenes/Vehicle.tscn")
var _spawn_timer := 0.0
var _spawn_interval := Vector2(0.8, 1.6)
var _direction := 1

func setup(type: int, row: int, height: float, width: float, rng: RandomNumberGenerator) -> void:
	lane_type = type
	row_index = row
	lane_height = height
	lane_width = width
	_rng = rng
	_direction = 1 if _rng.randf() < 0.5 else -1
	position = Vector2(0, -row_index * lane_height)
	_spawn_timer = _rng.randf_range(_spawn_interval.x, _spawn_interval.y)
	if is_inside_tree():
		_update_sprites()
	else:
		call_deferred("_update_sprites")
	queue_redraw()

func _ready() -> void:
	_grass_tile_region_cache = _resolve_tile_region(grass_tile_region, grass_sprite)
	_road_tile_region_cache = _resolve_tile_region(road_tile_region, road_sprite)

func _process(delta: float) -> void:
	if lane_type != LANE_ROAD:
		return
	_spawn_timer -= delta
	if _spawn_timer <= 0.0:
		_spawn_vehicle()
		_spawn_timer = _rng.randf_range(_spawn_interval.x, _spawn_interval.y)

func _spawn_vehicle() -> void:
	var vehicle := _vehicle_scene.instantiate()
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

func _update_sprites() -> void:
	var size := Vector2(lane_width, lane_height)
	var grass_tex := grass_texture if grass_texture != null else grass_sprite.texture
	var road_tex := road_texture if road_texture != null else road_sprite.texture
	var grass_region := _resolve_tile_region(grass_tile_region, grass_sprite, _grass_tile_region_cache)
	var road_region := _resolve_tile_region(road_tile_region, road_sprite, _road_tile_region_cache)
	_update_sprite(grass_sprite, grass_tex, size, grass_region)
	_update_sprite(road_sprite, road_tex, size, road_region)

	grass_sprite.visible = lane_type == LANE_GRASS and grass_tex != null
	road_sprite.visible = lane_type == LANE_ROAD and road_tex != null


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

func _draw() -> void:
	return
