extends Spatial

signal clicked
var occupied = false

class_name CheckersTile

func _on_Area_input_event(camera, event, click_position, click_normal, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			emit_signal("clicked", self)

func is_show_outline() -> bool:
	return $MeshInstance/Outline.visible

func show_outline(yes : bool) -> void:
	$MeshInstance/Outline.visible = yes