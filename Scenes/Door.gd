extends Area2D

var canbeOpened = true
signal finishedClosing

func _on_Door_area_entered(area):
	if area.is_in_group("player") and canbeOpened:
		Global.canPass = true
		$Label.visible = true

func _on_Door_area_exited(area):
	if area.is_in_group("player") and canbeOpened:
		Global.canPass = false
		$Label.visible = false

func openDoor():
	canbeOpened = false
	$AnimatedSprite.play("Open")
	yield($AnimatedSprite, "animation_finished")
	closeDoor()

func closeDoor():
	$AnimatedSprite.play("Close")
	yield($AnimatedSprite, "animation_finished")
	emit_signal("finishedClosing")
	
