extends PathFollow2D
"""
" Oluwasesan Adeleke & Nicolas Korsunski 
" updated as of 2022-04-11
" 
" Enemy movement logic and dealth logic
"""

#enemy speed
var speed = 100

#signals to connect main script with enemy instance
signal lose_a_life
signal worm_cash_gained
#adapt based on enemy type or hardcode logic per enemy if unable to create an adaptable code (easily)
var hp = GameVariables.AI_Dict_Var_Keys["worm"]["health"]

#plays animation
func _process(delta):
	$KinematicBody2D/AnimationPlayer.play("worm")

#on hit method to damage enemy and destroy if health is reached 0 or below
func on_hit(damage):
	hp -= damage
	if hp <= 0:
		on_destroy()
		#emits signal to reward player with cash
		emit_signal("worm_cash_gained")
		
	

#destroys enemy instance
func on_destroy():
	self.queue_free()

func _physics_process(delta):
	#method incharge of speed
	var distance = speed * delta
	move(distance)


func move(distance):
	#method incharge of setting the path
	set_offset(get_offset() + distance)
	
	#when reached the end the players health will be reduced unless enemy is destoryed first
	if loop == false and get_unit_offset() == 1:
		queue_free()
		emit_signal("lose_a_life")
	
