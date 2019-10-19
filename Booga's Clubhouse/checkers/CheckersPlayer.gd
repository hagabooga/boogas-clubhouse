tool
extends Node

class_name CheckersPlayer

enum PlayerColor {RED, BLACK}
export (PlayerColor) var player_color


var piece : PackedScene = null
var setup_tiles = null
var current_piece : CheckersPiece = null
var original_pos : Vector2
var opponent : CheckersPlayer = null


const tile_size : int = 2
const peice_height : float = 0.2
const peice_rows : int = 3
const peice_columns : int = 4

signal placed

func _ready():
		piece = load("res://checkers/CheckersPieceBlack.tscn") \
				if player_color else load("res://checkers/CheckersPiece.tscn")

func _physics_process(delta):
	if current_piece != null:
		var camera = get_viewport().get_camera()
		var ray_len = camera.transform.origin.distance_to(current_piece.transform.origin)
		var mouse_pos = camera.get_viewport().get_mouse_position()
		var from = camera.project_ray_origin(mouse_pos)
		var to = from + camera.project_ray_normal(mouse_pos) * ray_len
		to.y = peice_height*2
		current_piece.transform.origin = to


func move_pieces_start() -> void:
	for row in range(peice_rows):
		for col in range(peice_columns):
			var add = piece.instance()
			add.connect("clicked", self, "drag_piece")
			var alternate = !(row%2)
			var column = col*2 if alternate else col*2 + 1
			add.transform.origin = setup_tiles[row][column].transform.origin
			add.transform.origin.y = 0.2
			add_child(add)
			add.pos = Vector2(row,column)

func drag_piece(piece):
	if current_piece == null:
		current_piece = piece
		original_pos = current_piece.pos
		current_piece.disable_collision(true)
		var moves = get_legal_moves()
		#print("Legal moves: ", moves)
		for x in moves:
			var move_tile = get_tile(x)
			#print(move_tile)
			if original_pos == x || !occupied(x):
				move_tile.show_outline(true)
				connect("placed", move_tile, "show_outline", [false])

func put_down(tile) -> void:
	if current_piece != null:
		if tile.is_show_outline():
			for x in get_legal_moves():
				emit_signal("placed")
				disconnect("placed", tile, "show_outline")
				if get_tile(x) == tile:
					current_piece.pos = x
			current_piece.transform.origin = tile.transform.origin
			current_piece.transform.origin.y = peice_height
			current_piece.disable_collision(false)
			current_piece = null

func get_legal_moves() -> Array:
	var moves = [original_pos]
	var left = original_pos.y-1
	var right = original_pos.y+1
	var up = original_pos.x + 1
	var can_up = 0 <= up and up < 8
	if 0 <= left and left < 8 and can_up:
		var pos = Vector2(up, left)
		if !occupied(pos):
			moves.append(pos)
	if 0 <= right and right < 8 and can_up:
		var pos = Vector2(up, right)
		if !occupied(pos):
			moves.append(pos)
	for x in moves:
		for p in opponent.get_children():
			if opponent.setup_tiles[p.pos.x][p.pos.y] == setup_tiles[x.x][x.y]:
				print("can eat: ", p.name)
	return moves

func occupied(pos) -> bool:
	for x in get_children():
		if x.pos == pos:
			return true
	return false


func get_tile(pos : Vector2):#-> CheckersTile:
	#pos = pos/2
	return setup_tiles[pos.x][pos.y]