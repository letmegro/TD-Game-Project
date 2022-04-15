extends PathFollow2D
"""
" Oluwasesan Adeleke & Nicolas Korsunski 
" updated as of 2022-04-15
" 
" DeathWorm movement logic and dealth logic
"""
#speed of which the enemy moves at
#idea note: make variable speed so the enemy gets faster or each enemy has unique speed
#not hard coded but variable speed
var speed = 100

#signals which allow communication between main script and instances
signal lose_a_life
signal deathworm_cash_gained
#adapt based on enemy type or hardcode logic per enemy if unable to create an
#adaptable code (easily)
var hp = GameVariables.AI_Dict_Var_Keys["deathworm"]["health"]

#plays death worm animation
func _process(delta):
	$KinematicBody2D/AnimationPlayer.play("death_worm")

#this method is in charge of making sure that when the turret hits the enemy
#the enemy takes damage
func on_hit(damage):
	hp -= damage
	if hp <= 0:
		#when enemy's health goes below 0 or hits 0 the instance is destoryed
		on_destroy()
		#emits signal so player gains cash for destorying enemy
		emit_signal("deathworm_cash_gained")
		
	

#enemy is destroyed here by freeing the instance
func on_destroy():
	self.queue_free()

#sets the movement speed
func _physics_process(delta):
	var distance = speed * delta
	move(distance)

#sets the path
func move(distance):
	set_offset(get_offset() + distance)
	#if enemy reaches end then the lost life signal is emited and user loses a life
	if loop == false and get_unit_offset() == 1:
		queue_free()
		emit_signal("lose_a_life")
	
