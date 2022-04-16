extends Node2D

"""
" Nicolas Korsunski & Oluwasesan Adeleke
" 2022-04-12
"
" The script below is for the game mechanics the placement, time, and enemy spawn logic
" this script is for level 1 it is similar to level 2 the scripts as you will see
" share a lot of similarities. this script has been mostly fixed for a lot of
" known bugs which were found through testing but some may still exist that
" were not yet found
"""

#enemy scenes are preloaded to have scenes in memory for loading instances
onready var spider = preload("res://Enemies/spider/spider.tscn")
onready var fly = preload("res://Enemies/fly/fly.tscn")
onready var worm = preload("res://Enemies/worm/worm.tscn")
onready var deathworm = preload("res://Enemies/death worm/deathworm.tscn")
onready var wasp = preload("res://Enemies/wasp/wasp.tscn")

#player lifes
var lives = GameVariables.Player_Dict_Var_Keys.lifes
#for wave control
var waves = 10
var wave_count = 0
#map node in order to have a variable access to updating map when a new tower is placed or deleted
var map_node
#tower placement variables
var waitTime = 1
var can_place_tower = false
var place_mode = false
var build_location
var build_type
var tower_platform_tile
var build_valid = false
var invalid_tiles
var tower_tiles = []
var tower_tile_positions = []
#players cash
var user_cash = GameVariables.Player_Dict_Var_Keys["start_money"]

#for restablishing enemy health in global variables
var spider_health = GameVariables.AI_Dict_Var_Keys["spider"]["health"]
var fly_health    = GameVariables.AI_Dict_Var_Keys["fly"]["health"]
var worm_health   = GameVariables.AI_Dict_Var_Keys["worm"]["health"]
var deathworm_health = GameVariables.AI_Dict_Var_Keys["deathworm"]["health"]
var wasp_health   = GameVariables.AI_Dict_Var_Keys["wasp"]["health"]

func _ready():
	#audio check and turn on onready
	if GameVariables.music:
		$"AudioStreamPlayer2D".play()
	#starts auto wave timer
	$bug_spawn_timer.start(30)
	
	#sets player lifes
	$user_interface/lives.text = "Lives: " + str(lives)
	#sets map tiles that are invalid for tower placement (path tiles)
	invalid_tiles = $nav/nav_TileMap.get_used_cells()
	#variable instance of the main node for map control
	map_node = get_node(".")
	#updates the cash to default cash
	updated_player_cash(user_cash)
	#connects all the tower types to a group to control the build tower types in script
	for i in get_tree().get_nodes_in_group("build_buttons"):
		i.connect("pressed", self, "initiate_build_mode", [i.get_name()])
	


func _process(delta):
	#always checks for if the user decides to place a new tower
	if place_mode:
		update_tower_preview()
	#the timer updates here. the timer which updates is the wave timer incase the user doesn't
	#manually start the round the game will auto start after 30 seconds
	$user_interface/next_wave_time.text = str(int($bug_spawn_timer.time_left))
	

#the method below checks for the user cancel input and if the user is not in
#build mode and deletes the turrent instance from the game
#the method leaves the placement pad and does not convert it back (needs to be fixed)
func _input(event):
	if event.is_action_released("ui_cancel") and place_mode == false:
		if tower_tiles.size() > 0:
			for i in tower_tiles:
				#checks and ensures that the tower the mouse is over is only deleted
				if event.position.x >= i.position.x and event.position.x <= i.position.x+65:
					if event.position.y >= i.position.y and event.position.y <= i.position.y+65:
						map_node.get_node("nav/nav_TileMap").set_cellv(tower_tile_positions[tower_tiles.find(i)], -1)
						map_node.get_node("Level").set_cellv(tower_tile_positions[tower_tiles.find(i)], -1)
						#removes the tower from the map after it locates it
						tower_tile_positions.remove(tower_tiles.find(i))
						#the user will only ever get 125 back so in case they delete their towers
						#future balancing might be needed
						user_cash += 125
						updated_player_cash(user_cash)
						#removes those tile instances which are saved in the arrays from the arrays
						tower_tiles.erase(i)
						i.free()
						
						
					
				
			
		
	

