extends KinematicBody2D

var gravity = 15
var buildMode = true
var velocity = Vector2()

onready var main = get_tree().get_nodes_in_group("main")[0]
var hover = false

var timerRunning = false

func _ready():
	for raycast in $Raycasts.get_children():
		raycast.add_exception(self)

func _physics_process(delta):
	if not buildMode:
		velocity.y += gravity
#		print(velocity.length())
		velocity = move_and_slide(velocity, Vector2.UP)
		var overlappingAreas = $Area2D.get_overlapping_areas()
		
		for area in overlappingAreas:
			if area.is_in_group("player"):
				velocity.x = area.get_owner().SPEED * area.get_owner().direction
			
		velocity.x = lerp(velocity.x, 0, 0.6)

func exitBuildMode():
	$Area2D2.monitoring = true
	$Arrow.visible = false
	buildMode = false

func lookForSkeletonUnder():
	for raycast in $Raycasts.get_children():
		if raycast.is_colliding():
			print(raycast.get_collider().name)
			if raycast.get_collider().is_in_group("enemy"):
				raycast.get_collider().stunned = true

func _on_Area2D_mouse_entered():
	if main.buildMode:
		print("mouseOver")
		$Label.visible = true
		hover = true

func _on_Area2D_mouse_exited():
	if main.buildMode:
		$Label.visible = false
		hover = false

func _input(event):
	if event.is_action_pressed("rightclick") and hover:
		main.get_node("Sell").play()
		main.currentBalance += 20
		main.updateBalance(main.currentBalance)
		queue_free()

func sell():
	main.get_node("Sell").play()
	main.currentBalance += 20
	main.updateBalance(main.currentBalance)
	queue_free()
	
