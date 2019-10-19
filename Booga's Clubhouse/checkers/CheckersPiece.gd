tool
extends Spatial

signal clicked
signal dropped




class_name CheckersPiece

var king_texture : StreamTexture = preload("res://checkers/texture_red_king.png")

var pos : Vector2


func _on_Area_input_event(camera, event, click_position, click_normal, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			emit_signal("clicked", self)
			#print("PRESSED LEFT BUTTON row: ", transform.origin.x,"col: ",transform.origin.z)
			
func become_king() -> void:
	$pCylinder1.get_surface_material(0).albedo_texture = king_texture

func disable_collision(yes):
	$pCylinder1/Area/CollisionShape.disabled = yes

func put_down(pos):
	transform.origin = pos