extends Node2D

export(PackedScene) var Bullet
export(PackedScene) var Baka

onready var player := get_tree().get_root().get_node("World/Player")

var maxHealth = 50
var health = 50
var deltaTime = 0.0
var tpTime = 0.0

var screenSize
var middle
var upperMiddle
var xOffsetMax
var xOffsetMin
var playerPos
var playerSpeed

var moveWay = 1
var moveSpeed = 3
var diff
var phase = 0
var newPos = Vector2()
var circling = false
var flashes = 3


func _ready():
    print("CirnoSpawn")
    playerPos = player.position
    screenSize = get_viewport().get_visible_rect().size
    middle = screenSize / 2
    xOffsetMax = middle.x / 2
    xOffsetMin = -middle.x / 2
    upperMiddle = playerPos
    upperMiddle.y = middle.y - 300
    position = upperMiddle
    $ShootTimer.start(1)


func _process(delta):
    get_player_pos()
    #set shadow and collision
    if $AnimatedSprite.frame < 5:
        $Area2D/CollisionShape2D.position.x = -4.5
        $CirnoShadow.position.x = -18
    else:
        $CirnoShadow.position.x = -9
        $Area2D/CollisionShape2D.position.x = 4.5
    print(health)
    if health > maxHealth * 0.75:
        print("phase1")
        get_pos(delta)
    elif health > maxHealth/2:
        print("phase2")
        phase2(delta)   
    elif health > maxHealth * 0.25:
        print("phase3")
        phase3(delta)
    elif health > 0:
        print("phase4")
        phase4(delta)   
    else:
        die()

    deltaTime += delta


func get_player_pos():
    playerPos = player.position
    playerSpeed = abs(player.movespeed)
    diff = playerPos - position

func get_pos(delta):
    position.y = player.position.y - 250
    position.x += moveSpeed * moveWay
    if player.velocity.x > 100 and moveWay == 1:
        moveSpeed += 1 * delta
    elif player.velocity.x < -100 and moveWay == -1:
        moveSpeed += 1 * delta
    else:
        moveSpeed = 3
    moveSpeed = clamp(moveSpeed, 3, 8)
    if diff.x > xOffsetMax:
        moveWay = 1
        position.x += diff.x * 0.005 * moveWay
    elif diff.x < xOffsetMin:
        moveWay = -1
        position.x -= diff.x * 0.005 * moveWay

func phase2(delta):
    if $ShootTimer2.time_left == 0:
        $ShootTimer2.start(1)
    newPos = Vector2(0, 30*sin(phase))
    get_pos(delta)
    position += newPos
    phase += 10 * delta
    
func phase3(delta):
    if circling == false:
        if abs(position.x - playerPos.x) > 20 and abs(position.y - playerPos.y - 250) > 50:
            move_to_upper_middle(delta, 10)
        elif position != upperMiddle:
            circling = true
            phase = deg2rad(180)
    else:
        phase += delta
        newPos = Vector2(sin(phase) * 300, cos(phase) * 300) + playerPos
        position = newPos


func phase4(delta):
    if abs(position.x - playerPos.x) > 100 and abs(position.y - playerPos.y - 250) > 100:
        move_to_upper_middle(delta, 0.1)
        $ShootTimer.stop()
        $ShootTimer2.stop()
    elif $ShootTimer.time_left == 0.0:
        $ShootTimer.start(2)
        $ShootTimer2.start(5)
    else:
        var speedMod = abs((diff.y+250) * 0.1)
        move_to_upper_middle(delta, speedMod)
        
        
func move_to_upper_middle(delta, speed):
    var wantedPos = playerPos
    wantedPos.y -= 250
    if position != wantedPos:
        position.x += (wantedPos.x - position.x) * delta * speed
        position.y += (wantedPos.y - position.y) * delta * speed

func die():
    $ShootTimer.stop()
    $ShootTimer2.stop()
    var baka = Baka.instance()
    baka.global_position = global_position
    get_parent().add_child(baka)
    get_parent().boss_died("snowball")
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
    var angleToMid = playerPos.angle_to_point(position)
    if health > maxHealth * 0.75:
        for i in range(0, 200, 20):
            shoot(deg2rad(i), playerSpeed+200, 0, 0)
        $ShootTimer.start(3)
    elif health > maxHealth/2:
        for i in range(-30, 31, 5):
            shoot(angleToMid + deg2rad(i), playerSpeed+250, 0, 0)
            $ShootTimer.start(3)
    elif health > maxHealth * 0.75:
        shoot(angleToMid, 400, 0, 2)
        shoot(angleToMid+0.5, playerSpeed+400, 0, 2)
        shoot(angleToMid-0.5, playerSpeed+400, 0, 2)
        $ShootTimer.start(rand_range(0.5, 1.0))
    elif health > 0:
        for i in range(-90, 100, 5):
            shoot(angleToMid + deg2rad(i), playerSpeed+300, 0, 2)
            $ShootTimer.start(rand_range(1, 2))
    

func _on_ShootTimer2_timeout():
    var angleToMid = playerPos.angle_to_point(position)
    if health > maxHealth * 0.75:
        shoot(angleToMid + deg2rad(rand_range(-10, 10)), playerSpeed+300, 0, 1)
        $ShootTimer2.start(0.5)
    elif health > maxHealth / 2:
        shoot(angleToMid, playerSpeed+250, deg2rad(45), 0)
        shoot(angleToMid, playerSpeed+250, deg2rad(-45), 0)
        $ShootTimer2.start(3)
    elif health > maxHealth * 0.25:
        for i in range(0, 1000, 50):
            shoot(angleToMid, playerSpeed+300 + i, 0, 1)
        if health < maxHealth*0.1:
            for i in range(0, 1000, 50):
                shoot(angleToMid-deg2rad(-45), playerSpeed+300+i, 0, 1)
                shoot(deg2rad(45), playerSpeed+300+i, 0, 1)

func boss_hit(dmg):
    health -= dmg
    print(health)
    if health <= 0:
        die()
    else:
        $FlashTimer.start(0.1)
        

func _on_FlashTimer_timeout():
    if flashes > 0:
        if flashes % 2 == 1:
            $AnimatedSprite.hide()
        else:
            $AnimatedSprite.show()
        $FlashTimer.start(0.1)
        flashes -= 1
    else:
        $AnimatedSprite.show()
        flashes = 3
