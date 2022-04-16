extends Node2D

"""
" Nicolas Korsunski & Oluwasesan Adeleke
" 2022-04-15
"
" The script below is for the game mechanics the placement, time, and enemy spawn logic
" this script is the second level and connects all the scripts creates instances and
" controls all the nodes please refer to the comments to better understand
" how each part works and what is what
" currect issues is when there are a LOT of turrent instances the game might start to 
" lag at some points (not game breaking) but should be looked at (noticed on: 2022-04-13)
"""

#pre loads all the possible enemy instances
onready var spider = preload("res://Enemies/spider/spider.tscn")
onready var fly = preload("res://Enemies/fly/fly.tscn")
onready var worm = preload("res://Enemies/worm/worm.tscn")
onready var deathworm = preload("res://Enemies/death worm/deathworm.tscn")
onready var wasp = preload("res://Enemies/wasp/wasp.tscn")

#player health
var lives = GameVariables.Player_Dict_Var_Keys.lifes
#wave counter and 10 waves is the initial introduction waves before the infinite 
#wave which goes on forever
var waves = 10
var wave_count = 0
#map node in order to have a variable access to updating map when a new tower is placed or deleted
var map_node
#tower placement variables
var waitTime = 1
#all the variables below are used to maintain instances of turrets and create them
#verify the build placement to make sure it is valid
var can_place_tower = false
#if user selects turret
var place_mode = false
#position
var build_location
#the turret type
var build_type
#tower tile 
var tower_platform_tile
#if valid build placement
var build_valid = false
#if the tile is valid for building
var invalid_tiles
#the two below are for saving where the turrets were saved so they can be deleted easily
var tower_tiles = []
var tower_tile_positions = []

#these variables are to reestablish the bugs original health upon death
var spider_health = GameVariables.AI_Dict_Var_Keys["spider"]["health"]
var fly_health    = GameVariables.AI_Dict_Var_Keys["fly"]["health"]
var worm_health   = GameVariables.AI_Dict_Var_Keys["worm"]["health"]
var deathworm_health = GameVariables.AI_Dict_Var_Keys["deathworm"]["health"]
var wasp_health   = GameVariables.AI_Dict_Var_Keys["wasp"]["health"]
#player cash
var user_cash = GameVariables.Player_Dict_Var_Keys["start_money"]

# Called when the node enters the scene tree for the first time.
func _ready():
	#audio check and turn on onready
	if GameVariables.music:
		$"AudioStreamPlayer2D".play()
	#initial auto start timer
	$bug_spawn_timer2.start(30)
	#set player lives
	$level2_control/lives.text = "Lives: " + str(lives)
	#sets the variable of which tiles are valid tiles
	invalid_tiles = $nav2/nav2_tilemap.get_used_cells()
	#main node for over all map control within script
	map_node = get_node(".")
	#connects all the turrets to a build method for build control
	for i in get_tree().get_nodes_in_group("build_buttons"):
		i.connect("pressed", self, "initiate_build_mode", [i.get_name()])
	#add the default starting cash
	updated_player_cash(user_cash)
	

#if tower is placed in a valid position the map will auto update all the time but only
#if user is in build mode
func _process(delta):
	if place_mode:
		update_tower_preview()
	#always updates timer if wave is done until next wave starts
	$level2_control/next_wave_time.text = str(int($bug_spawn_timer2.time_left))

#this whole method is to check if player tries to delete a tower
func _input(event):
	if event.is_action_released("ui_cancel") and place_mode == false:
		if tower_tiles.size() > 0:
			for i in tower_tiles:
				if event.position.x >= i.position.x and event.position.x <= i.position.x+65:
					if event.position.y >= i.position.y and event.position.y <= i.position.y+65:
						map_node.get_node("nav2/nav2_tilemap").set_cellv(tower_tile_positions[tower_tiles.find(i)], -1)
						map_node.get_node("level2").set_cellv(tower_tile_positions[tower_tiles.find(i)], -1)
						print(tower_tile_positions)
						#return enough cash so that no matter what they user will always have enough to buy at least 1 tower
						user_cash += 125
						updated_player_cash(user_cash)
						tower_tile_positions.remove(tower_tiles.find(i))
						tower_tiles.erase(i)
						i.free()
						
						
					
				
			
		
	