#checks for user placement and updates if the position tower is hovered over
#is valid for placement or not
func _unhandled_input(event):
	if event is InputEventMouseMotion and can_place_tower:
		$tower_placement.clear()
		
		var tile = $tower_placement.world_to_map(event.position)
		
		if tile in invalid_tiles:
			
			$tower_placement.set_cell(tile.x, tile.y, 0)
		else:
			$tower_placement.set_cell(tile.x, tile.y, 1)
		
	
	#these methods check if the user tries placing tower or cancel build more
	if event.is_action_released("ui_cancel") and place_mode == true:
		cancel_placement_mode()
	if event.is_action_released("ui_accept") and place_mode == true:
		verify_and_build()
		cancel_placement_mode()
	

#initiates build mode when player selects a tower type
func initiate_build_mode(tower_type):
	#cancels build mode if user tries to place tower on invalid tile 
	#place_mode is decided true or false in another place constantly 
	if place_mode:
		cancel_placement_mode()
	build_type = tower_type  #rank for possible upgrading functionality
	place_mode = true
	#determines the colour in the UI check UI script for more details
	get_node("UI").set_tower_preview(build_type, get_global_mouse_position())
	

#helper method for determining the colour of the tower
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
	

#to cancel build mode
func cancel_placement_mode():
	place_mode = false
	build_valid = false
	_on_TextureButton_pressed()
	get_node("UI/TowerPreview").free()
	

#here the method verifies and builds the tower
func verify_and_build():
	#to compare and if enough cash build
	var cost = GameVariables.Tower_Dict_Var_Keys[build_type]["cost"]
	#check to see if build is in valid position and if player has enough cash
	if build_valid and (cost <= user_cash):
		var new_tower =  load("res://Towers/" + build_type + ".tscn").instance()
		#sets all the necessary tower information for the instance
		new_tower.position = build_location
		new_tower.built = true
		new_tower.by_level_fix = 1
		new_tower.type = build_type
		new_tower.shotType = GameVariables.Tower_Dict_Var_Keys[build_type]["ShotType"]
		#adds tower to the map
		map_node.get_node("Towers").add_child(new_tower, true)
		map_node.get_node("nav/nav_TileMap").set_cellv(tower_platform_tile, 32)
		map_node.get_node("Level").set_cellv(tower_platform_tile, 32)
		tower_tiles.append(new_tower)
		tower_tile_positions.append(tower_platform_tile)
		#plays placement sound if sound option is true
		if GameVariables.sound:
			$PlacementSound.play()
			yield(get_tree().create_timer(0.35), "timeout")
			$PlacementSound.stop()
		##once checked cash deduct here
		user_cash -= cost
		updated_player_cash(user_cash)
		##update cash
		
	

#wave timer and wave incremented here
func _on_bug_spawn_timer_timeout():
	wave_count += 1
	$user_interface/wave_count.text = str(wave_count)
	
	#match/switch statements which determine the wave spawning style and what enemies
	#based on wave value
	match wave_count:
		1:
			$bug_spawn_timer.stop()
			wave1_spawning_logic()
			
		2:
			$bug_spawn_timer.stop()
			wave2_spawning_logic()
		3:
			$bug_spawn_timer.stop()
			wave3_spawning_logic()
		4:
			$bug_spawn_timer.stop()
			wave4_spawning_logic()
		5:
			$bug_spawn_timer.stop()
			wave5_spawning_logic()
		6:
			$bug_spawn_timer.stop()
			wave6_spawning_logic()
		7:
			$bug_spawn_timer.stop()
			wave7_spawning_logic()
		8:
			$bug_spawn_timer.stop()
			wave8_spawning_logic()
		9:
			$bug_spawn_timer.stop()
			wave9_spawning_logic()
		10:
			$bug_spawn_timer.stop()
			wave10_spawning_logic()
		_:
			$bug_spawn_timer.stop()
			infinite_spawninglogic()
		
	
	

#updates user cash display label
func updated_player_cash(amount):
	$user_interface/user_cash.text = "$" + String(amount)

#updates user score display label
func update_user_score(amount):
	$user_interface/points.text = String(amount)

#points variable for keeping track of player score throughout the game
var points = 0

