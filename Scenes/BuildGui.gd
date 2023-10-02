extends Control

onready var levels = $Levels
onready var assembledPieces = $Levels/AssembledPieces
onready var platform = preload("res://GameObjects/Platform1.tscn")
onready var crate = preload("res://GameObjects/Crate.tscn")
onready var movingPlatform = preload("res://GameObjects/MovingPlatform.tscn")
onready var movingPlatform2 = preload("res://GameObjects/MovingPlatform2.tscn")

signal fadedIn
#onready var spikes = preload()

var objectDragged = null
var levelInstance

var buildMode = false

var gameOver = false
var currentBalance = 0
var balances = [60, 100, 250, 130, 150]

var currentLevel = 1
var lastLevel = 6

var musicVolume = 1.0
var effectsVolume = 1.0

var inMainMenu = true

func _ready():
#	loadLevel("World1")
#	updateBalance(balances[currentLevel-1])
	pass

func _on_start_pressed():
	currentLevel = 1
	inMainMenu = false
	$titleScreen.visible = false
	$Selected.play()
	loadLevel("World1")
	showDialogue()
	updateBalance(balances[currentLevel-1])
	$Music1.stop()
	$Music2.play()

func _on_QuitButton_pressed():
	$Levels/CanvasLayer/BuildGui.visible = false
	$Levels/CanvasLayer/DeathGui.visible = false
	$Levels/CanvasLayer/WinGui.visible = false
	$Levels/CanvasLayer/PauseGui.visible = false
	$Levels/CanvasLayer/ColorRect.visible = false
	inMainMenu = true
	$titleScreen.visible = true
	gameOver = false
	unloadLevel()
	$Music1.play()
	$Music2.stop()
	setVolumeLinearly(musicVolume)
	


func unloadLevel():
	if (is_instance_valid(levelInstance)):
		levelInstance.queue_free()
	levelInstance = null
	
	for node in assembledPieces.get_children():
		node.queue_free()

func loadLevel(levelName):
	$Levels/CanvasLayer/PlayGui.visible = true
	$Levels/CanvasLayer/PlayGui/Label.text = "Level " + str(currentLevel)
	setVolumeLinearly(musicVolume)	
	get_tree().paused = false
	unloadLevel()
	var levelPath = "res://Scenes/%s.tscn" % levelName
	var levelResource = load(levelPath)
	if levelResource:
		levelInstance = levelResource.instance()
		levels.add_child(levelInstance)
	
	updateBalance(balances[currentLevel-1])
	

func _physics_process(delta):
	if objectDragged != null:
		objectDragged.position = get_global_mouse_position()
		if objectDragged.get_node("Area2D").get_overlapping_bodies().size() > 0 or currentBalance < obtainCostOfObject():
			objectDragged.modulate = Color("#ee1919")
			objectDragged.modulate.a = 0.5
		else:
			objectDragged.modulate = Color("#ffffff")
			objectDragged.modulate.a = 0.5
	if Input.is_action_just_pressed("interact") and Global.canPass == true:
		doorInteract()
	if Input.is_action_just_pressed("pause") and not gameOver:
		pause()
		

func _on_PlatformOne_button_down():
	if currentBalance >= 50:
		$Pickup.play()	
		var platformInstance = platform.instance()
		platformInstance.get_node("CollisionShape2D").disabled = true
		platformInstance.modulate.a = 0.5
		assembledPieces.add_child(platformInstance)
		objectDragged = platformInstance
		platformInstance.playerBased = true
	else:
		$WrongPlacement.play()
		$Levels/CanvasLayer/BuildGui/HBoxContainer/VBoxContainer/PlatformOne.modulate = Color("#ee1919")
		
	

