extends Node

class_name CheckersPlayer

enum PlayerColor {RED, BLACK}
export (PlayerColor) var player_color


var piece : PackedScene = null
var setup_tiles = null
var current_piece : CheckersPiece = null
var original_pos : Vector2
var opponent : CheckersPlayer = null
var current_legal_moves = null
var original_origin : Vector3


const tile_size : int = 2
const peice_height : float = 0.2
const peice_rows : int = 3
const peice_columns : int = 4

signal placed
signal finished_turn

func _ready():
	connect("finished_turn", self, "enable_click", [false])

func enable_click(yes : bool, except = null) -> void:
	for x in get_children():
		x.can_be_clicked = yes
	if except != null:
		except.can_be_clicked = !yes

remotesync func setPosition(pos):
	current_piece.transform.origin = pos

func _physics_process(delta):
	if !is_network_master():
		return
	if current_piece == null:
		return
	var camera = get_viewport().get_camera()
	var ray_len = camera.transform.origin.distance_to(current_piece.transform.origin)
	var mouse_pos = camera.get_viewport().get_mouse_position()
	var from = camera.project_ray_origin(mouse_pos)
	var to = from + camera.project_ray_normal(mouse_pos) * ray_len
	to.y = peice_height*2
	rpc_unreliable("setPosition", to)
	

func get_piece(pos):
	for x in get_children():
		if x.pos== pos:
			return x

func move_pieces_start(id) -> void:
	for row in range(peice_rows):
		for col in range(peice_columns):
			var add = piece.instance()
			add.connect("clicked", self, "pickup_piece")
			var alternate = !(row%2)
			var column = col*2 if alternate else col*2 + 1
			add.transform.origin = setup_tiles[row][column].transform.origin
			add.transform.origin.y = 0.2
			add_child(add)
			add.set_network_master(id)
			add.pos = Vector2(row,column)
 
remotesync func set_piece(p):
	current_piece = get_piece(p)

func pickup_piece(piece):
	if current_piece == null and piece.is_network_master():
		rpc_unreliable("set_piece", piece.pos)
		original_origin = current_piece.transform.origin
		original_pos = current_piece.pos
		current_piece.disable_collision(true)
		get_legal_moves()

puppet func rpc_put_down(tile_pos, pos, is_king):
	current_piece.pos = pos
	if is_king and !current_piece.is_king:
		current_piece.become_king()
	current_piece.transform.origin = tile_pos
	current_piece.transform.origin.y = peice_height
	current_piece.disable_collision(false)
	current_piece = null


func put_down(tile) -> void:
	print("0 ", current_legal_moves)
	if current_piece != null:
		if tile.is_show_outline():
			var move_pos
			var did_eat = false
			for legal_move in current_legal_moves:
				#if legal_move[0] != original_pos:
				#print(legal_move)
				var place_tile = get_tile(legal_move[0])
				emit_signal("placed")
				disconnect("placed", place_tile, "show_outline")
				if place_tile == tile:
					move_pos = legal_move[0]
					current_piece.pos = move_pos
					if legal_move[1] != null:
						did_eat = true
						place_tile.eat(null)
					if current_piece.pos.x > 6 and !current_piece.is_king:
						current_piece.become_king()
					#print(current_piece.pos)
			rpc_unreliable("rpc_put_down", tile.transform.origin, move_pos, current_piece.pos.x > 6)
			current_piece.transform.origin = tile.transform.origin
			current_piece.transform.origin.y = peice_height
			current_piece.disable_collision(false)
			if did_eat:
				enable_click(false, current_piece)
				rpc_unreliable("set_piece", current_piece.pos)
				original_origin = current_piece.transform.origin
				original_pos = current_piece.pos
				get_legal_moves()
				print("1 ", current_legal_moves)
				var can_eat = false
				for x in current_legal_moves:
					if x[1] != null:
						can_eat = true
						break
				if not can_eat:
					for x in current_legal_moves:
						var final_tile = get_tile(x[0])
						final_tile.show_outline(false)
						emit_signal("placed")
						disconnect("placed", get_tile(x[0]), "show_outline")
					print("cannot eat anymore")
					emit_signal("finished_turn")
			elif original_pos != current_piece.pos:
				emit_signal("finished_turn")
			current_piece = null
		
slave func set_tile_eat(tile_pos, pos):
	get_tile(tile_pos).eat_piece = opponent.get_piece(pos)

func get_legal_moves() -> void:
	var moves = [[original_pos, null]]
	var left = original_pos.y - 1
	var right = original_pos.y + 1
	var up = original_pos.x + 1
	var down = original_pos.x - 1
	var can_up = up < 8
	var can_down = 0 <= down
	if 0 <= left and left < 8 and can_up:
		var pos = Vector2(up, left)
		if !occupied(pos):
			moves.append([pos, null])
	if 0 <= right and right < 8 and can_up:
		var pos = Vector2(up, right)
		if !occupied(pos):
			moves.append([pos, null])
	if current_piece.is_king:
		if 0 <= left and left < 8 and can_down:
			var pos = Vector2(down, left)
			if !occupied(pos):
				moves.append([pos, null])
		if 0 <= right and right < 8 and can_down:
			var pos = Vector2(down, right)
			if !occupied(pos):
				moves.append([pos, null])
	
	var copy = moves.duplicate()
	for legal_move in moves:
		var move = legal_move[0]
		var move_tile = get_tile(move)
		var can_eat = true
		for op_piece in opponent.get_children():
			var op_tile = opponent.get_tile(op_piece.pos)
			if op_tile == move_tile:
				#print("eat tile: ",op_piece.pos)#, p.queue_free()) 
				copy.erase([move,null])
				var eat_pos = 2*move - original_pos
				if 0 <= eat_pos.x and eat_pos.x < 8 and 0 <= eat_pos.y and eat_pos.y < 8:
					for op in opponent.get_children():
						if opponent.get_tile(op.pos) == get_tile(eat_pos):
							can_eat = false
							break
					if can_eat:
						if !occupied(eat_pos):
							copy.append([eat_pos, op_piece])
							copy.erase([move, null])
	#print(copy)
	for legal_move in copy:
		#print(legal_move)
		var move_tile = get_tile(legal_move[0])
		connect("placed", move_tile, "show_outline", [false])
		move_tile.show_outline(true)
		#print(move_tile)
		move_tile.eat_piece = legal_move[1]
		if legal_move[1] != null:
			#print(legal_move)
			rpc_unreliable("set_tile_eat", legal_move[0], legal_move[1].pos)
	current_legal_moves = copy
	


func occupied(pos) -> bool:
	for x in get_children():
		#print(x,pos)
		if x.pos == pos:
			return true
	return false


func get_tile(pos : Vector2):#-> CheckersTile:
	#pos = pos/2
	return setup_tiles[pos.x][pos.y]