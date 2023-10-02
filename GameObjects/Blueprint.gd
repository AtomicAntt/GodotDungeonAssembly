extends Area2D

onready var world = get_tree().get_nodes_in_group("main")[0]

func _on_Blueprint_area_entered(area):
	if area.is_in_group("player"):
		world.get_node("TouchBlueprint").play()
		world.enterBuildMode()
		queue_free()
