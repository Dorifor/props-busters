extends Node3D

@export var speed = 10
@export var raycast: RayCast3D


func _process(delta):
	position += transform.basis * Vector3(0, 0, -speed) * delta


func _physics_process(_delta):
	if raycast.is_colliding():
		var collider = raycast.get_collider()
		if collider is Hider:
			collider._on_bullet_colliding()
		queue_free()


func _on_lifetime_timer_timeout() -> void:
	queue_free()
