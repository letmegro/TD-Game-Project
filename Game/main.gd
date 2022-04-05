extends Node2D

"""
" Nicolas Korsunski & Oluwasesan Adeleke
" 2022-03-19
"
" The script below is for the game mechanics the placement, time, and enemy spawn logic
" additionally as of 2022-03-19 this is course project prototype 1 (Medium Fidelity)
" add new enemies and update the enemy difficulty so it gets harder with each running round
"""

onready var spider = preload("res://Enemies/spider/spider.tscn")
var bugs_remaining = 0
var lives = GameVariables.Player_Dict_Var_Keys.lifes
var waves = 10
var wave_count = 0
#map node in order to have a variable access to updating map when a new tower is placed or deleted
var map_node

#presentation iterative example vars
var enemy_count = 10
var spawn_rate = 1.0
var points = 0
#tower placement variables
var can_place_tower = false
var place_mode = false
var build_location
var build_type
var tower_platform_tile
var build_valid = false
var invalid_tiles
var tower_tiles = []
var tower_tile_positions = []

func _ready():
	#audio check and turn on onready
	if GameVariables.music:
		$"AudioStreamPlayer2D".play()
	$bug_spawn_timer.start(30)
	#bugs remaining starts off at 10
	bugs_remaining = enemy_count
	$user_interface/lives.text = "Lives: " + str(lives)
	$Impact.visible = false
	invalid_tiles = $nav/nav_TileMap.get_used_cells()
	
	map_node = get_node(".")
	
	for i in get_tree().get_nodes_in_group("build_buttons"):
		i.connect("pressed", self, "initiate_build_mode", [i.get_name()])
	

func _process(delta):
	
	if place_mode:
		update_tower_preview()
	$user_interface/next_wave_time.text = str(int($bug_spawn_timer.time_left))
	

func _input(event):
	if event.is_action_released("ui_cancel") and place_mode == false:
		if tower_tiles.size() > 0:
			for i in tower_tiles:
				#bug when tower placed and esc is pressed twice
				if event.position.x >= i.position.x and event.position.x <= i.position.x+65:
					if event.position.y >= i.position.y and event.position.y <= i.position.y+65:
						map_node.get_node("nav/nav_TileMap").set_cellv(tower_tile_positions[tower_tiles.find(i)], -1)
						map_node.get_node("Level").set_cellv(tower_tile_positions[tower_tiles.find(i)], -1)
						print(tower_tile_positions)
						
						tower_tile_positions.remove(tower_tiles.find(i))
						tower_tiles.erase(i)
						i.free()
						
						
					
				
			
		
	

func _unhandled_input(event):
	if event is InputEventMouseMotion and can_place_tower:
		$tower_placement.clear()
		
		var tile = $tower_placement.world_to_map(event.position)
		
		if tile in invalid_tiles:
			
			$tower_placement.set_cell(tile.x, tile.y, 0)
		else:
			$tower_placement.set_cell(tile.x, tile.y, 1)
		
	
	if event.is_action_released("ui_cancel") and place_mode == true:
		cancel_placement_mode()
	if event.is_action_released("ui_accept") and place_mode == true:
		verify_and_build()
		cancel_placement_mode()
	

func initiate_build_mode(tower_type):
	if place_mode:
		cancel_placement_mode()
	build_type = tower_type  #rank for possible upgrading functionality
	place_mode = true
	get_node("UI").set_tower_preview(build_type, get_global_mouse_position())
	

func update_tower_preview():
	var mouse_position = get_global_mouse_position()
	var current_tile = map_node.get_node("tower_placement").world_to_map(mouse_position)
	var tile_position = map_node.get_node("tower_placement").map_to_world(current_tile)
	
	if map_node.get_node("nav/nav_TileMap").get_cellv(current_tile) == -1:
		get_node("UI").update_tower_preview(tile_position, "ad54ff3c")
		build_valid = true
		build_location = tile_position
		tower_platform_tile = current_tile
	else:
		get_node("UI").update_tower_preview(tile_position, "adff4545")
		build_valid = false
	

func cancel_placement_mode():
	place_mode = false
	build_valid = false
	_on_TextureButton_pressed()
	get_node("UI/TowerPreview").free()
	

func verify_and_build():
	if build_valid:
		#add money and verify here is the player has enough cash
		var new_tower =  load("res://Towers/" + build_type + ".tscn").instance()
		new_tower.position = build_location
		new_tower.built = true
		new_tower.type = build_type
		new_tower.shotType = GameVariables.Tower_Dict_Var_Keys[build_type]["ShotType"]
		map_node.get_node("Towers").add_child(new_tower, true)
		map_node.get_node("nav/nav_TileMap").set_cellv(tower_platform_tile, 32)
		map_node.get_node("Level").set_cellv(tower_platform_tile, 32)
		tower_tiles.append(new_tower)
		tower_tile_positions.append(tower_platform_tile)
		if GameVariables.sound:
			$PlacementSound.play()
			yield(get_tree().create_timer(0.35), "timeout")
			$PlacementSound.stop()
		##once checked cash deduct here
		##update cash
		
	

func _on_bug_spawn_timer_timeout():
	var bug_instance = null
	bug_instance = spider.instance()
	bug_instance.connect("lose_a_life", self, "lose_a_life")
	
	
	
	bug_instance.position = $start_position.position
	bug_instance.destination = $end_position.position
	
	var path = $nav.get_simple_path($start_position.position, $end_position.position)
	bug_instance.set_path(path)
	
	
	$enemies.add_child(bug_instance)
	
	
	$user_interface/start_next_wave.disabled = true
	
	
	
	bugs_remaining -= 1
	if bugs_remaining > 0:
		#timer that determines spawn rate turn into a variable for difficulty
		$bug_spawn_timer.start(spawn_rate) 
	else:
		#points formula
		points += (100*(wave_count*(enemy_count))) - (100*(250-lives))
		$user_interface/points.text =  String(points)
		#when bugs are done spawning for the round reset the wait timer to 60 for auto start 
		$bug_spawn_timer.start(60)
		#reset bug counter, make into a variable for iterative difficulty
		if enemy_count <= 45:
			#highest number of enemies is 50
			enemy_count += 5
		if spawn_rate >= 0.3:
			#lowest rate is 0.2
			spawn_rate -=0.2
		bugs_remaining = enemy_count
		if wave_count == 5:
			#add a congrats to the player
			get_node("Impact/winner").play("winner")
			$Impact.visible = true
		$user_interface/start_next_wave.disabled = false
		begin_next_wave()
		
	

func lose_a_life():
	lives -= 1
	$user_interface/lives.text = "Lives: " + str(lives)


func begin_next_wave():
	wave_count += 1
	$user_interface/wave_count.text = str(wave_count)


func _on_start_next_wave_pressed():
	_on_bug_spawn_timer_timeout()
	#begin_next_wave()

func _on_TextureButton_pressed():
	$tower_placement.clear()
	can_place_tower = !can_place_tower

func _on_Gun2_pressed():
	$tower_placement.clear()
	can_place_tower = !can_place_tower

func _on_Gun3_pressed():
	$tower_placement.clear()
	can_place_tower = !can_place_tower
