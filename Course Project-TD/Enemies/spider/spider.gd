extends KinematicBody2D


var velocity = Vector2()

func _physics_process(delta):
	var collision = move_and_collide(velocity * delta)
	if collision:
		self.queue_free()
		GameVariables.tempCounter -= 1
	
