class_name FloorColor

extends ColorRect

var Player: CharacterBody2D
var off_color: Color
var on_color: Color

# Called when the node enters the scene tree for the first time.
func _ready():
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    pass
    
    
func _physics_process(delta):
    var player_position = Player.global_position
    var in_rect_x = (
            global_position.x <= player_position.x
            and player_position.x <= (global_position.x + size.x)
            )
    var in_rect_y = (
            global_position.y <= player_position.y
            and player_position.y <= (global_position.y + size.y)
            )
    var in_rect = in_rect_x and in_rect_y
    if in_rect:
        color = on_color
    else:
        color = off_color