#checks for input on placement of a tower to auto update red or green for valid 
#and invalid placement positions
func _unhandled_input(event):
	if event is InputEventMouseMotion and can_place_tower:
		$tower_placement.clear()
		
		var tile = $tower_placement.world_to_map(event.position)
		
		if tile in invalid_tiles:
			$tower_placement.set_cell(tile.x, tile.y, 0)
		else:
			$tower_placement.set_cell(tile.x, tile.y, 1)
		
	#to cancel or confirm placement of tower
	if event.is_action_released("ui_cancel") and place_mode == true:
		cancel_placement_mode()
	if event.is_action_released("ui_accept") and place_mode == true:
		verify_and_build()
		cancel_placement_mode()
	

#if user clicks on a tower it initiates the build mode to allow player to build a tower
func initiate_build_mode(tower_type):
	if place_mode:
		cancel_placement_mode()
	build_type = tower_type  #rank for possible upgrading functionality
	place_mode = true
	get_node("UI").set_tower_preview(build_type, get_global_mouse_position())
	

#previews and updates the colour of the tower based on positions (actual logic)
func update_tower_preview():
	var mouse_position = get_global_mouse_position()
	var current_tile = map_node.get_node("tower_placement").world_to_map(mouse_position)
	var tile_position = map_node.get_node("tower_placement").map_to_world(current_tile)
	
	if map_node.get_node("nav2/nav2_tilemap").get_cellv(current_tile) == -1:
		get_node("UI").update_tower_preview(tile_position, "ad54ff3c")
		build_valid = true
		build_location = tile_position
		tower_platform_tile = current_tile
	else:
		get_node("UI").update_tower_preview(tile_position, "adff4545")
		build_valid = false
	

#method to cancel build mode
func cancel_placement_mode():
	place_mode = false
	build_valid = false
	_on_TextureButton_pressed()
	get_node("UI/TowerPreview").free()
	

#if player clicks left mouse buttons this method will verify and place new instance
func verify_and_build():
	#cost of the tower selected
	var cost = GameVariables.Tower_Dict_Var_Keys[build_type]["cost"]
	#checks to make sure user has a valid placement and enough cash to build
	if build_valid and (cost <= user_cash):
		var new_tower =  load("res://Towers/" + build_type + ".tscn").instance()
		#adds all necessary tower information
		new_tower.position = build_location
		new_tower.built = true
		new_tower.type = build_type
		new_tower.by_level_fix = 0
		new_tower.shotType = GameVariables.Tower_Dict_Var_Keys[build_type]["ShotType"]
		#adds tower type to map
		map_node.get_node("Towers").add_child(new_tower, true)
		map_node.get_node("nav2/nav2_tilemap").set_cellv(tower_platform_tile, 32)
		map_node.get_node("level2").set_cellv(tower_platform_tile, 32)
		tower_tiles.append(new_tower)
		tower_tile_positions.append(tower_platform_tile)
		#if sound is on the game will play the placement sound
		if GameVariables.sound:
			$PlacementSound.play()
			yield(get_tree().create_timer(0.35), "timeout")
			$PlacementSound.stop()
		##once checked cash deduct here
		user_cash -= cost
		updated_player_cash(user_cash)
		##update cash
		
	

#increments the wave number
func _on_bug_spawn_timer2_timeout():
	wave_count += 1
	$level2_control/wave_count.text = str(wave_count)
	
	#this is a switch/match statement which introduces the initial 10 waves
	#and runs costume and infinite style of waves
	match wave_count:
		1:
			$bug_spawn_timer2.stop()
			wave1_spawning_logic()
			
		2:
			$bug_spawn_timer2.stop()
			wave2_spawning_logic()
		3:
			$bug_spawn_timer2.stop()
			wave3_spawning_logic()
		4:
			$bug_spawn_timer2.stop()
			wave4_spawning_logic()
		5:
			$bug_spawn_timer2.stop()
			wave5_spawning_logic()
		6:
			$bug_spawn_timer2.stop()
			wave6_spawning_logic()
		7:
			$bug_spawn_timer2.stop()
			wave7_spawning_logic()
		8:
			$bug_spawn_timer2.stop()
			wave8_spawning_logic()
		9:
			$bug_spawn_timer2.stop()
			wave9_spawning_logic()
		10:
			$bug_spawn_timer2.stop()
			wave10_spawning_logic()
		_:
			$bug_spawn_timer2.stop()
			infinite_spawninglogic()
		
	

