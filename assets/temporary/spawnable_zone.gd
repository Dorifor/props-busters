extends NavigationRegion3D

@export var zone_props: Array[PackedScene]
@export var test_prop: PackedScene
@export var max_count: int = 8

func _ready() -> void:
	await get_tree().physics_frame 
	await get_tree().physics_frame
	
	var rng = RandomNumberGenerator.new()
	
	for i in range(rng.randi_range(0, max_count)):
		spawn_at_random_pos(zone_props.pick_random())


func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("right"):
		get_tree().reload_current_scene()


func spawn_at_random_pos(prop: PackedScene):	
	var prop_instance = prop.instantiate() as StaticBody3D
	add_child(prop_instance)
	
	prop_instance.global_position = get_random_pos()
	while await is_prop_colliding(prop_instance):
		prop_instance.global_position = get_random_pos()


func get_random_zone_prop():
	return zone_props.pick_random()


func get_random_pos() -> Vector3:
	return NavigationServer3D.region_get_random_point(get_rid(), 1, false)


func is_prop_colliding(prop_instance: StaticBody3D) -> bool:
	var prop_collision: CollisionShape3D = prop_instance.get_node("Collision")
	
	var overlap_query := PhysicsShapeQueryParameters3D.new()
	overlap_query.collide_with_bodies = true
	overlap_query.transform = prop_instance.global_transform
	overlap_query.shape = prop_collision.shape
	overlap_query.collision_mask = 0b10100
	overlap_query.exclude = [prop_instance.get_rid()]
	overlap_query.margin = .2
	
	await get_tree().physics_frame 
	var overlaps = get_world_3d().direct_space_state.intersect_shape(overlap_query)
	return overlaps.size() > 0
