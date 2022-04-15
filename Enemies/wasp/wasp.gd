extends PathFollow2D
"""
" Oluwasesan Adeleke & Nicolas Korsunski 
" updated as of 2022-04-11
" 
" Enemy movement logic and dealth logic
"""

#enemy speed
var speed = 100

#signal to connect instance with main script
signal lose_a_life
signal wasp_cash_gained
#adapt based on enemy type or hardcode logic per enemy if unable to create an adaptable code (easily)
var hp = GameVariables.AI_Dict_Var_Keys["wasp"]["health"]

func _process(delta):
	$KinematicBody2D/AnimationPlayer.play("wasp")
	

#enemy health reduction method
func on_hit(damage):
	hp -= damage
	if hp <= 0:
		#if health reached or below then destroy instance
		on_destroy()
		emit_signal("wasp_cash_gained")
		
	

#destroys enemy
func on_destroy():
	self.queue_free()

#movement speed method setter
func _physics_process(delta):
	var distance = speed * delta
	move(distance)


func move(distance):
	#move path setter
	set_offset(get_offset() + distance)
	
	#if reached the end without being destroyed then player health is reduced
	if loop == false and get_unit_offset() == 1:
		queue_free()
		emit_signal("lose_a_life")
	
