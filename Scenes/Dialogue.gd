extends Label

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


func show():
	$AnimationPlayer.playback_speed = 60.0 / self.text.length()
	$AnimationPlayer.play("Show Dialogue")

