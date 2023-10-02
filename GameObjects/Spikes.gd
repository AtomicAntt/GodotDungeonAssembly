extends Area2D



func _on_Spikes_area_entered(area):
	if area.is_in_group("player"):
		var player = area.get_owner()
		if player.dead == false:
			player.die()
