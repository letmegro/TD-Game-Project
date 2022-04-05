extends KinematicBody2D

var speed = 1300
var velocity = Vector2()

func start(pos, dir):
	rotation = dir
	position = pos
	velocity = Vector2(speed, 0).rotated(rotation-125)

func _physics_process(delta):
	var collision = move_and_collide(velocity * delta)
	if collision:
		yield(get_tree().create_timer(0.04), "timeout")
		self.free()
		
	

func _on_VisibilityNotifier2D_screen_exited():
	queue_free()