#updates the cash display label
func updated_player_cash(amount):
	$level2_control/user_cash.text = "$" + String(amount)
	

#updates the score display label
func update_user_score(amount):
	$level2_control/score.text = String(amount)
	

#points variable for adding player score
var points = 0

#all the methods below are called upon signal made from the enemy instances
func spider_cash_gained():
	#adds cash based on enemy signal type
	user_cash += GameVariables.AI_Dict_Var_Keys["spider"]["worth"]
	updated_player_cash(user_cash)
	#score is updated upon enemy worth * the wave survived
	points += GameVariables.AI_Dict_Var_Keys["spider"]["worth"]*wave_count
	update_user_score(points)
	

func deathworm_cash_gained():
	user_cash += GameVariables.AI_Dict_Var_Keys["deathworm"]["worth"]
	updated_player_cash(user_cash)
	points += GameVariables.AI_Dict_Var_Keys["deathworm"]["worth"]*wave_count
	update_user_score(points)
	

func fly_cash_gained():
	user_cash += GameVariables.AI_Dict_Var_Keys["fly"]["worth"]
	updated_player_cash(user_cash)
	points += GameVariables.AI_Dict_Var_Keys["fly"]["worth"]*wave_count
	update_user_score(points)
	

func worm_cash_gained():
	user_cash += GameVariables.AI_Dict_Var_Keys["worm"]["worth"]
	updated_player_cash(user_cash)
	points += GameVariables.AI_Dict_Var_Keys["worm"]["worth"]*wave_count
	update_user_score(points)
	

func wasp_cash_gained():
	user_cash += GameVariables.AI_Dict_Var_Keys["wasp"]["worth"]
	updated_player_cash(user_cash)
	points += GameVariables.AI_Dict_Var_Keys["wasp"]["worth"]*wave_count
	update_user_score(points)
	

#all the create methods below are similar and create the instance of enemy
#based on the wave type and also have two different path types they may go on
#this is the regular
func create_spider():
	var spider_instance = null
	spider_instance = spider.instance()
	spider_instance.connect("lose_a_life", self, "lose_a_life")
	spider_instance.connect("spider_cash_gained", self, "spider_cash_gained")
	map_node.get_node("spider_movement2").add_child(spider_instance, true)
	

#this is the circle path that goes around the circle for one round around
func create_circus_spider():
	var spider_instance = null
	spider_instance = spider.instance()
	spider_instance.connect("lose_a_life", self, "lose_a_life")
	spider_instance.connect("spider_cash_gained", self, "spider_cash_gained")
	map_node.get_node("circus").add_child(spider_instance, true)

func create_fly():
	var fly_instance = null
	fly_instance = fly.instance()
	fly_instance.connect("lose_a_life", self, "lose_a_life")
	fly_instance.connect("fly_cash_gained", self, "fly_cash_gained")
	map_node.get_node("fly_movement").add_child(fly_instance, true)
	

func create_circus_fly():
	var fly_instance = null
	fly_instance = fly.instance()
	fly_instance.connect("lose_a_life", self, "lose_a_life")
	fly_instance.connect("fly_cash_gained", self, "fly_cash_gained")
	map_node.get_node("circus").add_child(fly_instance, true)


func create_worm():
	var worm_instance = null
	worm_instance = worm.instance()
	worm_instance.connect("lose_a_life", self, "lose_a_life")
	worm_instance.connect("worm_cash_gained", self, "worm_cash_gained")
	map_node.get_node("spider_movement2").add_child(worm_instance, true)
	

func create_circus_worm():
	var worm_instance = null
	worm_instance = worm.instance()
	worm_instance.connect("lose_a_life", self, "lose_a_life")
	worm_instance.connect("worm_cash_gained", self, "worm_cash_gained")
	map_node.get_node("circus").add_child(worm_instance, true)


