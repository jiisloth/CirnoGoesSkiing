extends Node2D

export(PackedScene) var Bullet
export(PackedScene) var Baka

const displayname = "A Giant Snowball??" 

var pos = Vector2.ZERO
var screenSize = Vector2.ZERO
var middle = Vector2.ZERO
var velocity = Vector2.ZERO

var moveWay = 1
var xOffset = 0
var xOffsetMax
var xOffsetMin

var moving = false
var shooting = false
var starting = true
var phase2 = false
var past = false
var dying = false

var deltaTime = 0.0
var animeTime = 0.0
var movTime = 1
var shootPause = 1.0
var accSpeed = 1

var graze = true
var lift = 0

var health = 15
var maxhealth = 15
var phase = 1

var ready = false

enum {
    SNOWBALL,
    ICICLE,
    CRYSTAL
   }


var player

func _ready():
    player = get_tree().get_nodes_in_group("Player")[0]
    screenSize = get_viewport().get_visible_rect().size
    middle = screenSize / 2
    xOffsetMax = middle.x / 2
    xOffsetMin = -middle.x / 2
    position = get_start_pos()


func get_start_pos():
    var start_pos = Vector2.ZERO
    start_pos[0] = player.position.x
    start_pos[1] = player.position.y - middle.y - 250
    velocity = player.velocity
    return start_pos


func _process(delta):
    if health <= 0 and phase < 3:
        phase += 1
        if phase == 3:
            die()
        else:
            health = maxhealth
        
        
    var diff = player.position - position
    #NOT USED: var accModifier = (diff.y - 250) * 0.01

    if diff.y > 305 and starting:
        velocity.x = accSpeed * (diff.x + xOffset)
        velocity.y = diff.y * accSpeed * 0.05
        accSpeed += delta * 1.5
    elif starting:
        ready = true
        accSpeed = 5
        starting = false
        shooting = true
    
    if starting == false:
        if moving == false:
            xOffset += 2 * moveWay
            if xOffset > xOffsetMax and moveWay == 1:
                moveWay = -1
            elif xOffset < xOffsetMin and moveWay == -1:
                moveWay = 1
            velocity.x = accSpeed * (diff.x + xOffset)
            velocity.y = accSpeed * (diff.y - 250)
        else:
            velocity.y += 1

    if player.velocity.y < 50:
        velocity.y = 200
        shooting = false
        moving = true
        $OverTimer.start(10)

    if dying:
        velocity.x = 0
        velocity.y = 0
    position += velocity * delta
    deltaTime += delta
    animeTime += delta * velocity.y * 0.04
    $Sprite.frame = int(animeTime)%8
    $Sprite.position.y = min($Sprite.position.y + lift*3*delta, -38)
    lift += 1

    if deltaTime > shootPause and shooting == true:
        var num = randi()%5
        if phase == 1:
            bullet_phase1(num)
            deltaTime = 0.0
        else:
            bullet_phase2(num)
            deltaTime = 0.0
    if health > 1:
        health -= delta*0.1


func create_bullet(d, speed, btype):
    var bullet = Bullet.instance()
    bullet.speed = abs(player.movespeed) + speed
    bullet.rotation = rotation + deg2rad(d)
    bullet.position = position
    bullet.btype = btype
    get_parent().add_child(bullet)
    

func bullet_phase1(num):
    if num != 4:
        create_bullet(90, 200, SNOWBALL)
        create_bullet(135, 200, SNOWBALL)
        create_bullet(45, 200, SNOWBALL)
    else:
        create_bullet(90, 200, ICICLE)
        create_bullet(90, 250, ICICLE)
        create_bullet(90, 300, ICICLE)
    
func bullet_phase2(num):
    if num != 4:
        create_bullet(90, 150, SNOWBALL)
        create_bullet(90-22.5, 150, SNOWBALL)
        create_bullet(45, 150, SNOWBALL)
        create_bullet(112.5, 150, SNOWBALL)
        create_bullet(135, 150, SNOWBALL)
    else:
        create_bullet(90, 200, ICICLE)
        create_bullet(135, 200, ICICLE)
        create_bullet(45, 200, ICICLE)
        create_bullet(90, 400, ICICLE)
        create_bullet(135, 400, ICICLE)
        create_bullet(45, 400, ICICLE)
        create_bullet(90, 300, ICICLE)
        create_bullet(135, 300, ICICLE)
        create_bullet(45, 300, ICICLE)
 
       
func boss_hit(dmg):
    health -= dmg
    if health > 0:
        lift = -40
        
   
func die():
    var baka = Baka.instance()
    baka.global_position = global_position
    get_parent().add_child(baka)
    get_parent().boss_died(E.SNOWBALL)
    for i in range(5, 360, 5):
        create_bullet(deg2rad(i), 150, SNOWBALL)
    queue_free()


func _on_Area2D_body_entered(body):
    if body.name == "Player":
        if body.height < 70:
            graze = false
            body.hit(1, false, 0.3)


func _on_OverTimer_timeout():
    position = get_start_pos()
    velocity = player.velocity
    starting = true
    moving = false
