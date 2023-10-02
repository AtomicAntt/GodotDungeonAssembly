extends Node2D

onready var monitorSize = get_viewport_rect().size
onready var mousePos = get_global_mouse_position()

var stopped = false

func _ready():
# warning-ignore:return_value_discarded
	get_tree().get_root().connect("size_changed", self, "resizedReset")
	monitorSize = get_viewport_rect().size
	mousePos = get_global_mouse_position()

# warning-ignore:unused_argument
func _physics_process(delta):
	if not stopped:
		if $skeleton.position.x < -75:
			$skeleton.scale.x = -1
		elif $skeleton.position.x > 400:
			$skeleton.scale.x = 1
		$skeleton.position.x -= $skeleton.scale.x * 2
		if mousePos != get_global_mouse_position():
			mousePos = get_global_mouse_position()
		if monitorSize.x - mousePos.x > monitorSize.x / 4 and abs(mousePos.x - monitorSize.x) < 3 * monitorSize.x / 4:
			var xScale = (mousePos.x - (monitorSize.x/2)) / (monitorSize.x/2)
			$Logo.position.x = calculate3d(56, 20, xScale)
			$buttons.rect_position.x = calculate3d(56, 20, xScale)
			$wall.position.x = calculate3d(30, 30, xScale)
			$mc.position.x = calculate3d(500, 50, xScale)
			$Hands.position.x = calculate3d(500, 90, xScale)
			$trap.position.x = calculate3d(-25, 15, xScale)

		var yScale = ((mousePos.y - (monitorSize.y/2)) / (monitorSize.y/2))
		$Logo.position.y = calculate3d(30, 10, yScale)
		$buttons.rect_position.y = calculate3d(150, 20, yScale)
		$trap.position.y = calculate3d(10, 5, yScale)
		$mc.position.y = calculate3d(250, 50, yScale)
		$Hands.position.y = calculate3d(260, 60, yScale)
		$wall.position.y = calculate3d(-50, 35, yScale)
		$skeleton.position.y = calculate3d(200, 10, yScale)

func resizedReset():
	monitorSize = get_viewport_rect().size

func calculate3d(base, multiplier, scale, direction=1):
	return base + direction * (multiplier * scale)
