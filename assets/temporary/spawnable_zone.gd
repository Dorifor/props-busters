extends NavigationRegion3D

@export var zone_props: Array[PackedScene]
@export var test_prop: PackedScene

var map: RID

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#for i in range(navigation_mesh.get_polygon_count()):
		#print(navigation_mesh.get_polygon(i))
		#var pol = navigation_mesh.get_polygon(i)
		#var prop = test_prop.instantiate()
		#add_child(prop)
		#prop.position = Vector3(pol[0], pol[1], pol[2])
		
	map = NavigationServer3D.map_create()
	NavigationServer3D.region_set_map(get_rid(), map)
	
	for i in range(len(zone_props)):
		spawn_at_random_pos(zone_props[i])
	

func spawn_at_random_pos(prop: PackedScene):
	NavigationServer3D.map_force_update(map)
	var pos = NavigationServer3D.map_get_random_point(map, 1, false)
	
	var prop_instance = prop.instantiate() as StaticBody3D
	add_child(prop_instance)
	#pos.y = 2
	#print(pos)
	
	prop_instance.global_position = pos

func get_random_zone_prop():
	return zone_props.pick_random()

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("right"):
		get_tree().reload_current_scene()