#all of the methods below are very similar as they are
#methods called by the enemy instance signal to add cash to user 
#upon enemy death
func spider_cash_gained():
	#adds to player cash when enemy is killed based on enemy worth
	#balancing might be needed 
	user_cash += GameVariables.AI_Dict_Var_Keys["spider"]["worth"]
	updated_player_cash(user_cash)
	#adds enemy points based on enemy worth*wave count
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
	

#here all the methods below are also very similar as they create the enemy instances and
#add them to a single path here they only follow one path
func create_spider():
	var spider_instance = null
	spider_instance = spider.instance()
	#connects all the signals with the enemy instance
	spider_instance.connect("lose_a_life", self, "lose_a_life")
	spider_instance.connect("spider_cash_gained", self, "spider_cash_gained")
	#adds enemy to the map
	map_node.get_node("spider").add_child(spider_instance, true)
	

func create_fly():
	var fly_instance = null
	fly_instance = fly.instance()
	fly_instance.connect("lose_a_life", self, "lose_a_life")
	fly_instance.connect("fly_cash_gained", self, "fly_cash_gained")
	map_node.get_node("fly").add_child(fly_instance, true)
	

func create_worm():
	var worm_instance = null
	worm_instance = worm.instance()
	worm_instance.connect("lose_a_life", self, "lose_a_life")
	worm_instance.connect("worm_cash_gained", self, "worm_cash_gained")
	map_node.get_node("spider").add_child(worm_instance, true)
	

func create_deathworm():
	var deathworm_instance = null
	deathworm_instance = deathworm.instance()
	deathworm_instance.connect("lose_a_life", self, "lose_a_life")
	deathworm_instance.connect("deathworm_cash_gained", self, "deathworm_cash_gained")
	map_node.get_node("deathworm").add_child(deathworm_instance, true)
	


func create_wasp():
	var wasp_instance = null
	wasp_instance = wasp.instance()
	wasp_instance.connect("lose_a_life", self, "lose_a_life")
	wasp_instance.connect("wasp_cash_gained", self, "wasp_cash_gained")
	map_node.get_node("fly").add_child(wasp_instance, true)

#below is the wave logic for each wave also fairly standard and
#self explanitory
func wave1_spawning_logic():
	#disables the start next wave button to prevent wave overlap
	$user_interface/start_next_wave.disabled = true
	#creates the enemies in the for loop
	#based on the quantity 
	for spider_Count in 10:
		create_spider()
		yield(get_tree().create_timer(1), "timeout")
		
	$bug_spawn_timer.start(30)
	$user_interface/start_next_wave.disabled = false


func wave2_spawning_logic():
	
	$user_interface/start_next_wave.disabled = true
	for spider_Count in 4:
		create_spider()
		yield(get_tree().create_timer(0.5), "timeout")
	
	#waits a bit between each spawn type to prevent overlap
	#and to make the round playable
	yield(get_tree().create_timer(1.5), "timeout")

	for fly_Count in 4:
		create_fly()
		yield(get_tree().create_timer(1), "timeout")
	
	$bug_spawn_timer.start(30)
	$user_interface/start_next_wave.disabled = false


func wave3_spawning_logic():
	
	$user_interface/start_next_wave.disabled = true
	
	for fly_Count in 4:
		create_fly()
		yield(get_tree().create_timer(0.5), "timeout")

	
	yield(get_tree().create_timer(0.25), "timeout")
	
	for bug_count in 3:
		create_spider()
		yield(get_tree().create_timer(0.75), "timeout")
		create_fly()
		yield(get_tree().create_timer(0.75), "timeout")
	
	create_fly()
	
	$bug_spawn_timer.start(30)
	$user_interface/start_next_wave.disabled = false


func wave4_spawning_logic():
	
	$user_interface/start_next_wave.disabled = true
	
	#first batch of fourth wave
	create_spider()
	yield(get_tree().create_timer(0.75), "timeout")
	create_fly()
	yield(get_tree().create_timer(0.75), "timeout")
	create_fly()
	yield(get_tree().create_timer(0.75), "timeout")
	for spider_Count in 3:
		create_spider()
		yield(get_tree().create_timer(0.75), "timeout")
	
	
	yield(get_tree().create_timer(3), "timeout")
	for fly_Count in 5:
		create_fly()
		yield(get_tree().create_timer(0.45), "timeout")
		
	
	$bug_spawn_timer.start(30)
	$user_interface/start_next_wave.disabled = false


