"""
"Nicolas Korsunski
"updated as of 2022-03-28
"
"every tower will inherit this script.
"the follwoing script is a general tower logic script currently rotating based on mouse position
"updated to-do: add upgrade possibility 
"""
extends Node2D
#tower variables for shooting and enemy tracking
var type
var enemy_tracking_array = []
var built = false
var enemy
var ready = true
var shotType

#on ready (in build mode) this sets the radius of the tower tracking radius asset
#as scene when a tower is selected pre placement
func _ready():
	if built:
		self.get_node("Range/CollisionShape2D").get_shape().radius = 0.5 * GameVariables.Tower_Dict_Var_Keys[type]["range"]
		
	

"""
this variable below is a quick fix because this is a fix to a bug which
only happens on level 1. what happens is that the
the tower is added to the enemy array and tries to shoot itself (our understanding)
and does not contain a on_hit method (probably for the better since it tries 
to shoot itself)
so this will determine if it is a level 1 or 2 and work based off that
"""
var by_level_fix = 0

func _physics_process(delta):
	#if an enemy is within radius
	if enemy_tracking_array.size() > by_level_fix and built:
		#an enemy will be selected
		enemy_selection()
		#tower turned towards enemy
		turn()
		if ready:
			#fire on enemy 
			fire()
	else:
		#if enemy is not within radius enemy is null as it does not exist
		enemy = null
	

func turn():
	#turns towards enemy within radius
	get_node("Turret").look_at(enemy.position)
	

func fire():
	#to prevent mutiple shooting one shot per reload
	ready = false
	if shotType == "Projectile":
		#to play shooting animation for each type of gun
		fire_gun()
	elif shotType == "IceShot":
		fire_Ice_Gun()
	elif shotType == "cannon":
		cannon_fire()
	#on hit method which will reduce enemy health and kill if health is 0 or below
	enemy.on_hit(GameVariables.Tower_Dict_Var_Keys[type]["power"])
	yield(get_tree().create_timer(GameVariables.Tower_Dict_Var_Keys[type]["rof"]), "timeout")
	#after a reload timer wait the tower is set to ready to shoot again
	#tower will still turn but not shoot
	ready = true
	

#the three methods below just play the animation and sound if sound option is true
func fire_gun():
	get_node("AnimationPlayer").play("fire")
	if GameVariables.sound:
		get_node("machinegun").play()
		yield(get_tree().create_timer(0.18), "timeout")
		get_node("machinegun").stop()
		
	

func cannon_fire():
	get_node("AnimationPlayer").play("fire2")
	if GameVariables.sound:
		get_node("cannonfire").play()
		yield(get_tree().create_timer(6.75), "timeout")
		get_node("cannonfire").stop()
		
	

func fire_Ice_Gun():
	get_node("AnimationPlayer").play("fire3")
	if GameVariables.sound:
		get_node("icegun").play()
		yield(get_tree().create_timer(2.85), "timeout")
		get_node("icegun").stop()
		
	

#method for selecting enemy, the tower will always look at first enemy that entered 
#its radius
func enemy_selection():
	var enemy_array = []
	for i in enemy_tracking_array:
		enemy_array.append(i.position)
	var max_offset = enemy_array.max()
	var enemy_index = enemy_array.find(max_offset)
	enemy = enemy_tracking_array[enemy_index]
	

#adds enemy to array when entered tower radius
func _on_Range_body_entered(body):
	enemy_tracking_array.append(body.get_parent())
	

#removes when enemy is destroyed or leaves body
func _on_Range_body_exited(body):
	enemy_tracking_array.erase(body.get_parent())
