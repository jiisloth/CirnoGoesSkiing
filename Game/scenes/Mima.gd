extends Node2D


export(PackedScene) var Bullet
export(PackedScene) var Laser

var deltatime = 0

var rng = RandomNumberGenerator.new()

var phase = 0
var health = 12
var phasephase = 0


var player

func _ready():
    player = get_tree().get_nodes_in_group("Player")[0]
    rng.randomize()
    spawn()
    

func _process(delta):
    deltatime += delta
    $Sprites/Tail.frame = int(deltatime*10)%5
    $Sprites/Body.frame = int(deltatime)%2
    position += delta*player.velocity * 0.85
    $Sprites.position.y = -43 + cos(deltatime)*3
    if not $Area2D/CollisionShape2D.disabled and (player.global_position-global_position).length() > 600:
        if $Lasers.get_child_count() == 0:
            teleport()
    if health <= 0:
        phase += 1
        health = 12 + 2*phase
        if phase == 4:
            teleport()


func _on_Timer_timeout():
    teleport()
    
func teleport():
    $TP.stop()
    $Sprites/Tail.hide()
    $Sprites/Body.hide()
    $Sprites/Teleport1.show()
    $Sprites/Teleport2.show()
    $Area2D/CollisionShape2D.disabled = true
    $Teleport.interpolate_property($Sprites/Teleport1, "scale:y", 1, 3, 0.15)
    $Teleport.interpolate_property($Sprites/Teleport2, "scale:y", 1, 3, 0.15)
    $Teleport.interpolate_property($Sprites/Teleport1, "position:y", -10, -10+10, 0.15)
    $Teleport.interpolate_property($Sprites/Teleport2, "position:y", -10, -10-23*2-10, 0.15)
    $Teleport.start()
    yield(get_tree().create_timer(0.15), "timeout")
    if phase == 4:
        get_parent().boss_died("mima")
        queue_free()
    spawn()
    
func spawn():
    global_position = player.global_position + Vector2(200 + rng.randf()*200,0).rotated(TAU*rng.randf())
    $Teleport.interpolate_property($Sprites/Teleport1, "scale:y", 3,1, 0.15)
    $Teleport.interpolate_property($Sprites/Teleport2, "scale:y", 3,1, 0.15)
    $Teleport.interpolate_property($Sprites/Teleport1, "position:y", -10+10,-10, 0.15)
    $Teleport.interpolate_property($Sprites/Teleport2, "position:y", -10-23*2-10,-10, 0.15)
    yield(get_tree().create_timer(0.15), "timeout")
    $Area2D/CollisionShape2D.disabled = false
    $Sprites/Tail.show()
    $Sprites/Body.show()
    $Sprites/Teleport1.hide()
    $Sprites/Teleport2.hide()
    $TP.start(4+rng.randf()*4)
    


func _on_Area2D_area_entered(area):
    if area.is_in_group("Obstacle"):
        teleport()
        
func shoot(d, speed, rot_speed, t):
    var bullet = Bullet.instance()
    bullet.speed = speed
    bullet.movement = player.velocity
    bullet.rotation = d
    bullet.rotatespeed = rot_speed
    bullet.position = position
    bullet.btype = t
    get_parent().add_child(bullet)


func shoot_laser(d,rs, dur, dmg):
    var laser = Laser.instance()
    laser.rotatespeed = rs
    laser.offset = 50
    laser.rotation = d
    laser.duration = dur
    laser.damage = dmg
    laser.modulate = Color("#a2e387") #NOT NEEDED
    $Lasers.add_child(laser)
    
    if $TP.time_left < dur+1 and $TP.time_left != 0:
        $TP.start(dur+1+rng.randf()*4)
    

func _on_Shoot_timeout():
    if not $Area2D/CollisionShape2D.disabled:
        var dif = (player.global_position-global_position)
        match phase:
            0:
                for i in 5:
                    shoot(dif.angle()+PI/2+i*PI/5, 150, -PI/2.0*(1+i/2.0), 3)
                    shoot(dif.angle()-PI/2-i*PI/5, 150, PI/2.0*(1+i/2.0), 3)
            1:  
                if phasephase == 0:
                    shoot_laser(dif.angle()+PI, 2, 3, 3) 
                    phasephase = 1
                else:
                    for i in 6:
                        shoot(dif.angle()+PI/2-i*PI/5, 200, -PI/2.0*(1+i/2.0), 3)
                        shoot(dif.angle()-PI/2+i*PI/5, 200, PI/2.0*(1+i/2.0), 3)
                    phasephase = 0
            2:
                phasephase = randi()%2
                if phasephase == 0:
                    for i in 5:
                        shoot(dif.angle()+PI/2+(1+i)*PI/5, 200 - 50*i%2, -PI/2.0*(1+i/2.0), 3)
                        shoot(dif.angle()-PI/2-(1+i)*PI/5, 200 - 50*i%2, PI/2.0*(1+i/2.0), 3)
                        shoot(dif.angle()+PI/2+i*PI/5, 200 - 50*i%2, -PI/2.0*(1+i/2.0), 3)
                        shoot(dif.angle()-PI/2-i*PI/5, 200 - 50*i%2, PI/2.0*(1+i/2.0), 3)
                else:
                    shoot_laser(dif.angle()+PI, 2, 3, 3) 
                    shoot_laser(dif.angle()+PI, -2, 3, 3) 
            3:
                phasephase = randi()%3
                if phasephase == 0:
                    for i in 5:
                        shoot(dif.angle()+PI/2+(1+i)*PI/5, 200 - 50*i%2, -PI/2.0*(1+i/2.0), 3)
                        shoot(dif.angle()-PI/2-(1+i)*PI/5, 200 - 50*i%2, PI/2.0*(1+i/2.0), 3)
                        shoot(dif.angle()+PI/2+i*PI/5, 200 - 50*i%2, -PI/2.0*(1+i/2.0), 3)
                        shoot(dif.angle()-PI/2-i*PI/5, 200 - 50*i%2, PI/2.0*(1+i/2.0), 3)
                elif phasephase == 1:
                    for i in 4:
                        shoot(dif.angle()+PI/2-i*PI/5, 200, -PI/2.0*(1+i/2.0), 3)
                        shoot(dif.angle()-PI/2+i*PI/5, 200, PI/2.0*(1+i/2.0), 3)
                    shoot_laser(dif.angle()+PI, 1.5, 4, 3) 
                    shoot_laser(dif.angle()+PI, -2.5, 2.5, 3) 
                else:
                    shoot_laser(dif.angle()+PI, 2, 6, 3) 
                    shoot_laser(dif.angle()+PI, -2, 6, 3) 
                
        $Shoot.start(4-phase+rng.randf()*4)
    else:
        $Shoot.start(rng.randf())
        
        
func boss_hit(dmg):
    health -= dmg
    $Sprites.visible = false
    yield(get_tree().create_timer(0.10), "timeout")
    $Sprites.visible = true
    yield(get_tree().create_timer(0.10), "timeout")
    $Sprites.visible = false
    yield(get_tree().create_timer(0.10), "timeout")
    $Sprites.visible = true
    yield(get_tree().create_timer(0.10), "timeout")
    if $Lasers.get_child_count() == 0:
        teleport()
    
        
