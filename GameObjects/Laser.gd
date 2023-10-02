extends Node2D

onready var endPos = $Position2D
onready var raycast = $RayCast2D
onready var laser = $Laser

func _physics_process(delta):
	if raycast.is_colliding():
		endPos.global_position = raycast.get_collision_point()
		if raycast.get_collider().is_in_group("player"):
			var player = raycast.get_collider()
			player.die()
	else:
		endPos.global_position = raycast.cast_to
	laser.region_rect.end.x = endPos.position.length() + 3
