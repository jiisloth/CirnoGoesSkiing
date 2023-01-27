extends KinematicBody2D


var speed = 500
var moving = false
var offset = Vector2()
var player
var movement = Vector2()
var damage = 1
var wave = 0
var yspeed = 0
var age = 0

func _physics_process(delta):
    age += delta
    yspeed = cos(age*40+wave*10)
    $Sprite.position = Vector2.UP.rotated(-rotation)*20
    if moving:
        move_and_collide((movement + Vector2(speed,yspeed*wave*500).rotated(rotation))*delta)
    else:
        global_position = player.global_position + offset
