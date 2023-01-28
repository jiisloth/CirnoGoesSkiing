extends Node2D

export(PackedScene) var Bullet

onready var player := get_tree().get_root().get_node("World").get_node("Player")

var pos = Vector2.ZERO
var screenSize = Vector2.ZERO
var middle = Vector2.ZERO

var moveWay = 1
var xOffset = 0
var xOffsetMax
var xOffsetMin

var moving = true
var shooting = false
var starting = true
var phase2 = false

var deltaTime = 0.0
var bossHealth = 100
var movTime = 1
var shootPause = 1.0

# Called when the node enters the scene tree for the first time.
func _ready():
    #hide()
    screenSize = get_viewport().get_visible_rect().size
    middle = screenSize / 2
    xOffsetMax = middle.x
    xOffsetMin = -middle.x
    self.position = get_start_pos()


func get_start_pos():
    var start_pos = Vector2.ZERO
    start_pos[0] = player.position.x
    start_pos[1] = player.position.y - middle.y - 200
    print(start_pos)
    return start_pos


func _process(delta):
    
    if player.position.y - self.position.y > 300 and starting:
        self.position.y += 100 * delta
    elif starting:
        self.position.y = player.position.y - 300
        starting = false
        shooting = true
    
    if starting == false:
        self.position.y = player.position.y - 300
        self.position.x = player.position.x + xOffset + moveWay
        xOffset += 2 * moveWay
        if xOffset > xOffsetMax and moveWay == 1:
            moveWay = -1
        elif xOffset < xOffsetMin and moveWay == -1:
            moveWay = 1

    $Sprite.rotation -= 1 * delta
    deltaTime += delta
    
    if deltaTime > shootPause and shooting == true:
        var num = randi()%5
        if bossHealth > 50:
            bullet_phase1(num)
            deltaTime = 0.0
        else:
            bullet_phase2(num)
            deltaTime = 0.0
        bossHealth -= 1


func create_bullet(d, speed, type):
    var bullet = Bullet.instance()
    bullet.speed = abs(player.movespeed) + speed
    bullet.scale *= 2
    bullet.rotation = self.rotation + deg2rad(d)
    bullet.position = self.position
    if type == 1:
        bullet.texType = type
    if type == 2:
        bullet.texType = type
    get_parent().add_child(bullet)
    bullet.moving = true
    

func bullet_phase1(num):
    if num != 4:
        create_bullet(90, 200, 1)
        create_bullet(135, 200, 1)
        create_bullet(45, 200, 1)
    else:
        create_bullet(90, 150, 2)
        create_bullet(90, 200, 2)
        create_bullet(90, 250, 2)
        create_bullet(90, 300, 2)
        create_bullet(90, 350, 2)
    
func bullet_phase2(num):
    if num != 4:
        create_bullet(90, 150, 1)
        create_bullet(90-22.5, 150, 1)
        create_bullet(45, 150, 1)
        create_bullet(112.5, 150, 1)
        create_bullet(135, 150, 1)
    else:
        create_bullet(90, 200, 2)
        create_bullet(135, 200, 2)
        create_bullet(45, 200, 2)
        create_bullet(90, 400, 2)
        create_bullet(135, 400, 2)
        create_bullet(45, 400, 2)
        create_bullet(90, 300, 2)
        create_bullet(135, 300, 2)
        create_bullet(45, 300, 2)
        
func boss_hit(dmg):
    print("Boss hit for ", dmg)
    bossHealth -= dmg
    if bossHealth <= 0:
        die()
        
func die():
    queue_free()
