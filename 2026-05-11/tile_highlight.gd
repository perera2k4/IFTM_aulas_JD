extends Node2D

signal tile_selected(tile_position)
@export var tilemap_layer: TileMapLayer
var tile = Vector2i(-9999, -9999)

func _process(delta: float) -> void:
	var mouse = get_local_mouse_position()
	var cell = tilemap_layer.local_to_map(mouse)
	
	if cell != tile:
		tile = cell
		## Limpa tudo que for desenhado neste nó
		queue_redraw()
		
	if Input.is_action_just_pressed("click"):
		tile_selected.emit(tile)
		
func _draw() -> void:
	#draw_rect(Rect2(0,0,200,100), "red", true)
	var cell_local_pos = tilemap_layer.map_to_local(tile)
	var tile_size = tilemap_layer.tile_set.tile_size
	
	var rect = Rect2(
		cell_local_pos - Vector2(tile_size) / 2.0,
		Vector2(tile_size)
	)
	
	draw_rect(rect, Color(0.62, 0.855, 0.0, 0.557))
