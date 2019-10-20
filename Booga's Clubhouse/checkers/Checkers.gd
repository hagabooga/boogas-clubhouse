tool
extends Spatial

const board_size : int = 8
var tile = preload("res://checkers/CheckersTile.tscn")
var tile_dark = preload("res://checkers/CheckersTileDark.tscn")

var original_pos
var current_piece = null

var tiles = []
var tiles_reverse = []

var turn = 0


func _ready():
	pre_configure_game()


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

	thisPlayer.set_name(str(get_tree().get_network_unique_id()))
	thisPlayer.set_network_master(get_tree().get_network_unique_id())
	thisPlayer.player_color = 0
	thisPlayer.setup_tiles = tiles_reverse
	thisPlayer.piece = preload("res://checkers/CheckersPiece.tscn")
	thisPlayer.move_pieces_start(get_tree().get_network_unique_id())

	add_child(thisPlayer)
	

	otherPlayer.set_name(str(globals.otherPlayerId))
	otherPlayer.set_network_master(globals.otherPlayerId)
	otherPlayer.player_color = 1
	otherPlayer.setup_tiles = tiles
	otherPlayer.piece = preload("res://checkers/CheckersPieceBlack.tscn")
	otherPlayer.move_pieces_start(globals.otherPlayerId)
	add_child(otherPlayer)
	
	thisPlayer.opponent = otherPlayer
	otherPlayer.opponent = thisPlayer
	
#	$PlayerRed.setup_tiles = tiles
#	$PlayerRed.move_pieces_start()
#	$PlayerRed.opponent = $PlayerBlack
#	$PlayerBlack.setup_tiles = tiles_reverse
#	$PlayerBlack.move_pieces_start()
#	$PlayerBlack.opponent = $PlayerRed
		
func reverse():
	tiles_reverse = tiles.duplicate(true)
	tiles_reverse.invert()
	for b in tiles:
		b.invert()