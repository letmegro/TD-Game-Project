extends KinematicBody2D
"""
" Oluwasesan Adeleke & Nicolas Korsunski 
" updated as of 2022-03-28
" 
" Enemy movement logic and dealth logic
"""

var speed = 100
var path : = PoolVector2Array() setget set_path
var destination = Vector2()

signal lose_a_life
#adapt based on enemy type or hardcode logic per enemy if unable to create an adaptable code (easily)
var hp = GameVariables.AI_Dict_Var_Keys["spider"]["health"]

func _ready():
	pass
	

func on_hit(damage):
	hp -= damage
	if hp <= 0:
		on_destroy()
		
	

func on_destroy():
	self.queue_free()

func _process(delta):
	get_node("AnimationPlayer").play("spider")

func _physics_process(delta):
	
	if path.size() > 0:
		
		var distance = speed * delta
		move_along_path(distance)
	elif abs(position.x - destination.x) < 10 and abs(position.y - destination.y) < 10:
		
		queue_free()
		emit_signal("lose_a_life")

func move_along_path(distance):
	var start_pos = position
	
	for i in range(path.size()):
		
		var distance_to_next = start_pos.distance_to(path[0])
		if distance <= distance_to_next and distance > 0:
			position = start_pos.linear_interpolate(path[0], distance / distance_to_next)
			break
		elif distance <= 0:
			position = path[0]
			break
			
		distance -= distance_to_next
		start_pos = path[0]
		path.remove(0)
	
func set_path(new_path):
	
	path = new_path
