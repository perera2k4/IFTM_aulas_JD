extends Node2D

@onready var spawn_timer: Timer = $SpawnTimer
@export var enemy_scene: PackedScene = preload("res://scenes/enemy.tscn")
@export var first_spawn_min_distance := 250
@export var first_spawn_delay := 1
@export var initial_spawn_count := 3
@export var total_enemy_count := 10

var navigation_map: RID
var navigation_region_rid: RID
var spawned_enemies := 0
var alive_enemies := 0
var is_game_over := false
var is_victory := false

# prepara navegacao, spawns iniciais e ativa o timer
func _ready() -> void:
	navigation_map = get_world_2d().navigation_map
	var nav_region := get_node_or_null("EnemyNavigationRegion2D") as NavigationRegion2D
	if nav_region:
		navigation_region_rid = nav_region.get_rid()
		
	await _wait_for_navigation_ready()
	await get_tree().create_timer(first_spawn_delay).timeout
	for _index in range(min(initial_spawn_count, total_enemy_count)):
		_spawn_enemy()
		
	if spawned_enemies < total_enemy_count:
		spawn_timer.start()
		
# dispara novos inimigos por tempo e verifica condicao de vitoria
func _on_tick_timeout() -> void:
	if is_game_over or is_victory:
		return
		
	if spawned_enemies >= total_enemy_count:
		spawn_timer.stop()
		_check_victory_condition()
		return
		
	_spawn_enemy()
	
# inicia os inimigos e atualiza contadores de partida
func _spawn_enemy() -> void:
	if is_game_over or is_victory:
		return
		
	if enemy_scene == null:
		return
		
	if spawned_enemies >= total_enemy_count:
		return
		
	var enemy = enemy_scene.instantiate()
	enemy.global_position = _get_random_spawn_position(spawned_enemies < initial_spawn_count)
	enemy.tree_exited.connect(_on_enemy_tree_exited)
	add_child(enemy)
	spawned_enemies += 1
	alive_enemies += 1
	
	if spawned_enemies >= total_enemy_count:
		spawn_timer.stop()
		
# escolhe um ponto valido para spawn, priorizando a regiao de navegacao
func _get_random_spawn_position(first_spawn: bool = false) -> Vector2:
	var player := get_node_or_null("player") as Node2D
	var farthest_point := Vector2.ZERO
	var farthest_distance := -1.0
	
	if navigation_region_rid.is_valid():
		for _index in range(30):
			var point := NavigationServer2D.region_get_random_point(navigation_region_rid, 1, false)
			if point == Vector2.ZERO:
				continue
				
			if !NavigationServer2D.region_owns_point(navigation_region_rid, point):
				continue
				
			var distance_to_player := INF
			if player:
				distance_to_player = point.distance_to(player.global_position)
				if distance_to_player > farthest_distance:
					farthest_distance = distance_to_player
					farthest_point = point
					
			if first_spawn and player and point.distance_to(player.global_position) < first_spawn_min_distance:
				continue
				
			return point
			
		if first_spawn and farthest_distance >= 0.0:
			return farthest_point
			
	if navigation_map.is_valid():
		for _index in range(20):
			var point := NavigationServer2D.map_get_random_point(navigation_map, 1, false)
			if point == Vector2.ZERO:
				continue
				
			var distance_to_player := INF
			if player:
				distance_to_player = point.distance_to(player.global_position)
				if distance_to_player > farthest_distance:
					farthest_distance = distance_to_player
					farthest_point = point
					
			if first_spawn and player and point.distance_to(player.global_position) < first_spawn_min_distance:
				continue
				
			return point
			
		if first_spawn and farthest_distance >= 0.0:
			return farthest_point
			
	if player:
		if navigation_region_rid.is_valid():
			return NavigationServer2D.region_get_closest_point(
				navigation_region_rid,
				player.global_position + Vector2(first_spawn_min_distance, 0)
			)
			
		if navigation_map.is_valid():
			return NavigationServer2D.map_get_closest_point(
				navigation_map,
				player.global_position + Vector2(first_spawn_min_distance, 0)
			)
			
		return player.global_position + Vector2(first_spawn_min_distance, 0)
		
	return global_position
	
# aguarda a malha de navegacao estar pronta antes dos spawns.
func _wait_for_navigation_ready() -> void:
	for _index in range(20):
		if navigation_region_rid.is_valid():
			var region_map := NavigationServer2D.region_get_map(navigation_region_rid)
			if region_map.is_valid() and NavigationServer2D.map_get_regions(region_map).size() > 0:
				return
				
		if navigation_map.is_valid() and NavigationServer2D.map_get_regions(navigation_map).size() > 0:
			return
		await get_tree().physics_frame
		
# encerra a partida por derrota e para o spawn.
func trigger_game_over() -> void:
	if is_game_over or is_victory:
		return
		
	is_game_over = true
	spawn_timer.stop()
	
# informa se a partida esta encerrada
func is_game_over_state() -> bool:
	return is_game_over or is_victory
	
# informa se a vitoria foi alcancada
func is_victory_state() -> bool:
	return is_victory
	
# atualiza inimigos vivos quando um inimigo sai da cena
func _on_enemy_tree_exited() -> void:
	alive_enemies = max(0, alive_enemies - 1)
	_check_victory_condition()
	
# marca vitoria quando nao restam inimigos vivos
func _check_victory_condition() -> void:
	if is_game_over or is_victory:
		return
		
	if spawned_enemies > 0 and alive_enemies == 0:
		is_victory = true
		spawn_timer.stop()
	
