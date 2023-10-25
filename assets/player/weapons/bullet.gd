extends Node3D

const SPEED = 10

	
func _process(delta):
	position += transform.basis * Vector3(0, 0, -SPEED) * delta
	
func _physics_process(delta):
	if $RayCast3D.is_colliding():
		var obj = $RayCast3D.get_collider()
		if obj is Hider:
			obj._on_bullet_colliding()  # Cette ligne est commentée, assurez-vous que c'est ce que vous voulez.
			queue_free()
			return
