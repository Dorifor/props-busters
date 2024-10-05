extends Node
class_name GameManager

@export var NBRPROP = 0
@export var NBRHUNTER = 0

@export var hunters: Array[Hunter] = []
@export var hiders: Array[Hider] = []

@rpc("authority")
func remove_hider(hider_id: int):
	for hider in hiders:
		if hider.get_instance_id() == hider_id:
			hiders.erase(hider)
			print("Hider removed by host. Remaining Hiders: %d" % hiders.size())
			break

	if hiders.size() == 0:
		print("All Hiders have been eliminated!")
		# Appeler la logique de victoire si nécessaire
