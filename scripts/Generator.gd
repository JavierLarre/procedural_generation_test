extends Node2D

const ROOM_SIZE = 32
const DOOR_SIZE = 8
const SQUARE_ROOM = preload("res://scenes/square_room.tscn")
const CORRIDOR = preload("res://scenes/corridor.tscn")
var spawn_room

func _ready():
	spawn_room = SQUARE_ROOM.instantiate()
	$Rooms.add_child(spawn_room)
	open_left(spawn_room)

func open_left(room):
	var tile_map = room.get_node("TileMap")
	const room_side = ROOM_SIZE >> 1
	const door_side = DOOR_SIZE >> 1
	for i in range(-door_side, door_side):
		tile_map.erase_cell(0, Vector2i(-room_side, i))
