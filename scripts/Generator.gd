extends Node2D

const LEVEL_SIZE := Vector2i(1000, 800)
const ROOM_SIZE := Vector2i(100, 140) # min, max
const MAX_ROOMS := 15
const ROOM_COLOR := Color(0.369, 0.369, 0.369, 1)

@onready var tile_map = $TileMap


func _ready():
	randomize()
	var rooms = generate_rooms()
	rooms_to_rects(rooms)
	var corridors = connect_rooms(rooms)
	corridors_to_rects(corridors)
		
func generate_rooms():
	var rooms: Array[Rect2i] = []
	var room: Rect2i
	for r in range(MAX_ROOMS):
		room = generate_room()
		if intersect_with_rooms(rooms, room):
			continue
		rooms.append(room)
	return rooms
		
func generate_room() -> Rect2i:
	#ugly ahh function
	var width := randi_range(ROOM_SIZE.x, ROOM_SIZE.y)
	var height := randi_range(ROOM_SIZE.x, ROOM_SIZE.y)
	var x_pos := randi_range(0, LEVEL_SIZE.x)
	var y_pos := randi_range(0, LEVEL_SIZE.y)
	return Rect2i(x_pos, y_pos, width, height)

func intersect_with_rooms(rooms: Array[Rect2i], room: Rect2i):
	var intersects := false
	for compared_room in rooms:
		if room.intersects(compared_room):
			intersects = true
			break
	return intersects

func rooms_to_rects(rooms: Array[Rect2i]):
	var color_rect
	for room in rooms:
		color_rect = ColorRect.new()
		color_rect.global_position = room.position
		color_rect.size = room.size
		color_rect.color = ROOM_COLOR
		$Rooms.add_child(color_rect)
		
func connect_rooms(rooms: Array[Rect2i]) -> Array:
	if rooms.size() <= 1:
		return []
	var corridors := {}
	var room_center_1: Vector2i
	var room_center_2: Vector2i
	for i in rooms.size()-1:
		room_center_1 = (rooms[i].position + rooms[i].end) / 2
		room_center_2 = (rooms[i+1].position + rooms[i+1].end) / 2
		var coin_flip := randi() % 1
		if coin_flip:
			add_corridor(corridors, room_center_1.x, room_center_2.x, room_center_1.y, Vector2i.AXIS_X)
			add_corridor(corridors, room_center_1.y, room_center_2.y, room_center_2.x, Vector2i.AXIS_Y)
		else:
			add_corridor(corridors, room_center_1.y, room_center_2.y, room_center_1.x, Vector2i.AXIS_Y)
			add_corridor(corridors, room_center_1.x, room_center_2.x, room_center_2.y, Vector2i.AXIS_X)
	return corridors.keys()
			
func add_corridor(corridors: Dictionary, start: int, end: int, constant: int, axis: int):
	for t in range(min(start, end), max(start, end) + 1):
		var point
		if axis == Vector2i.AXIS_X:
			point = Vector2i(t, constant)
		elif axis == Vector2i.AXIS_Y:
			point = Vector2i(constant, t)
		corridors[point] = null

func corridors_to_rects(corridors: Array):
	var color_rect
	for corridor in corridors:
		color_rect = ColorRect.new()
		color_rect.global_position = corridor
		color_rect.size = Vector2(1, 1)
		color_rect.color = Color(1, 1, 1, 1)
		$Corridors.add_child(color_rect)
