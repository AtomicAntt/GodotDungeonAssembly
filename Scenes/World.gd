extends Node2D

onready var spikes = preload("res://GameObjects/Spikes.tscn")

func _ready():
	for cellpos in $Obstacles.get_used_cells():
		var cell = $Obstacles.get_cellv(cellpos)
		if cell == 0:
			var spikesInstance = spikes.instance()
			spikesInstance.position = $Obstacles.map_to_world(cellpos) * $Obstacles.scale
			spikesInstance.position += Vector2(8,13)
			add_child(spikesInstance)
			$Obstacles.set_cellv(cellpos, -1)
