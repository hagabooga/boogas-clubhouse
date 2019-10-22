tool
extends Spatial

const board_size : int = 8
var tile = preload("res://checkers/CheckersTile.tscn")
var tile_dark = preload("res://checkers/CheckersTileDark.tscn")

var tiles = []
var tiles_reverse = []

var turn = -1
var player = null

var players

func _ready():
	pre_configure_game()

remotesync func next_turn() -> void:
	turn += 1
	var copy = players.duplicate()
	for x in players:
		if x.player_color == turn % 2:
			x.enable_click(true)
			copy.erase(x)
	copy[0].enable_click(false)
	update_ui()

func update_ui():
	$UI/VBoxContainer/Turn.text	= "Turn: %d"%turn
	$UI/VBoxContainer/WhoseTurn.text = ("Black" if turn % 2 else "Red") + " Player's Turn"

remote func pre_configure_game() -> void:
	var thisPlayer = preload("res://checkers/CheckersPlayer.tscn").instance()
	var otherPlayer = preload("res://checkers/CheckersPlayer.tscn").instance()
	for row in range(board_size):
		tiles.append([])
		for col in range(board_size):
			var add_tile = tile_dark if (row + col) % 2 else tile
			add_tile = add_tile.instance()
			$CheckerBoard.add_child(add_tile)
			tiles[row].append(add_tile)
			var pos = Vector3(col*2, 0, row*2)
			add_tile.transform.origin = pos
			add_tile.connect("clicked", thisPlayer, "put_down")
			add_tile.connect("clicked", otherPlayer, "put_down")
			
	reverse()
	setup_player(thisPlayer)
	setup_player(otherPlayer)
	thisPlayer.connect("finished_turn", self, "rpc_unreliable", ["next_turn"])
	thisPlayer.opponent = otherPlayer
	
	otherPlayer.opponent = thisPlayer
	otherPlayer.connect("finished_turn", self, "rpc_unreliable", ["next_turn"])
	players = [thisPlayer, otherPlayer]
	
	rpc_unreliable("next_turn")

func setup_player(thisPlayer : CheckersPlayer):
	if get_tree().is_network_server() and player == null:
		print(111)
		thisPlayer.set_name(str(get_tree().get_network_unique_id()))
		thisPlayer.set_network_master(get_tree().get_network_unique_id())
		thisPlayer.player_color = 0
		thisPlayer.setup_tiles = tiles_reverse
		thisPlayer.piece = preload("res://checkers/CheckersPiece.tscn")
		player = thisPlayer
		thisPlayer.move_pieces_start(get_tree().get_network_unique_id())
	else:
		if player == null:
			print(222)
			thisPlayer.set_name(str(get_tree().get_network_unique_id()))
			thisPlayer.set_network_master(get_tree().get_network_unique_id())
			thisPlayer.player_color = 1
			thisPlayer.setup_tiles = tiles
			thisPlayer.piece = preload("res://checkers/CheckersPieceBlack.tscn")
			player = thisPlayer
			$BlackCamera.make_current()
			thisPlayer.move_pieces_start(get_tree().get_network_unique_id())
		else:
			print(333)
			thisPlayer.set_name(str(globals.otherPlayerId))
			thisPlayer.set_network_master(globals.otherPlayerId)
			thisPlayer.player_color = (player.player_color + 1)%2
			thisPlayer.setup_tiles = tiles if thisPlayer.player_color else tiles_reverse
			thisPlayer.piece = preload("res://checkers/CheckersPieceBlack.tscn") if thisPlayer.player_color else\
			preload("res://checkers/CheckersPiece.tscn")
			thisPlayer.move_pieces_start(globals.otherPlayerId)
			
	#print("NETOWRK ID: ",get_tree().get_network_unique_id())
	
	add_child(thisPlayer)

func reverse():
	tiles_reverse = tiles.duplicate(true)
	tiles_reverse.invert()
	for b in tiles:
		b.invert()