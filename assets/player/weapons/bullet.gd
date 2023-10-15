extends Node3D

const SPEED = 20
	
func _process(delta):
	position += transform.basis * Vector3(0, 0, -SPEED) * delta


func _on_body_entered(body):
	if body is Hider:
		body._on_bullet_colliding()
	queue_free()
