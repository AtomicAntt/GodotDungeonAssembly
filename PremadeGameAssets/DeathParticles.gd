extends Particles2D

onready var skeleton = preload("res://GameAssets/extra/008.png")
var type = 1


func _ready():
	if type == 1:
		self.set_texture(skeleton)
	$AnimationPlayer.play("play")
	$AudioStreamPlayer2D.play()

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "play":
		queue_free()
