extends Spatial

var mouse_pos = Vector2.ZERO
var start
var end
var holding = false

func _ready():
	start = transform.origin



func _on_Area_input_event(camera, event, click_position, click_normal, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			$MeshInstance/Selected.visible = !$MeshInstance/Selected.visible
			holding = true
	elif event is InputEventMouseMotion:
		if holding:
			transform.origin = Vector3(click_position.x, 2, click_position.y)

