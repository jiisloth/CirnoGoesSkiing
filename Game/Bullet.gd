extends KinematicBody2D


var speed = 500
var moving = false
var offset = Vector2()
var player
var movement = Vector2()


func _physics_process(delta):
    $Sprite.position = Vector2.UP.rotated(-rotation)*20
    if moving:
        move_and_collide((movement + Vector2(speed,0).rotated(rotation))*delta)
    else:
        global_position = player.global_position + offset
