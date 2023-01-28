extends Node2D

export(PackedScene) var Bullet

onready var player := get_tree().get_root().get_node("World/Player")

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

var deltaTime = 0.0
var animeTime = 0.0
var bossHealth = 100
var movTime = 1
var shootPause = 1.0
var accSpeed = 1

var graze = true

enum {
    SNOWBALL,
    ICICLE,
    CRYSTAL
   }


# Called when the node enters the scene tree for the first time.
func _ready():
    #hide()
    screenSize = get_viewport().get_visible_rect().size
    middle = screenSize / 2
    xOffsetMax = middle.x / 2
    xOffsetMin = -middle.x / 2
    position = get_start_pos()


func get_start_pos():
    var start_pos = Vector2.ZERO
    start_pos[0] = player.position.x
    start_pos[1] = player.position.y - middle.y - 300
    velocity = player.velocity
    return start_pos


func _process(delta):
    
    var diff = player.position - position
    var accModifier = (diff.y - 250) * 0.01

    if diff.y > 305 and starting:
        velocity.x = accSpeed * (diff.x + xOffset)
        if (accSpeed) * (diff.y - 250) > velocity.y:
            velocity.y += delta * diff.y * 0.05
        accSpeed += delta
    elif starting:
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
            if diff.y < -900:
                position = get_start_pos()
                velocity = player.velocity
                starting = true
                moving = false

    if player.velocity.y < 50:
        velocity.y = 200
        shooting = false
        moving = true

    position += velocity * delta
    deltaTime += delta
    animeTime += delta * velocity.y * 0.04
    $Sprite.frame = int(animeTime)%8
    
    if deltaTime > shootPause and shooting == true:
        var num = randi()%5
        if bossHealth > 50:
            bullet_phase1(num)
            deltaTime = 0.0
        else:
            bullet_phase2(num)
            deltaTime = 0.0
        bossHealth -= 1


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
        create_bullet(90, 150, ICICLE)
        create_bullet(90, 200, ICICLE)
        create_bullet(90, 250, ICICLE)
        create_bullet(90, 300, ICICLE)
        create_bullet(90, 350, ICICLE)
    
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
    print("Boss hit for ", dmg)
    bossHealth -= dmg
    if bossHealth <= 0:
        die()
    else:
        var tween = Tween.new()
        add_child(tween)
        tween.interpolate_property($Sprite, "position:y", -38, -100, 0.1, Tween.TRANS_LINEAR, Tween.EASE_OUT)
        tween.start()
        yield(get_tree().create_timer(0.1), "timeout")
        tween.interpolate_property($Sprite, "position:y", -100, -38, 0.1, Tween.TRANS_LINEAR, Tween.EASE_IN)
        tween.start()
        yield(get_tree().create_timer(0.2), "timeout")
        tween.queue_free()
        
   
func die():
    queue_free()



func _on_Area2D_body_entered(body):
    if body.name == "Player":
        if body.height < 70:
            graze = false
            body.hit(1, false, 0.3)

