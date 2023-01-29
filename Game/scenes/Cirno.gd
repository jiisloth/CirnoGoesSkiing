extends Node2D

export(PackedScene) var Bullet

onready var player := get_tree().get_root().get_node("World/Player")

var health = 220
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


func _process(delta):
    #set shadow and collision
    if $AnimatedSprite.frame < 5:
        $CollisionShape2D.position.x = -4.5
        $CirnoShadow.position.x = -18
    else:
        $CirnoShadow.position.x = -9
        $CollisionShape2D.position.x = 4.5
        
    
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
    health -= 10 * delta


func get_pos():
    position.x += moveSpeed * moveWay
    if diff.x > xOffsetMax:
        moveWay = -1
    elif diff.x < xOffsetMin:
        moveWay = 1 

func phase2(delta):
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