func _on_object_button_up():
	if not objectDragged:
		$Levels/CanvasLayer/BuildGui/HBoxContainer/VBoxContainer/PlatformOne.modulate = Color("#ffffff")
		$Levels/CanvasLayer/BuildGui/HBoxContainer/VBoxContainer3/MovingPlatform.modulate = Color("#ffffff")
		$Levels/CanvasLayer/BuildGui/HBoxContainer/VBoxContainer2/MovingPlatform2.modulate = Color("#ffffff")
		$Levels/CanvasLayer/BuildGui/HBoxContainer/VBoxContainer4/CenterContainer/Crate.modulate = Color("#ffffff")
		return
	if objectDragged.get_node("Area2D").get_overlapping_bodies().size() == 0 and currentBalance >= obtainCostOfObject():
		$Placedown.play()
		currentBalance -= obtainCostOfObject()
		updateBalance(currentBalance)
		objectDragged.modulate.a = 1
		if not objectDragged.is_in_group("movingPlatform"):
			objectDragged.get_node("CollisionShape2D").disabled = false
		else:
			objectDragged.exitBuildMode()
		if objectDragged.is_in_group("crate"):
			objectDragged.lookForSkeletonUnder()
		objectDragged = null
	else:
		$WrongPlacement.play()
		objectDragged.queue_free()
		objectDragged = null
		

func doorInteract():
	Global.canPass = false
	currentLevel += 1
	$LevelCompleted.play()
	var door = levelInstance.get_node("Door")
	var player = levelInstance.get_node("Player")
	player.visible = false
	player.buildMode()
	door.openDoor()
	yield(door, "finishedClosing")
	transitionLevelFrom()
	yield(self, "fadedIn")
	if currentLevel >= lastLevel:
		$Levels/CanvasLayer/WinGui.visible = true
		get_tree().paused = true
	else:
		loadLevel("World" + str(currentLevel))
	
	

func enterBuildMode():
	var camera = levelInstance.get_node("Camera2D")
	var goToPos = camera.position
	var goToZoom = camera.zoom
	var player = levelInstance.get_node("Player")
	var playerCamera = player.get_node("Camera2D")
	var tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	camera.position = player.position	
	tween.tween_property(camera, "position", goToPos, 1)
	tween.parallel().tween_property(camera, "zoom", goToZoom, 1)
	tween.parallel().tween_method(self, "setVolumeLinearly", musicVolume, musicVolume / 4.0, 1.0)
	tween.parallel().tween_property($Levels/CanvasLayer/ColorRect, "color", Color("#1c025cf8"), 1.0)
#	camera.position = player.position
	camera.current = true
	player.buildMode()
	$Levels/CanvasLayer/BuildGui.visible = true
	$Levels/CanvasLayer/ColorRect.visible = true
	
	buildMode = true
	
	for enemy in get_tree().get_nodes_in_group("enemy"):
		enemy.enterBuildMode()
	
func _on_ConfirmButton_pressed():
	exitBuildMode()

func exitBuildMode():
	buildMode = false
#	levelInstance.get_node("Player").get_node("Camera2D").current = true
	var camera = levelInstance.get_node("Camera2D")
	var initialPos = camera.position
	var initialZoom = camera.zoom
	var player = levelInstance.get_node("Player")
	var playerCamera = player.get_node("Camera2D")
	var goToPos = player.position
	var goToZoom = playerCamera.zoom
	var tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(camera, "position", goToPos, 1)
	tween.parallel().tween_property(camera, "zoom", goToZoom, 1)
	tween.parallel().tween_method(self, "setVolumeLinearly", musicVolume / 4, musicVolume, 1.0)
	tween.parallel().tween_property($Levels/CanvasLayer/ColorRect, "color", Color("#00025cf8"), 1.0)
	$Levels/CanvasLayer/BuildGui.visible = false
	
	
	
	
#	camera.position = player.position
#	camera.current = true
	for enemy in get_tree().get_nodes_in_group("enemy"):
		enemy.exitBuildMode()
	
	for crate in get_tree().get_nodes_in_group("crate"):
		crate.exitBuildMode()
		
	yield(tween, "finished")
	
	playerCamera.current = true
	
	camera.position = initialPos
	camera.zoom = initialZoom
	
	player.exitBuildMode()
	$Levels/CanvasLayer/ColorRect.visible = false
	

