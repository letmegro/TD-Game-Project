extends PathFollow2D
"""
" Oluwasesan Adeleke & Nicolas Korsunski 
" updated as of 2022-04-11
" 
" Enemy movement logic and dealth logic
"""

#enemy movement speed
var speed = 100

#signals to connect instances with main scripts
signal lose_a_life
signal fly_cash_gained
#adapt based on enemy type or hardcode logic per enemy if unable to create an adaptable code (easily)
var hp = GameVariables.AI_Dict_Var_Keys["fly"]["health"]

#plays fly animation
func _process(delta):
	$KinematicBody2D/AnimationPlayer.play("fly")

#damages enemy and reduces health
func on_hit(damage):
	hp -= damage
	if hp <= 0:
		#destroys instance and emits signal to give player cash
		on_destroy()
		emit_signal("fly_cash_gained")
		
	

#frees instance to delete it from scene
func on_destroy():
	self.queue_free()

#processes movement speed
func _physics_process(delta):
	var distance = speed * delta
	move(distance)


func move(distance):
	#sets movement path
	set_offset(get_offset() + distance)
	#emits loss of life so players life is reduced when reached end
	if loop == false and get_unit_offset() == 1:
		queue_free()
		emit_signal("lose_a_life")
