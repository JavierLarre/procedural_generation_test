extends Node2D

var spawn: Vector2

const LEVEL_SIZE := Vector2i(200, 200)
const ROOM_SIZE := Vector2i(15, 30) # min, max
const CORR_WIDTH := 4
const MAX_ROOMS := 20

const ROOM_COLOR := Color(0.369, 0.369, 0.369, 1)
const WALL_TILE_COORDS := Vector2i(0, 1)
const FLOOR_TILE_COORDS := Vector2i(4, 10)

@onready var tile_map = $TileMap


func _ready():
    randomize()
    var rooms = generate_rooms()
    rooms_to_tiles(rooms)
    add_rooom_floor(rooms)
    spawn = get_spawn_room(rooms)
    var corridors = connect_rooms(rooms)
    corridors_to_floor(corridors)
    add_corridor_walls(corridors)
    remove_walls(corridors)
    remove_room_walls(rooms)


#region Room functions
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


func rooms_to_tiles(rooms: Array[Rect2i]):
    var tile_map := $TileMap
    var room_walls: Array[Vector2i]
    for room in rooms:
        room_walls = generate_room_walls(room)
        for coord in room_walls:
            tile_map.set_cell(1, coord, 0, WALL_TILE_COORDS)


func generate_room_walls(room: Rect2i):
    var coords: Array[Vector2i] = []
    
    for i in range(room.position.x, room.end.x + 1):
        coords.append(Vector2i(i, room.position.y))
        coords.append(Vector2i(i, room.end.y))
        
    for i in range(room.position.y, room.end.y):
        coords.append(Vector2i(room.position.x, i))
        coords.append(Vector2i(room.end.x, i))
        
    return coords
    
    
func add_rooom_floor(rooms: Array[Rect2i]):
    var color_rect
    var tile_size = $TileMap.tile_set.tile_size.x
    for room in rooms:
        color_rect = FloorColor.new()
        color_rect.global_position = room.position * tile_size
        color_rect.size = (room.size + Vector2i(1, 1)) * tile_size # +1 to include corners
        color_rect.on_color = Color(1, 1, 1, 1)
        color_rect.off_color = ROOM_COLOR
        $Rooms.add_child(color_rect)
        
        
func remove_room_walls(rooms: Array[Rect2i]):
    for room in rooms:
        for x in range(room.position.x + 1, room.end.x):
            for y in range(room.position.y + 1, room.end.y):
                tile_map.erase_cell(1, Vector2i(x, y))
#endregion


#region Corridor functions
func connect_rooms(rooms: Array[Rect2i]) -> Array:
    if rooms.size() <= 1:
            return []
    var corridors: Array[Rect2i] = []
    for i in rooms.size()-1:
        connect_two_rooms(corridors, rooms[i], rooms[i+1])
    return corridors


func connect_two_rooms(corridors, room_1, room_2):
    var room_center_1 = calculate_room_center(room_1)
    var room_center_2 = calculate_room_center(room_2)
    var coin_flip := randi() % 1
    if coin_flip: # i do not how this works, dont ask me please teach me
        add_corridor(corridors, room_center_1.x, room_center_2.x, room_center_1.y, Vector2i.AXIS_X)
        add_corridor(corridors, room_center_1.y, room_center_2.y, room_center_2.x, Vector2i.AXIS_Y)
    else:
        add_corridor(corridors, room_center_1.x, room_center_2.x, room_center_1.y, Vector2i.AXIS_X)
        add_corridor(corridors, room_center_1.y, room_center_2.y, room_center_2.x, Vector2i.AXIS_Y)


func calculate_room_center(room):
    return (room.position + room.end) / 2


func add_corridor(corridors: Array, start: int, end: int, constant: int, axis: int):
    var corridor = Rect2i()
    if not axis:
        corridor.position = Vector2i(min(start, end), constant)
        corridor.end = Vector2i(max(start, end), constant + 1)
    else:
        corridor.position = Vector2i(constant, min(start, end))
        corridor.end = Vector2i(constant + 1, max(start, end))
    corridor.position -= Vector2i(CORR_WIDTH, CORR_WIDTH)
    corridor.end += Vector2i(CORR_WIDTH, CORR_WIDTH)
    corridors.append(corridor)
    
    #for t in range(min(start, end), max(start, end) + 1):
        #var point
        #if axis == Vector2i.AXIS_X:
            #point = Vector2i(t, constant)
        #elif axis == Vector2i.AXIS_Y:
            #point = Vector2i(constant, t)
        #corridors[point] = null


func corridors_to_tiles(corridors: Array):
    var tile_map = $TileMap
    for corridor in corridors:
        tile_map.set_cell(0, corridor, 0, FLOOR_TILE_COORDS)
        if tile_map.get_cell_tile_data(1, corridor) != null:
            tile_map.erase_cell(1, corridor)
            
func corridors_to_floor(corridors: Array):
    var tile_size = $TileMap.tile_set.tile_size.x
    for corridor in corridors:
        var floor = FloorColor.new()
        floor.global_position = corridor.position * tile_size
        floor.size = corridor.size * tile_size
        floor.on_color = Color(1, 1, 1, 1)
        floor.off_color = ROOM_COLOR
        floor.z_index -= 1
        $Corridors.add_child(floor)
        

func remove_walls(corridors: Array[Rect2i]):
    var tile_map := $TileMap
    for corridor in corridors:
        for x in range(corridor.position.x, corridor.end.x):
            for y in range(corridor.position.y, corridor.end.y):
                tile_map.erase_cell(1, Vector2i(x, y))


func add_corridor_walls(corridors: Array[Rect2i]):
    var tile_map := $TileMap 
    for corridor in corridors:
        var corridor_copy = Rect2i(corridor)
        corridor_copy.position -= Vector2i(1, 1)
        corridor_copy.end += Vector2i(1, 1)
        var coords = generate_room_walls(corridor_copy)
        for coord in coords:
            tile_map.set_cell(1, coord, 0, WALL_TILE_COORDS)
        
        
#endregion


func get_spawn_room(rooms):
    # just chooses the center of a random room lol
    var spawn_room = rooms.pick_random()
    var center: Vector2 = calculate_room_center(spawn_room) * $TileMap.tile_set.tile_size.x
    return center


#region Functions to create ColorRects instead of tiles 
func corridors_to_rects(corridors: Array):
    var color_rect
    for corridor in corridors:
        color_rect = ColorRect.new()
        color_rect.global_position = corridor
        color_rect.size = Vector2(1, 1)
        color_rect.color = Color(1, 1, 1, 1)
        $Corridors.add_child(color_rect)


func rooms_to_rects(rooms: Array[Rect2i]):
    var color_rect
    for room in rooms:
        color_rect = ColorRect.new()
        color_rect.global_position = room.position
        color_rect.size = room.size
        color_rect.color = ROOM_COLOR
        $Rooms.add_child(color_rect)
#endregion