func create_deathworm():
	var deathworm_instance = null
	deathworm_instance = deathworm.instance()
	deathworm_instance.connect("lose_a_life", self, "lose_a_life")
	deathworm_instance.connect("deathworm_cash_gained", self, "deathworm_cash_gained")
	map_node.get_node("death_worm_movement").add_child(deathworm_instance, true)
	

func create_circus_deathworm():
	var deathworm_instance = null
	deathworm_instance = deathworm.instance()
	deathworm_instance.connect("lose_a_life", self, "lose_a_life")
	deathworm_instance.connect("deathworm_cash_gained", self, "deathworm_cash_gained")
	map_node.get_node("circus").add_child(deathworm_instance, true)


func create_wasp():
	var wasp_instance = null
	wasp_instance = wasp.instance()
	wasp_instance.connect("lose_a_life", self, "lose_a_life")
	wasp_instance.connect("wasp_cash_gained", self, "wasp_cash_gained")
	map_node.get_node("wasp_movement").add_child(wasp_instance, true)

func create_circus_wasp():
	var wasp_instance = null
	wasp_instance = wasp.instance()
	wasp_instance.connect("lose_a_life", self, "lose_a_life")
	wasp_instance.connect("wasp_cash_gained", self, "wasp_cash_gained")
	map_node.get_node("circus").add_child(wasp_instance, true)

#below are all the methods which are very similar so I will once again 
#explain for only one because it is the same for all the rest just some small
#variable differences
func wave1_spawning_logic():
	#disables button to start new wave to not start another round, prevents round laping
	$level2_control/start_next_wave.disabled = true
	
	#first batch of enemies
	for bug_Count in 15:
		create_circus_spider()
		yield(get_tree().create_timer(1), "timeout")
		
	#after enemies are done spawning restart timer
	$bug_spawn_timer2.start(30)
	#reanable the button
	$level2_control/start_next_wave.disabled = false


func wave2_spawning_logic():
	
	$level2_control/start_next_wave.disabled = true
	
	#first batch
	for spider_Count in 6:
		create_spider()
		yield(get_tree().create_timer(0.5), "timeout")
		create_circus_spider()
		yield(get_tree().create_timer(0.5), "timeout")
	
	#wait time
	yield(get_tree().create_timer(1.5), "timeout")

#second batch
	for fly_Count in 4:
		create_fly()
		yield(get_tree().create_timer(0.4), "timeout")
		create_circus_fly()
		yield(get_tree().create_timer(0.4), "timeout")
	
	
	
	$bug_spawn_timer2.start(30)
	$level2_control/start_next_wave.disabled = false


func wave3_spawning_logic():
	
	$level2_control/start_next_wave.disabled = true
	
	#first batch
	for fly_Count in 4:
		create_fly()
		yield(get_tree().create_timer(0.5), "timeout")

	
	yield(get_tree().create_timer(0.5), "timeout")
	
	#second batch
	for bug_count in 3:
		create_spider()
		yield(get_tree().create_timer(0.5), "timeout")
		create_fly()
		yield(get_tree().create_timer(0.5), "timeout")
		create_circus_fly()
		yield(get_tree().create_timer(0.25), "timeout")
		
	
	yield(get_tree().create_timer(2), "timeout")
	create_fly()
	
	$bug_spawn_timer2.start(30)
	$level2_control/start_next_wave.disabled = false


func wave4_spawning_logic():
	
	$level2_control/start_next_wave.disabled = true
	
	#first batch of fourth wave
	create_spider()
	yield(get_tree().create_timer(0.45), "timeout")
	create_fly()
	yield(get_tree().create_timer(0.5), "timeout")
	create_fly()
	yield(get_tree().create_timer(0.5), "timeout")
	for spider_Count in 3:
		create_spider()
		yield(get_tree().create_timer(0.75), "timeout")
	
	
	yield(get_tree().create_timer(3), "timeout")
	
	#second batch
	for fly_Count in 8:
		create_fly()
		yield(get_tree().create_timer(0.25), "timeout")
		create_circus_fly()
		yield(get_tree().create_timer(0.25), "timeout")
		
	
	$bug_spawn_timer2.start(30)
	$level2_control/start_next_wave.disabled = false


