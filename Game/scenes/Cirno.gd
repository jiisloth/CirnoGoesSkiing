extends Node2D

export(PackedScene) var Bullet

onready var player := get_tree().get_root().get_node("World/Player")

var health = 250
var deltaTime = 0.0
var tpTime = 0.0

var screenSize
var middle
var upperMiddle
var xOffsetMax
var xOffsetMin

var moveWay = 1
var moveSpeed = 3
var diff
var phase = 0
var newPos = Vector2()
var circling = false

var phase1 = false
var phase2 = false
var phase3 = false
var phase4 = false

func _ready():
    screenSize = get_viewport().get_visible_rect().size
    middle = screenSize / 2
    xOffsetMax = middle.x / 2
    xOffsetMin = -middle.x / 2
    upperMiddle = screenSize / 2
    upperMiddle.y = middle.y - 300
    position = upperMiddle
    $ShootTimer.start(5)


func _process(delta):
    diff = position - middle
    if health > 300:
        get_pos()
    elif health > 200:
        phase2(delta)   
    elif health > 100:
        phase3(delta)
    elif health > 0:
        pass      
    else:
        die()

    deltaTime += delta
    health -= 1 * delta


func get_pos():
    position.x += moveSpeed * moveWay
    if diff.x > xOffsetMax:
        moveWay = -1
    elif diff.x < xOffsetMin:
        moveWay = 1 

func phase2(delta):
    if $ShootTimer2.time_left == 0:
        $ShootTimer2.start(1)
    newPos = Vector2(position.x + moveSpeed * moveWay, middle.y - 250 + 30*sin(phase))
    get_pos()
    position = newPos
    phase += 10 * delta
    
func phase3(delta):
    if circling == false:
        if abs(position.x - upperMiddle.x) < 15 and abs(position.y -upperMiddle.y) < 10:
            circling = true
            phase = deg2rad(180)
        elif position != upperMiddle:
            var movTween = Tween.new()
            add_child(movTween)
            movTween.interpolate_property(self, "position", position, upperMiddle, 1, Tween.TRANS_LINEAR, Tween.EASE_IN)
            movTween.start()
    else:
        phase += delta
        newPos = Vector2(sin(phase) * 300, cos(phase) * 300) + middle
        position = newPos

func die():
    queue_free()
    

func shoot(d, speed, rot, t):
    var bullet = Bullet.instance()
    bullet.speed = speed
    bullet.movement = Vector2(50, 50)
    bullet.rotation = d
    bullet.rotatespeed = rot
    bullet.position = position
    bullet.btype = t
    get_parent().add_child(bullet)


func _on_ShootTimer_timeout():
    var angleToMid = middle.angle_to_point(position)
    if health > 300:
        for i in range(0, 200, 20):
            shoot(deg2rad(i), 100, 0, 0)
        $ShootTimer.start(3)
    elif health > 200:
        for i in range(-20, 21, 5):
            shoot(angleToMid - deg2rad(i), 150, 0, 0)
            $ShootTimer.start(2)
    elif health > 100:
        shoot(angleToMid, 300, 0, 2)
        shoot(angleToMid+0.5, 300, 0, 2)
        shoot(angleToMid-0.5, 300, 0, 2)
        $ShootTimer.start(rand_range(0.5, 1.0))
    elif health > 0:
        pass
    

func _on_ShootTimer2_timeout():
    if health > 200:
        pass
    elif health > 100:
        pass
    elif health > 0:
        pass
