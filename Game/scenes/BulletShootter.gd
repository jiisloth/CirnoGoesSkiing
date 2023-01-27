extends Node2D

export(PackedScene) var Bullet

var player_rotation = 0

var bullets = []
var dir = 0
var next = 0
var bullet_count = 0
var speed = 8

func _ready():
    rotation = TAU*randf()
    bullet_count = 4 + floor(abs(player_rotation)/PI)*4
    
func _process(delta):
    dir += delta*speed
    if dir > TAU:
        launch_bullets()
        queue_free()
    if dir > next:
        add_bullet(next)
        next += TAU/bullet_count
        if next >= TAU:
            next = INF

func add_bullet(d):
    var bullet = Bullet.instance()
    bullet.rotation = d + rotation
    bullet.position = Vector2(50,0).rotated(d+ rotation)
    bullets.append(bullet)
    get_parent().add_child(bullet)
    
func launch_bullets():
    for bullet in bullets:
        bullet.moving = true
