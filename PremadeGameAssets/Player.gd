extends KinematicBody2D

# Atomic Ant's premade 2d platformer type code with coyote time and jump buffering

# Dependencies
# Input map: up, left, down, right

enum States {AIR, FLOOR, DEAD, BUILD}

onready var coyoteTimer = $CoyoteTimer
onready var platform = preload("res://GameObjects/Platform1.tscn")
onready var main = get_tree().get_nodes_in_group("main")[0]

var state = States.AIR
var velocity = Vector2.ZERO
var dead = false
var direction = 1

const SPEED = 130
const GRAVITY = 15
const JUMP = -200

func _ready():
	dead = false

func _physics_process(delta):
	match state:
		States.AIR:
			$AnimatedSprite.play("Jump")
			if is_on_floor():
				state = States.FLOOR
				continue # skips lines of code
			if Input.is_action_pressed("right"):
				velocity.x = lerp(velocity.x, SPEED, 0.1)
				$AnimatedSprite.flip_h = false
				direction = 1
				$RayCast2D.cast_to.x = 10
			elif Input.is_action_pressed("left"):
				velocity.x = lerp(velocity.x, -SPEED, 0.1)
				$AnimatedSprite.flip_h = true
				direction = -1
				$RayCast2D.cast_to.x = -10
			else:
				velocity.x = lerp(velocity.x, 0, 0.6)
			
			if Input.is_action_just_pressed("up"):
				print("cant jump in air")
			moveAndFall()
		States.FLOOR:
			var snap = Vector2.DOWN * 0
			#TRANSITIONS TO OTHER STATES (in this case only air)
			if Input.is_action_just_pressed("up"): # floor transitions to air state by jumping
				coyoteTimer.stop()
				velocity.y = JUMP
				state = States.AIR
				main.get_node("Jump").play()
			elif not is_on_floor() && coyoteTimer.is_stopped(): # you just walked off a cliff (Additionally: coyote timer starts for leniency)
				coyoteTimer.start()
				velocity.y = 0
			else:
				snap = Vector2.DOWN * 32
				
			if Input.is_action_pressed("right"):
				velocity.x = lerp(velocity.x, SPEED, 0.1)
				$AnimatedSprite.play("Walk")	
				$AnimatedSprite.flip_h = false
				direction = 1
				$RayCast2D.cast_to.x = 10
			elif Input.is_action_pressed("left"):
				velocity.x = lerp(velocity.x, -SPEED, 0.1)
				$AnimatedSprite.play("Walk")				
				$AnimatedSprite.flip_h = true
				direction = -1
				$RayCast2D.cast_to.x = -10
			else:
				velocity.x = lerp(velocity.x, 0, 0.6)
				$AnimatedSprite.play("Idle")
			move(snap)
		States.DEAD:
			moveAndFall()
			velocity.x = lerp(velocity.x, 0, 0.6)
		States.BUILD:
			$AnimatedSprite.play("Idle")
			
	if $RayCast2D.is_colliding():
		if $RayCast2D.get_collider().is_in_group("crate"):
			$AnimatedSprite.play("Push")
	
#	if Input.is_action_just_pressed("click"):
#		spawnPlatform()
		
#func spawnPlatform():
#	var platformInstance = platform.instance()
#	get_tree().get_root().add_child(platformInstance)
#	platformInstance.global_position = get_global_mouse_position()


func moveAndFall():
	velocity = move_and_slide(velocity, Vector2.UP)
	velocity.y += GRAVITY
	

func move(snap):
	velocity = move_and_slide_with_snap(velocity, snap, Vector2.UP)
	velocity.y += GRAVITY

func die():
	if not dead:
		dead = true
		state = States.DEAD
		$AnimatedSprite.play("Collapse")
		main.die()

func buildMode():
	state = States.BUILD
#	modulate.a = 0

func exitBuildMode():
	state = States.AIR
#	modulate.a = 1

func _on_CoyoteTimer_timeout():
	if not is_on_floor():
		state = States.AIR
	
#func _on_Area2D_area_entered(area):
#	if area.is_in_group("crateArea") and state != States.BUILD:
#		area.get_owner().velocity.x += velocity.x