func _on_Crate_button_down():
	if currentBalance >= 20:
		$Pickup.play()
		var crateInstance = crate.instance()
		objectDragged = crateInstance	
		crateInstance.get_node("CollisionShape2D").disabled = true
		crateInstance.modulate.a = 0.5
		assembledPieces.add_child(crateInstance)
		objectDragged = crateInstance
	else:
		$WrongPlacement.play()
		$Levels/CanvasLayer/BuildGui/HBoxContainer/VBoxContainer4/CenterContainer/Crate.modulate = Color("#ee1919")


func _on_MovingPlatform_button_down():
	if currentBalance >= 90:
		$Pickup.play()	
		var movingPlatformInstance = movingPlatform.instance()
		movingPlatformInstance.modulate.a = 0.5
		assembledPieces.add_child(movingPlatformInstance)
		objectDragged = movingPlatformInstance
		movingPlatformInstance.buildMode()
	else:
		$WrongPlacement.play()
		$Levels/CanvasLayer/BuildGui/HBoxContainer/VBoxContainer3/MovingPlatform.modulate = Color("#ee1919")


func _on_MovingPlatform2_button_down():
	if currentBalance >= 90:
		$Pickup.play()	
		var movingPlatformInstance = movingPlatform2.instance()
		movingPlatformInstance.modulate.a = 0.5
		assembledPieces.add_child(movingPlatformInstance)
		objectDragged = movingPlatformInstance
		movingPlatformInstance.buildMode()
	else:
		$WrongPlacement.play()
		$Levels/CanvasLayer/BuildGui/HBoxContainer/VBoxContainer2/MovingPlatform2.modulate = Color("#ee1919")

func _on_RestartButton_pressed():
	loadLevel("World" + str(currentLevel))
	setVolumeLinearly(musicVolume)
	$Music2.play()
	$Levels/CanvasLayer/DeathGui.visible = false
	$Levels/CanvasLayer/PauseGui.visible = false
	$Levels/CanvasLayer/BuildGui.visible = false
	$Levels/CanvasLayer/WinGui.visible = false
	$Levels/CanvasLayer/ColorRect.visible = false
	gameOver = false
	get_tree().paused = false
	showDialogue()

func die():
	var tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_method(self, "setVolumeLinearly", musicVolume, 0.0, 0.5)
	$Die.play()
	$Levels/CanvasLayer/DeathGui.visible = true
	gameOver = true
	

func _on_ResumeButton_pressed():
	get_tree().paused = false
	$Levels/CanvasLayer/PauseGui.visible = false
	
func updateBalance(newBalance):
	currentBalance = newBalance
	$Levels/CanvasLayer/BuildGui/BalanceLabel.text = "Current Balance: $" + str(newBalance)

func obtainCostOfObject():
	if objectDragged.is_in_group("platform"):
		return 50
	elif objectDragged.is_in_group("movingPlatform"):
		return 90
	elif objectDragged.is_in_group("crate"):
		return 20

func scaleUp(object, text):
	var tween = create_tween().set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(object, "rect_scale", Vector2(1.2, 1.2), 1)
	tween.parallel().tween_property(text, "rect_scale", Vector2(1.2, 1.2), 1)

func scaleDown(object, text):
	var tween = create_tween().set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(object, "rect_scale", Vector2(1, 1), 1)
	tween.parallel().tween_property(text, "rect_scale", Vector2(1, 1), 1)


func _on_PlatformOne_mouse_entered():
	$HoverParts.play()
	scaleUp($Levels/CanvasLayer/BuildGui/HBoxContainer/VBoxContainer/PlatformOne, $Levels/CanvasLayer/BuildGui/HBoxContainer/VBoxContainer/Label)

func _on_PlatformOne_mouse_exited():
	scaleDown($Levels/CanvasLayer/BuildGui/HBoxContainer/VBoxContainer/PlatformOne, $Levels/CanvasLayer/BuildGui/HBoxContainer/VBoxContainer/Label)

func _on_MovingPlatform_mouse_entered():
	$HoverParts.play()	
	scaleUp($Levels/CanvasLayer/BuildGui/HBoxContainer/VBoxContainer3/MovingPlatform, $Levels/CanvasLayer/BuildGui/HBoxContainer/VBoxContainer3/Label)

