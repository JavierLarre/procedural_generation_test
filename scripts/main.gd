extends Node2D

func _ready():
    $UI/Button.pressed.connect(reiniciar)
    $Player.global_position = $Generator.spawn
    setup_floor_color()
    
        
func reiniciar():
    get_tree().reload_current_scene()
        
        
func setup_floor_color():
    for i in $Generator/Rooms.get_child_count():
        var floor_rect = $Generator/Rooms.get_child(i)
        floor_rect.Player = $Player
    for i in $Generator/Corridors.get_child_count():
        var floor_corr = $Generator/Corridors.get_child(i)
        floor_corr.Player = $Player
