extends Node2D

@onready var player: Player = $Player
@onready var soil: TileMapLayer = $Map/Soil
@onready var tile_highlight: Node2D = $TileHighlight

func _ready() -> void:
	tile_highlight.tile_selected.connect(_on_tile_selected)

func _on_tile_selected(tile):
	var pos_player = soil.local_to_map(player.global_position)
	if max(abs(tile.x - pos_player.x), abs(tile.y - pos_player.y)) < 3:
		soil.set_cell(tile, 0, Vector2i(16,12))
