extends PathFollow2D
"""
" Oluwasesan Adeleke & Nicolas Korsunski 
" updated as of 2022-04-11
" 
" Enemy movement logic and dealth logic
"""

#enemy speed
var speed = 100
#enemy health
var hp = GameVariables.AI_Dict_Var_Keys["spider"]["health"]

#signals to connect instances with main script
signal lose_a_life
signal spider_cash_gained

#plays animation for instance
func _process(delta):
	$spider/AnimationPlayer.play("spider")

#enemy movement speed setting method
func _physics_process(delta):
	var distance = speed * delta
	move(distance)


func move(distance):
	#enemy path set
	set_offset(get_offset() + distance)
	
	if loop == false and get_unit_offset() == 1:
		queue_free()
		#signal whicch controls player health lose
		emit_signal("lose_a_life")
	

#reduces enemy health on hit by turret
func on_hit(damage):
	hp -= damage
	if hp <= 0:
		on_destroy()
		#destroys enemy instance if health is reached 0 or below
		emit_signal("spider_cash_gained")
		
	

#removes instance
func on_destroy():
	self.queue_free()

