tool
extends Spatial


var tile = load("res://checkers/CheckerTile.tscn")
var tile_dark = load("res://checkers/CheckerTileDark.tscn")

var tiles = []

func _ready():
	for row in range(8):
		tiles.append([])
		var i = 0
		if row % 2 == 0:
			i = 1
		for col in range(8):
			var add_tile
			if i % 2 == 0:
				add_tile = tile.instance()
			else:
				add_tile = tile_dark.instance()
			$CheckerBoard.add_child(add_tile)
			add_tile.transform.origin = Vector3(col*2, 0, row*2)
			tiles[row].append(add_tile)
			i += 1
			
