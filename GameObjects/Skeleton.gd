extends KinematicBody2D

onready var deathParticles = preload("res://PremadeGameAssets/DeathParticles.tscn")

var velocity = Vector2()
var direction = 1
var speed = 60
var gravity = 15

var stunned = false

var gameOver = false

func _ready():
	$AnimatedSprite.play("Walk")
	changeRaycastPos()

func _physics_process(delta):
	if is_on_wall() or not $FloorChecker.is_colliding() and is_on_floor() and not gameOver:
		direction = direction * -1
		$AnimatedSprite.flip_h = not $AnimatedSprite.flip_h
		changeRaycastPos()
	
	if not gameOver:
		velocity.y += gravity
		velocity.x = speed * direction

		velocity = move_and_slide(velocity, Vector2.UP)

func changeRaycastPos():
	$FloorChecker.position.x = $CollisionShape2D.shape.get_extents().x * direction


func _on_Area2D_area_entered(area):
	if area.is_in_group("player"):
		var player = area.get_owner()
		if player.dead == false:
			gameOver = true
			player.die()
	elif area.is_in_group("cratekill"):
		var crate = area.get_owner()
		if not crate.buildMode:
			var particleInstance = deathParticles.instance()
			get_tree().get_nodes_in_group("main")[0].add_child(particleInstance)
			particleInstance.position = self.position
			queue_free()

func enterBuildMode():
	speed = 0
	gravity = 0
	$AnimatedSprite.play("Idle")

func exitBuildMode():
	if not stunned:
		print("not stunned")
		speed = 60
		gravity = 15
		$AnimatedSprite.play("Walk")
	elif stunned:
		print("stunned")
		$Timer.start()

func _on_Timer_timeout():
	stunned = false
	exitBuildMode()
