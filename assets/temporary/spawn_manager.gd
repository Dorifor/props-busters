extends Node3D

@export var waiting_panel: Panel
@export var spawnable_zones: Array[SpawnableZone]

var zones_count: int

func _ready() -> void:
	zones_count = len(spawnable_zones)

func zone_finished_spawning():
	zones_count -= 1
	if zones_count <= 0:
		waiting_panel.hide()
