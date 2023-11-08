extends RayCast3D

@export var excluded_colliders: Array[CollisionObject3D]

func _ready() -> void:
	for collider in excluded_colliders:
		add_exception(collider)
