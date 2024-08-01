extends CharacterBody2D

@export var health = 100.0
const SPEED = 800.0


func _physics_process(_delta):
        var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
        velocity = direction * SPEED
        move_and_slide()
        if velocity.length() > 0.0:
                $HappyBoo.play_walk_animation()
        else:
                $HappyBoo.play_idle_animation()
