extends Node2D

@onready var player: Player = $Player
@onready var soil: TileMapLayer = $Map/Soil
@onready var tile_highlight: Node2D = $TileHighlight
@onready var plant_scene: PackedScene = preload("res://scenes/plant/plant.tscn")
@onready var pumpkin_label: Label = $HUD/MarginContainer2/HBoxContainer/PumpkinLabel

var tilelist = {}
var pumpkin_count = 0

func _ready() -> void:
	tile_highlight.tile_selected.connect(_on_tile_selected)
	_update_pumpkin_label()

func _on_tile_selected(tile):
	var pos_player = soil.local_to_map(player.global_position)
	if max(abs(tile.x - pos_player.x), abs(tile.y - pos_player.y)) < 3:
		var actual_tile = tilelist.get(tile, null)
		## Não existe esse tile na lista
		if actual_tile == null:
			tilelist[tile] = {
				"dirt": true,
				"plant": null
			}
			soil.set_cell(tile, 3, Vector2i(3,3))
		
		## Existe na lista e não tem planta
		## Adicionar a planta na terra pronta para o plantio
		elif !actual_tile["plant"]:
			var plant = plant_scene.instantiate()
			add_child(plant)
			plant.global_position = soil.map_to_local(tile)
			actual_tile["plant"] = plant
		
		## Não pode adicionar mais de uma na mesma terra (tile)
		## Aponte para a planta que você criou o "plant" da lista
		## Ao clicar novamente em uma planta no ultimo estágio
		## Colha a planta (remova-a) e aumente o contador de abóboras
		elif actual_tile["plant"]:
			var plant = actual_tile["plant"]
			if plant.phase >= 4:
				plant.queue_free()
				actual_tile["plant"] = null
				pumpkin_count += 1
				_update_pumpkin_label()

func _update_pumpkin_label() -> void:
	pumpkin_label.text = "%d" % pumpkin_count
