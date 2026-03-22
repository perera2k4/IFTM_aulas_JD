extends Node2D

signal fruit_collected

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

@export var types_fruit: Array[SpriteFrames]
@export var points : int = 1

func _ready() -> void:
	var choice = types_fruit.pick_random()
	animated_sprite_2d.sprite_frames = choice
	animated_sprite_2d.play("default")
	
	# Destroi a fruta que estiver na lista de global_iterates pois ja foi coletada
	if str(get_path()) in GlobalIterates.collected_fruits:
		queue_free()

func _on_area_2d_area_entered(area: Area2D) -> void:
	# Adiciona o caminho das frutas coletadas na lista de global_iterates
	GlobalIterates.collected_fruits.append(str(get_path()))
	fruit_collected.emit()
	queue_free()
