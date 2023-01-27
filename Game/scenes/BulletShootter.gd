extends Node2D

export(PackedScene) var Bullet

var player_rotation = 0

var bullets = []
var dir = 0
var next = 0
var bullet_count = 0
var speed = 8

var rot_dir = 1

func _ready():
    bullet_count = 4 + floor(abs(player_rotation)/PI)*4
    if player_rotation < 0:
        rot_dir =- 1
    
func _process(delta):
    dir += delta*speed
    if abs(dir) > TAU:
        launch_bullets()
        call_deferred("queue_free")
    if dir > next:
        add_bullet(next)
        next += TAU/bullet_count
        if next >= TAU:
            next = INF

func add_bullet(d):
    d = d*rot_dir
    var bullet = Bullet.instance()
    bullet.rotation = d + rotation
    bullet.offset = Vector2(50,0).rotated(d+ rotation)
    bullet.global_position = get_parent().global_position + bullet.offset
    bullet.player = get_parent()
    bullets.append(bullet)
    get_parent().get_parent().add_child(bullet)
    
func launch_bullets():
    for bullet in bullets:
        bullet.movement = get_parent().velocity
        bullet.moving = true