func wave5_spawning_logic():
	
	$user_interface/start_next_wave.disabled = true
	
	for spider_Count in 10:
		create_spider()
		yield(get_tree().create_timer(0.25), "timeout")
		
	for bug_count in 5:
		create_fly()
		yield(get_tree().create_timer(0.35), "timeout")
		create_spider()
		yield(get_tree().create_timer(0.5), "timeout")
		
	for fly_count in 5:
		create_fly()
		yield(get_tree().create_timer(0.75), "timeout")
		create_spider()
		yield(get_tree().create_timer(0.75), "timeout")
		
	yield(get_tree().create_timer(5), "timeout")
	
	for worm_count in 10:
		create_worm()
		yield(get_tree().create_timer(1), "timeout")
		
		
	$bug_spawn_timer.start(25)
	$user_interface/start_next_wave.disabled = false

func wave6_spawning_logic():
	
	$user_interface/start_next_wave.disabled = true
	
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
		yield(get_tree().create_timer(0.2), "timeout")
		create_spider()
		yield(get_tree().create_timer(0.2), "timeout")
		create_worm()
		yield(get_tree().create_timer(0.2), "timeout")
		
		
	$bug_spawn_timer.start(25)
	$user_interface/start_next_wave.disabled = false


func wave7_spawning_logic():
	
	$user_interface/start_next_wave.disabled = true
	
	
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
		
	yield(get_tree().create_timer(3), "timeout")
	
	for bug_count in 10:
		create_worm()
		yield(get_tree().create_timer(0.4), "timeout")
		create_deathworm()
		yield(get_tree().create_timer(0.6), "timeout")
		
	
	
	$bug_spawn_timer.start(25)
	$user_interface/start_next_wave.disabled = false

func wave8_spawning_logic():
	
	$user_interface/start_next_wave.disabled = true
	
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
		yield(get_tree().create_timer(0.5), "timeout")
		create_deathworm()
		yield(get_tree().create_timer(0.5), "timeout")
		create_fly()
		yield(get_tree().create_timer(0.2), "timeout")
	
	yield(get_tree().create_timer(3), "timeout")
	create_spider()
	
	
	$bug_spawn_timer.start(20)
	$user_interface/start_next_wave.disabled = false


func wave9_spawning_logic():
	
	$user_interface/start_next_wave.disabled = true
	
	for wasp_count in 5:
		create_wasp()
		yield(get_tree().create_timer(0.3), "timeout")
		
		
	yield(get_tree().create_timer(1), "timeout")
	
	for fly_count in 8:
		create_fly()
		yield(get_tree().create_timer(0.3), "timeout")
		
	yield(get_tree().create_timer(1.25), "timeout")
	
	for bug_count in 5:
		create_deathworm()
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
		
	for bug_count in 6:
		create_wasp()
		yield(get_tree().create_timer(0.5), "timeout")
		create_deathworm()
		yield(get_tree().create_timer(0.2), "timeout")
		create_fly()
		yield(get_tree().create_timer(0.2), "timeout")
		
		
	
	$bug_spawn_timer.start(20)
	$user_interface/start_next_wave.disabled = false



