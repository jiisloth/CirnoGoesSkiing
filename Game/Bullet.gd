extends KinematicBody2D


var speed = 50
var moving = false

func _physics_process(delta):
    if moving:
        move_and_collide(Vector2(speed*delta,0).rotated(rotation))
