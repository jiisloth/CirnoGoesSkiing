extends Node2D

export(PackedScene) var Bullet

var player_rotation = 0

var bullets = []
var dir = 0
var next = 0
var bullet_count = 0
var speed = 6

var rot_dir = 1

var tricks = []
var trick_total = 0

var launch = Vector3.ZERO
var fly = Vector3.ZERO
var hit = Vector3.ZERO
var total = Vector3.ZERO

var color = Color(1,1,1)
 

func _ready():
    bullet_count = 4 + floor(abs(player_rotation)/PI)*4
    if player_rotation < 0:
        rot_dir =- 1
    if len(tricks) == 0:
        queue_free()
        return
    var pointer = 0
    for trick in tricks:
        if pointer < 0.3333*trick_total:
            var to_point = 0.3333*trick_total-pointer
            if trick.y > to_point:
                launch[trick.x-1] += to_point
                var extra = trick.y - to_point
                to_point = 0.6667*trick_total - 0.3333*trick_total
                if extra > to_point:
                    fly[trick.x-1] += to_point
                    extra = extra - to_point
                    hit[trick.x-1] += extra
                else:
                    fly[trick.x-1] += extra
                    
            else:
                launch[trick.x-1] += trick.y
        elif pointer < 0.6667*trick_total:
            var to_point = 0.6667*trick_total-pointer
            if trick.y > to_point:
                fly[trick.x-1] += to_point
                var extra = trick.y - to_point
                hit[trick.x-1] += extra
            else:   
                fly[trick.x-1] += trick.y
        else:
            hit[trick.x-1] += trick.y
        total[trick.x-1] += trick.y
        pointer += trick.y
    var c = total.normalized()
    color = color.linear_interpolate(Color("#c63d42"),c.x).linear_interpolate(Color("#a2e387"),c.y).linear_interpolate(Color("#62abd2"),c.z)
    launch = scale_property(launch)/(2/3.0)
    fly = scale_property(fly)/(2/3.0)
    hit = scale_property(hit)/(2/3.0)
        
func scale_property(prop):
    var ptotal = prop.x + prop.y + prop.z
    if ptotal > 2/3.0:
        var pscale = (2/3.0)/ptotal
        prop = prop*pscale
    return prop
        
func _process(delta):
    dir += delta*(speed + launch.z*6)
    if abs(dir) > TAU:
        launch_bullets()
    if abs(dir) > TAU*2:
        call_deferred("queue_free")
    if dir > next:
        add_bullet(next)
        next += TAU/bullet_count
        if next >= TAU:
            next = INF

func add_bullet(d):
    d = d*rot_dir
    var bullet = Bullet.instance()
    bullet.rotation = (d + rotation)
    bullet.offset = Vector2(50,0).rotated(d+ rotation)
    bullet.global_position = get_parent().global_position + Vector2(50,0).rotated(d+ rotation)
    bullet.modulate = color
    bullet.speed = 400 + 400*fly.z
    bullet.damage = 1 + hit.z*3 + trick_total*0.1
    bullet.wave = fly.y
    bullet.health = hit.y * 10.0
    bullet.track = fly.x
    bullet.hb_scale = 1 + 3*hit.x
    bullet.player = get_parent()
    bullets.append(bullet)
    get_parent().get_parent().add_child(bullet)
    
func launch_bullets():
    for bullet in bullets:
        if is_instance_valid(bullet):
            bullet.movement = get_parent().velocity
            bullet.moving = true
    bullets = []