func wave5_spawning_logic():
	
	$level2_control/start_next_wave.disabled = true
	
	for spider_Count in 10:
		create_spider()
		yield(get_tree().create_timer(0.25), "timeout")
		
	for bug_count in 5:
		create_fly()
		yield(get_tree().create_timer(0.35), "timeout")
		create_spider()
		yield(get_tree().create_timer(0.2), "timeout")
		
	for fly_count in 5:
		create_fly()
		yield(get_tree().create_timer(0.35), "timeout")
		create_spider()
		yield(get_tree().create_timer(0.35), "timeout")
		
	yield(get_tree().create_timer(2), "timeout")
	
	for worm_count in 10:
		create_worm()
		yield(get_tree().create_timer(1), "timeout")
		create_deathworm()
		yield(get_tree().create_timer(1), "timeout")
		
		
	$bug_spawn_timer2.start(25)
	$level2_control/start_next_wave.disabled = false

func wave6_spawning_logic():
	$level2_control/start_next_wave.disabled = true
	
	for fly_count in 8:
		create_fly()
		yield(get_tree().create_timer(1), "timeout")
		
	for bug_count in 10:
		create_worm()
		yield(get_tree().create_timer(0.2), "timeout")
		create_spider()
		yield(get_tree().create_timer(0.2), "timeout")
	
	
	for bug_count in 10:
		create_fly()
		yield(get_tree().create_timer(0.1), "timeout")
		create_spider()
		yield(get_tree().create_timer(0.1), "timeout")
		create_worm()
		yield(get_tree().create_timer(0.1), "timeout")
		
		
	$bug_spawn_timer2.start(25)
	$level2_control/start_next_wave.disabled = false

func wave7_spawning_logic():
	
	$level2_control/start_next_wave.disabled = true
	
	
	for deathworm_count in 10:
		create_deathworm()
		yield(get_tree().create_timer(0.8), "timeout")
		
	for spider_count in 15:
		create_spider()
		yield(get_tree().create_timer(0.3), "timeout")
		
	yield(get_tree().create_timer(3), "timeout")
	
	for fly_count in 20:
		create_fly()
		yield(get_tree().create_timer(0.6), "timeout")
		create_circus_spider()
		yield(get_tree().create_timer(0.6), "timeout")
		
	yield(get_tree().create_timer(3), "timeout")
	
	for bug_count in 15:
		create_worm()
		yield(get_tree().create_timer(0.4), "timeout")
		create_deathworm()
		yield(get_tree().create_timer(0.2), "timeout")
		create_circus_deathworm()
		yield(get_tree().create_timer(0.6), "timeout")
		
	
	
	$bug_spawn_timer2.start(25)
	$level2_control/start_next_wave.disabled = false

func wave8_spawning_logic():
	
	$level2_control/start_next_wave.disabled = true
	
	for bug_count in 5:
		create_fly()
		yield(get_tree().create_timer(0.5), "timeout")
		
	yield(get_tree().create_timer(2), "timeout")
	
	for spider_count in 8:
		create_spider()
		yield(get_tree().create_timer(0.2), "timeout")
	
	yield(get_tree().create_timer(3), "timeout")
	
	for bug_count in 10:
		create_worm()
		yield(get_tree().create_timer(0.3), "timeout")
		create_circus_deathworm()
		yield(get_tree().create_timer(0.3), "timeout")
		create_fly()
		yield(get_tree().create_timer(0.2), "timeout")
	
	yield(get_tree().create_timer(3), "timeout")
	create_spider()
	
	
	$bug_spawn_timer2.start(20)
	$level2_control/start_next_wave.disabled = false

