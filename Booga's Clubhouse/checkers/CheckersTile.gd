extends Spatial

signal clicked
var occupied = false

class_name CheckersTile

var eat_piece = null


func _ready():
	connect("clicked", self, "eat")

func _on_Area_input_event(camera, event, click_position, click_normal, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			emit_signal("clicked", self)

func is_show_outline() -> bool:
	return $MeshInstance/Outline.visible

func show_outline(yes : bool) -> void:
	$MeshInstance/Outline.visible = yes

remotesync func rpc_eat():
	eat_piece.queue_free()
	eat_piece = null

func eat(s):
	if eat_piece != null:
		rpc_unreliable("rpc_eat")
#		eat_piece.queue_free()
#		eat_piece = null