func wave10_spawning_logic():
	
	$user_interface/start_next_wave.disabled = true
	
	
	for bug_count in 15:
		create_spider()
		yield(get_tree().create_timer(0.1), "timeout")
		create_fly()
		yield(get_tree().create_timer(0.4), "timeout")
		create_spider()
		yield(get_tree().create_timer(0.1), "timeout")
		create_wasp()
		yield(get_tree().create_timer(0.4), "timeout")
		create_fly()
		yield(get_tree().create_timer(0.3), "timeout")
	
	yield(get_tree().create_timer(1), "timeout")
	
	for bug_count in 15:
		create_deathworm()
		yield(get_tree().create_timer(0.2), "timeout")
		create_worm()
		yield(get_tree().create_timer(0.3), "timeout")
		create_deathworm()
		yield(get_tree().create_timer(0.1), "timeout")
	
	yield(get_tree().create_timer(7), "timeout")
	
	for bug_count in 10:
		create_wasp()
		yield(get_tree().create_timer(0.1), "timeout")
		create_fly()
		yield(get_tree().create_timer(0.2), "timeout")
		create_deathworm()
		yield(get_tree().create_timer(0.1), "timeout")
		create_worm()
		yield(get_tree().create_timer(0.3), "timeout")
	
	for bug_count in 9:
		create_spider()
		yield(get_tree().create_timer(0.1), "timeout")
		create_fly()
		yield(get_tree().create_timer(0.1), "timeout")
		create_spider()
		yield(get_tree().create_timer(0.1), "timeout")
		create_worm()
		yield(get_tree().create_timer(0.4), "timeout")
		create_deathworm()
		yield(get_tree().create_timer(0.4), "timeout")
		create_wasp()
		yield(get_tree().create_timer(0.2), "timeout")
		create_fly()
		yield(get_tree().create_timer(0.4), "timeout")
	
	
	$bug_spawn_timer.start(20)
	$user_interface/start_next_wave.disabled = false

#infiite round gets harder by having this variable increased each wave survived
#by 1
var infinite_count = 20
func infinite_spawninglogic():
	$user_interface/start_next_wave.disabled = true
	
	for bug_count in infinite_count:
		create_spider()
		yield(get_tree().create_timer(0.1), "timeout")
		create_wasp()
		yield(get_tree().create_timer(0.1), "timeout")
		create_fly()
		yield(get_tree().create_timer(0.1), "timeout")
		create_worm()
		yield(get_tree().create_timer(0.1), "timeout")
		create_deathworm()
		yield(get_tree().create_timer(0.1), "timeout")
		create_fly()
		yield(get_tree().create_timer(0.1), "timeout")
		create_wasp()
		yield(get_tree().create_timer(0.1), "timeout")
		create_worm()
		yield(get_tree().create_timer(0.1), "timeout")
		create_spider()
		yield(get_tree().create_timer(0.1), "timeout")
		create_fly()
		yield(get_tree().create_timer(0.1), "timeout")
		
	
	$bug_spawn_timer.start(15)
	#max increase is at 50
	if infinite_count != 50:
		infinite_count += 1
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
	$user_interface/start_next_wave.disabled = false

#signal initiated method to have a player lose a life when enemy reaches end of map
#without being destroyed
func lose_a_life():
	lives -= 1
	#updates life label
	$user_interface/lives.text = "Lives: " + str(lives)
	#here we will check if the player lifes reached 0 and then send them to 
	#a scene where the score will be displayed and send the player back to the main menu
	if lives <= 0:
		GameVariables.AI_Dict_Var_Keys["spider"]["health"] = spider_health
		GameVariables.AI_Dict_Var_Keys["fly"]["health"]    = fly_health
		GameVariables.AI_Dict_Var_Keys["worm"]["health"]   = worm_health
		GameVariables.AI_Dict_Var_Keys["deathworm"]["health"] = deathworm_health
		GameVariables.AI_Dict_Var_Keys["wasp"]["health"]   = wasp_health
		GameVariables.player_score = int($user_interface/points.text)
		if (GameVariables.player_high_score < GameVariables.player_score):
			GameVariables.player_high_score = int(GameVariables.player_score)
			
		get_tree().change_scene("res://player score scene/player_score_display.tscn")
		
	

#a quick method that is called as a wait method
func wait_time(value):
	yield(get_tree().create_timer(waitTime), "timeout")


#all the buttons are connected below self explanitory which buttons based on name
func _on_start_next_wave_pressed():
	_on_bug_spawn_timer_timeout()
	

#this one is for the first tower gun
func _on_TextureButton_pressed():
	$tower_placement.clear()
	can_place_tower = !can_place_tower

func _on_Gun2_pressed():
	$tower_placement.clear()
	can_place_tower = !can_place_tower

func _on_Gun3_pressed():
	$tower_placement.clear()
	can_place_tower = !can_place_tower
