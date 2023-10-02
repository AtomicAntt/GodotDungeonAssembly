extends StaticBody2D

onready var main = get_tree().get_nodes_in_group("main")[0]
var playerBased = false
var hover = false

func _on_Platform1_mouse_entered():
	if main.buildMode and playerBased:
		$Label.visible = true
		hover = true

func _on_Platform1_mouse_exited():
	if main.buildMode and playerBased:
		$Label.visible = false
		hover = false

func _input(event):
	if event.is_action_pressed("rightclick") and hover:
		main.get_node("Sell").play()
		main.currentBalance += 50
		main.updateBalance(main.currentBalance)
		queue_free()

func sell():
	main.get_node("Sell").play()
	main.currentBalance += 50
	main.updateBalance(main.currentBalance)
	queue_free()


