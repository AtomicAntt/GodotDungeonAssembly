extends Node2D

var buildMode = true
var moved = false
var hover = false
onready var main = get_tree().get_nodes_in_group("main")[0]

func buildMode():
	$Platform1/CollisionShape2D.disabled = true

func exitBuildMode():
	$Platform1/CollisionShape2D.disabled = false
	buildMode = false


func _on_Area2D_area_entered(area):
	if area.is_in_group("player") and not buildMode:
		movePlatform()

func movePlatform():
	if not moved:
		moved = true
		var tween = create_tween().set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN)
		tween.tween_property($Platform1, "global_position", $Position2.global_position, 1)
		yield(get_tree().create_timer(1.0), "timeout")
		$After.visible = false
		$Sprite.visible = false
		$Sprite2.visible = false
		$Sprite3.visible = false

func _on_Area2D_mouse_entered():
	if main.buildMode:
		print("hello it works")
		$Label.visible = true
		hover = true

func _on_Area2D_mouse_exited():
	if main.buildMode:
		$Label.visible = false
		hover = false

func _input(event):
	if event.is_action_pressed("rightclick") and hover:
		main.get_node("Sell").play()
		main.currentBalance += 90
		main.updateBalance(main.currentBalance)
		queue_free()

func sell():
	main.get_node("Sell").play()
	main.currentBalance += 90
	main.updateBalance(main.currentBalance)
	queue_free()