func wave9_spawning_logic():
	
	$level2_control/start_next_wave.disabled = true
	
	for wasp_count in 5:
		create_wasp()
		yield(get_tree().create_timer(0.3), "timeout")
		
		
	yield(get_tree().create_timer(1), "timeout")
	
	for fly_count in 8:
		create_fly()
		yield(get_tree().create_timer(0.3), "timeout")
		
	yield(get_tree().create_timer(1.25), "timeout")
	
	for bug_count in 5:
		create_circus_deathworm()
		yield(get_tree().create_timer(0.25), "timeout")
		create_spider()
		yield(get_tree().create_timer(0.25), "timeout")
		create_worm()
		yield(get_tree().create_timer(0.25), "timeout")
	
	yield(get_tree().create_timer(1), "timeout")
	
	for bug_count in 8:
		create_wasp()
		yield(get_tree().create_timer(0.25), "timeout")
		create_spider()
		yield(get_tree().create_timer(0.25), "timeout")
		create_fly()
		yield(get_tree().create_timer(0.25), "timeout")
	
	yield(get_tree().create_timer(3), "timeout")
	
	for bug_count in 3:
		create_worm()
		yield(get_tree().create_timer(0.5), "timeout")
		create_deathworm()
		yield(get_tree().create_timer(0.5), "timeout")
		create_fly()
		yield(get_tree().create_timer(0.5), "timeout")
	
		yield(get_tree().create_timer(2), "timeout")
		
	for bug_count in 9:
		create_circus_wasp()
		yield(get_tree().create_timer(0.5), "timeout")
		create_deathworm()
		yield(get_tree().create_timer(0.2), "timeout")
		create_fly()
		yield(get_tree().create_timer(0.2), "timeout")
		
		
	
	$bug_spawn_timer2.start(15)
	$level2_control/start_next_wave.disabled = false


func wave10_spawning_logic():
	$level2_control/start_next_wave.disabled = true
	
	for bug_count in 15:
		create_spider()
		yield(get_tree().create_timer(0.1), "timeout")
		create_fly()
		yield(get_tree().create_timer(0.3), "timeout")
		create_spider()
		yield(get_tree().create_timer(0.1), "timeout")
		create_wasp()
		yield(get_tree().create_timer(0.4), "timeout")
		create_circus_wasp()
		yield(get_tree().create_timer(0.2), "timeout")
		create_fly()
		yield(get_tree().create_timer(0.3), "timeout")
		create_circus_fly()
		yield(get_tree().create_timer(0.2), "timeout")
	
	yield(get_tree().create_timer(1), "timeout")
	
	for bug_count in 15:
		create_deathworm()
		yield(get_tree().create_timer(0.2), "timeout")
		create_worm()
		yield(get_tree().create_timer(0.15), "timeout")
		create_deathworm()
		yield(get_tree().create_timer(0.1), "timeout")
		create_circus_deathworm()
		yield(get_tree().create_timer(0.1), "timeout")
	
	yield(get_tree().create_timer(7), "timeout")
	
	for bug_count in 10:
		create_wasp()
		yield(get_tree().create_timer(0.1), "timeout")
		create_fly()
		yield(get_tree().create_timer(0.2), "timeout")
		create_circus_deathworm()
		yield(get_tree().create_timer(0.1), "timeout")
		create_worm()
		yield(get_tree().create_timer(0.3), "timeout")
	
	
	for bug_count in 15:
		create_spider()
		yield(get_tree().create_timer(0.1), "timeout")
		create_fly()
		yield(get_tree().create_timer(0.1), "timeout")
		create_circus_spider()
		yield(get_tree().create_timer(0.1), "timeout")
		create_worm()
		yield(get_tree().create_timer(0.1), "timeout")
		create_deathworm()
		yield(get_tree().create_timer(0.3), "timeout")
		create_circus_wasp()
		yield(get_tree().create_timer(0.2), "timeout")
		create_fly()
		yield(get_tree().create_timer(0.2), "timeout")
		create_circus_worm()
		yield(get_tree().create_timer(0.2), "timeout")
		create_circus_fly()
		yield(get_tree().create_timer(0.3), "timeout")
	
	$bug_spawn_timer2.start(20)
	$level2_control/start_next_wave.disabled = false

#the infinite waves logic starts with 30 instance types of each enemy 
var infinite_count = 30

