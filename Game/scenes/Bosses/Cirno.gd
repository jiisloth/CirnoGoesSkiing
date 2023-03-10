extends Node2D

export(PackedScene) var Bullet
export(PackedScene) var Baka
export(PackedScene) var Laser

const displayname = "Cirno" 

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
var phasepos = 0
var newPos = Vector2()
var circling = false
var flashes = 3
var starting = true

var phase = 1
var ready = false
var health = 20
var maxhealth = 20

var player

func _ready():
    player = get_tree().get_nodes_in_group("Player")[0]
    playerPos = player.position
    screenSize = get_viewport().get_visible_rect().size
    middle = screenSize / 2
    xOffsetMax = middle.x / 2
    xOffsetMin = -middle.x / 2
    upperMiddle = playerPos
    upperMiddle.x = playerPos.x - 700
    upperMiddle.y = middle.y - 250
    position = upperMiddle
    $StartTimer.start(13)
    $Area2D/CollisionShape2D.disabled = true
    

func _process(delta):
    if health <= 0 and phase < 5:
        phase += 1
        if phase == 5:
            die()
        else:
            health = maxhealth
        
    get_player_pos()
    if starting:
        if abs(position.x - playerPos.x) > 50 and abs(position.y - playerPos.y - 250) > 50:
            position.x += moveSpeed
            position.y = playerPos.y - 250
            moveSpeed += moveSpeed * delta
        else:
            starting = false
            ready = true
    #set shadow and collision
    if $AnimatedSprite.frame < 5:
        $Area2D/CollisionShape2D.position.x = -4.5
        $CirnoShadow.position.x = -18
    else:
        $CirnoShadow.position.x = -9
        $Area2D/CollisionShape2D.position.x = 4.5

    if !starting:
        match phase:
            1:
                get_pos(delta)
            2:
                phase2(delta)   
            3:
                phase3(delta)
            4:
                phase4(delta)

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
    newPos = Vector2(0, 30*sin(phasepos))
    get_pos(delta)
    position += newPos
    phasepos += 10 * delta
    
func phase3(delta):
    if circling == false:
        if abs(position.x - playerPos.x) > 20 and abs(position.y - playerPos.y - 250) > 50:
            move_to_upper_middle(delta, 10)
        elif position != upperMiddle:
            circling = true
            phasepos = deg2rad(180)
    else:
        phasepos += delta
        newPos = Vector2(sin(phasepos) * 300, cos(phasepos) * 300) + playerPos
        position = newPos


func phase4(delta):
    if abs(position.x - playerPos.x) > 100 and abs(position.y - playerPos.y - 250) > 100:
        move_to_upper_middle(delta, 5)
        $ShootTimer.stop()
        $ShootTimer2.stop()
    elif $ShootTimer.time_left == 0.0:
        $ShootTimer.start(3)
        $ShootTimer2.start(7)
    else:
        move_to_upper_middle(delta, 2)
        position.x = clamp(position.x, playerPos.x - 75, playerPos.x + 75)
        position.y = clamp(position.y, playerPos.y - 225, playerPos.y - 275)
        
        
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
    get_parent().boss_died(E.CIRNO)
    queue_free()
    

func shoot(d, speed, rot, t):
    var bullet = Bullet.instance()
    bullet.speed = speed
    bullet.movement = Vector2(50, 50)
    bullet.rotation = d
    bullet.damage = 3 + t
    bullet.rotatespeed = rot
    bullet.position = position
    bullet.btype = t
    get_parent().add_child(bullet)


func _on_ShootTimer_timeout():
    var angleToMid = playerPos.angle_to_point(position)
    match phase:
        1:
            for i in range(0, 200, 20):
                shoot(deg2rad(i), playerSpeed+200, 0, 0)
            $ShootTimer.start(rand_range(2.5, 3.5))
        2:
            for i in range(-30, 31, 5):
                shoot(angleToMid + deg2rad(i), playerSpeed+250, 0, 0)
                $ShootTimer.start(4)
        3:
            shoot(angleToMid, 400, 0, 2)
            shoot(angleToMid+0.5, playerSpeed+400, 0, 2)
            shoot(angleToMid-0.5, playerSpeed+400, 0, 2)
            $ShootTimer.start(rand_range(0.5, 1.0))
        4:
            for i in range(-90, 100, 5):
                shoot(angleToMid + deg2rad(i), playerSpeed+300, 0, 2)
                $ShootTimer.start(rand_range(1.5, 2.0))
    
func shoot_laser(d,rs, dur, dmg):
    var laser = Laser.instance()
    laser.rotatespeed = rs
    laser.offset = 50
    laser.rotation = d
    laser.duration = dur
    laser.damage = dmg
    add_child(laser)

func _on_ShootTimer2_timeout():
    var angleToMid = playerPos.angle_to_point(position)
    match phase:
        1:
            shoot(angleToMid + deg2rad(rand_range(-10, 10)), playerSpeed+300, 0, 2)
            $ShootTimer2.start(1.0)
        2:
            for _i in range(0, 3):
                shoot(angleToMid + deg2rad(rand_range(-10, 10)), playerSpeed+300, 0, 2)
            $ShootTimer2.start(1.0)
        3:
            shoot(angleToMid, playerSpeed+250, deg2rad(45), 0)
            shoot(angleToMid, playerSpeed+250, deg2rad(-45), 0)
            shoot(angleToMid, playerSpeed+250, deg2rad(90), 0)
            shoot(angleToMid, playerSpeed+250, deg2rad(-90), 0)
            $ShootTimer2.start(3)
        4:
            for _i in range(0, 1000, 50):
                shoot_laser(deg2rad(90), 0, 1.5, 5)
            if health < maxhealth*0.15:
                shoot_laser(deg2rad(120) + deg2rad(45), -deg2rad(90), 1.5, 5)
                shoot_laser(deg2rad(60) - deg2rad(45), deg2rad(90), 1.5, 5)
            $ShootTimer2.start(7)


func boss_hit(dmg):
    health -= dmg
    if health > 0:
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


func _on_StartTimer_timeout():
    $Area2D/CollisionShape2D.disabled = false
    $ShootTimer.start(2)
    $ShootTimer2.start(3)