func _on_MovingPlatform_mouse_exited():
	scaleDown($Levels/CanvasLayer/BuildGui/HBoxContainer/VBoxContainer3/MovingPlatform, $Levels/CanvasLayer/BuildGui/HBoxContainer/VBoxContainer3/Label)

func _on_MovingPlatform2_mouse_entered():
	$HoverParts.play()
	scaleUp($Levels/CanvasLayer/BuildGui/HBoxContainer/VBoxContainer2/MovingPlatform2, $Levels/CanvasLayer/BuildGui/HBoxContainer/VBoxContainer2/Label)

func _on_MovingPlatform2_mouse_exited():
	scaleDown($Levels/CanvasLayer/BuildGui/HBoxContainer/VBoxContainer2/MovingPlatform2, $Levels/CanvasLayer/BuildGui/HBoxContainer/VBoxContainer2/Label)

func _on_Crate_mouse_entered():
	$HoverParts.play()	
	scaleUp($Levels/CanvasLayer/BuildGui/HBoxContainer/VBoxContainer4/CenterContainer/Crate, $Levels/CanvasLayer/BuildGui/HBoxContainer/VBoxContainer4/Label)

func _on_Crate_mouse_exited():
	scaleDown($Levels/CanvasLayer/BuildGui/HBoxContainer/VBoxContainer4/CenterContainer/Crate, $Levels/CanvasLayer/BuildGui/HBoxContainer/VBoxContainer4/Label)

func setVolumeLinearly(value):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear2db(value))

func setEffectsVolumeLinearly(value):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Effects"), linear2db(value))

func _on_button_mouse_entered():
	$Selecting.play()

func _on_SellButton_pressed():
	if $Levels/AssembledPieces.get_children().size() <= 0:
		$WrongPlacement.play()
	else:
		for part in $Levels/AssembledPieces.get_children():
			part.sell()

func _on_Pause_pressed():
	pause()

func pause():
	if not inMainMenu:
		$Levels/CanvasLayer/PauseGui.visible = not $Levels/CanvasLayer/PauseGui.visible
		get_tree().paused = not get_tree().paused
		if not get_tree().paused:
			setVolumeLinearly(musicVolume)
		else:
			setVolumeLinearly(musicVolume / 10)

func _on_settings_pressed():
	$Selected.play()
	
	$titleScreen/buttons.visible = false
	$titleScreen/trap.visible = false
	$titleScreen/skeleton.visible = false
	$Levels/CanvasLayer/SettingsGui.visible = true
	$titleScreen.stopped = true


func _on_BackButton_pressed():
	$Selected.play()	
	$Levels/CanvasLayer/SettingsGui.visible = false
	
	$titleScreen/buttons.visible = true
	$titleScreen/trap.visible = true
	$titleScreen/skeleton.visible = true
	$titleScreen.stopped = false

func _on_HSlider_value_changed(value):
	$MoveSlider.play()
	musicVolume = value
	setVolumeLinearly(value)

func _on_EffectsSlider_value_changed(value):
	$MoveSlider.play()	
	effectsVolume = value
	setEffectsVolumeLinearly(value)

func transitionLevelFrom():
	$Levels/CanvasLayer/LevelTransition/Label.text = "Level " + str(currentLevel - 1) + " completed"
	$Levels/CanvasLayer/LevelTransition.visible = true
	$Levels/CanvasLayer/LevelTransition/AnimationPlayer.play("FadeIn")
	yield($Levels/CanvasLayer/LevelTransition/AnimationPlayer, "animation_finished")
	emit_signal("fadedIn")
	yield(get_tree().create_timer(1.0), "timeout")
	transitionLevelTo()
	
func transitionLevelTo():
	$Levels/CanvasLayer/LevelTransition/AnimationPlayer.play_backwards("FadeIn")
	yield($Levels/CanvasLayer/LevelTransition/AnimationPlayer, "animation_finished")
	showDialogue()
	$Levels/CanvasLayer/LevelTransition.visible = false

func showDialogue():
	var dialogue = levelInstance.get_node("Dialogue")
	dialogue.show()