func infinite_spawninglogic():
	$level2_control/start_next_wave.disabled = true
	
	for bug_count in infinite_count:
		create_spider()
		yield(get_tree().create_timer(0.1), "timeout")
		create_wasp()
		yield(get_tree().create_timer(0.1), "timeout")
		create_fly()
		yield(get_tree().create_timer(0.1), "timeout")
		create_circus_fly()
		yield(get_tree().create_timer(0.1), "timeout")
		create_worm()
		yield(get_tree().create_timer(0.1), "timeout")
		create_deathworm()
		yield(get_tree().create_timer(0.1), "timeout")
		create_circus_spider()
		yield(get_tree().create_timer(0.1), "timeout")
		create_fly()
		yield(get_tree().create_timer(0.1), "timeout")
		create_wasp()
		yield(get_tree().create_timer(0.1), "timeout")
		create_circus_wasp()
		yield(get_tree().create_timer(0.1), "timeout")
		create_worm()
		yield(get_tree().create_timer(0.1), "timeout")
		create_spider()
		yield(get_tree().create_timer(0.1), "timeout")
		create_circus_deathworm()
		yield(get_tree().create_timer(0.1), "timeout")
		create_fly()
		yield(get_tree().create_timer(0.1), "timeout")
		create_deathworm()
		yield(get_tree().create_timer(0.1), "timeout")
	#increase amount of enemies by 1 until user loses
	#max amount of instances of each enemy is 50 to try to reduce lag risk should work with 
	#at least 50
	if infinite_count != 50:
		infinite_count += 1
		
	#makes bugs have more health with each increased rounds until player loses
	if wave_count == 11:
		GameVariables.AI_Dict_Var_Keys["spider"]["health"] += 1
	elif wave_count == 12:
		GameVariables.AI_Dict_Var_Keys["fly"]["health"] += 1
	elif wave_count == 13:
		GameVariables.AI_Dict_Var_Keys["worm"]["health"] += 1
	elif wave_count == 14:
		GameVariables.AI_Dict_Var_Keys["deathworm"]["health"] += 1
	elif wave_count == 11:
		GameVariables.AI_Dict_Var_Keys["wasp"]["health"] += 1
	else:
		GameVariables.AI_Dict_Var_Keys["wasp"]["health"] += 1
		GameVariables.AI_Dict_Var_Keys["deathworm"]["health"] += 1
		GameVariables.AI_Dict_Var_Keys["worm"]["health"] += 1
		GameVariables.AI_Dict_Var_Keys["fly"]["health"] += 1
		GameVariables.AI_Dict_Var_Keys["spider"]["health"] += 1
	$bug_spawn_timer2.start(15)
	$level2_control/start_next_wave.disabled = false

#when enemy reaches the end and the signal is emited this is the method that is called
func lose_a_life():
	#life reduced here
	lives -= 1
	#update lifes display
	$level2_control/lives.text = "Lives: " + str(lives)
	#if amount of player lifes reaches 0 then save the score
	#update player high score
	if lives <= 0:
		GameVariables.AI_Dict_Var_Keys["spider"]["health"] = spider_health
		GameVariables.AI_Dict_Var_Keys["fly"]["health"]    = fly_health
		GameVariables.AI_Dict_Var_Keys["worm"]["health"]   = worm_health
		GameVariables.AI_Dict_Var_Keys["deathworm"]["health"] = deathworm_health
		GameVariables.AI_Dict_Var_Keys["wasp"]["health"]   = wasp_health
		GameVariables.player_score = int($level2_control/score.text)
		if (GameVariables.player_high_score < GameVariables.player_score):
			GameVariables.player_high_score = int(GameVariables.player_score)
			
		#and launch the end of game scene
		get_tree().change_scene("res://player score scene/player_score_display.tscn")
		
	

#all the methods below are for connecting the buttons
func _on_start_next_wave_pressed():
	_on_bug_spawn_timer2_timeout()

#this is for the first gun type the rest are self explanitory 
func _on_TextureButton_pressed():
	$tower_placement.clear()
	can_place_tower = !can_place_tower

func _on_Gun2_pressed():
	$tower_placement.clear()
	can_place_tower = !can_place_tower

func _on_Gun3_pressed():
	$tower_placement.clear()
	can_place_tower = !can_place_tower
	
