"""
"Nicolas Korsunski
"updated as of 2022-03-28
"
"every tower will inherit this script.
"the follwoing script is a general tower logic script currently rotating based on mouse position
"updated to-do: add enemy tracking and shooting
"""
extends Node2D
var type
var enemy_tracking_array = []
var built = false
var enemy
var ready = true
var shotType

func _ready():
	if built:
		self.get_node("Range/CollisionShape2D").get_shape().radius = 0.5 * GameVariables.Tower_Dict_Var_Keys[type]["range"]
		
	

func _physics_process(delta):
	if enemy_tracking_array.size() > 1 and built:
		enemy_selection()
		turn()
		if ready:
			fire()
	else:
		enemy = null
	

func turn():
		get_node("Turret").look_at(enemy.position)
	

func fire():
	ready = false
	if shotType == "Projectile":
		fire_gun()
	elif shotType == "IceShot":
		fire_Ice_Gun()
	elif shotType == "cannon":
		cannon_fire()
	enemy.on_hit(GameVariables.Tower_Dict_Var_Keys[type]["power"])
	yield(get_tree().create_timer(GameVariables.Tower_Dict_Var_Keys[type]["rof"]), "timeout")
	ready = true
	

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
		
	

func enemy_selection():
	var enemy_array = []
	for i in enemy_tracking_array:
		enemy_array.append(i.position)
	var max_offset = enemy_array.max()
	var enemy_index = enemy_array.find(max_offset)
	enemy = enemy_tracking_array[enemy_index]
	

func _on_Range_body_entered(body):
	enemy_tracking_array.append(body)
	


func _on_Range_body_exited(body):
	enemy_tracking_array.erase(body)
