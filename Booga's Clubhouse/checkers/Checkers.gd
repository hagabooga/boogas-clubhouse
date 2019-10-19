tool
extends Spatial


var tile = preload("res://checkers/CheckersTile.tscn")
var tile_dark = preload("res://checkers/CheckersTileDark.tscn")

const board_size : int = 8

const tile_size : int = 2
#const tile_size : int = 2
const peice_height : float = 0.2
const num_pieces = 12

var original_pos
var current_piece = null

var tiles_dict = {}
var tiles = []
var tiles_reverse = []
var original_tiles = []



func _ready():
	create_board()
	reverse()
	$PlayerRed.setup_tiles = tiles
	$PlayerRed.move_pieces_start()
	$PlayerRed.opponent = $PlayerBlack
	
	$PlayerBlack.setup_tiles = tiles_reverse
	$PlayerBlack.move_pieces_start()
	$PlayerBlack.opponent = $PlayerRed

func create_board() -> void:
	for row in range(board_size):
		tiles.append([])
		for col in range(board_size):
			var add_tile = tile_dark if (row + col) % 2 else tile
			add_tile = add_tile.instance()
			$CheckerBoard.add_child(add_tile)
			tiles[row].append(add_tile)
			var pos = Vector3(col*2, 0, row*2)
			add_tile.transform.origin = pos
			add_tile.connect("clicked", $PlayerRed, "put_down")
			add_tile.connect("clicked", $PlayerBlack, "put_down")
			tiles_dict[Vector2(pos.z,pos.x)/2] = add_tile
	print(tiles_dict)
			
		
func reverse():
	#original_tiles = tiles.duplicate()
	tiles_reverse = tiles.duplicate(true)
	tiles_reverse.invert()
	for b in tiles:
		b.invert()