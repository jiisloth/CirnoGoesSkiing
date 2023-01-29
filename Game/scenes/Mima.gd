extends Node2D


export(PackedScene) var Bullet
var deltatime = 0
onready var player := get_tree().get_root().get_node("World/Player")

var rng = RandomNumberGenerator.new()

var phase = 0
var health = 20

func _ready():
    rng.randomize()
    spawn()
    

func _process(delta):
    deltatime += delta
    $Sprites/Tail.frame = int(deltatime*10)%5
    $Sprites/Body.frame = int(deltatime)%2
    position += delta*player.velocity * 0.85
    $Sprites.position.y = cos(deltatime)*3
    if not $Area2D/CollisionShape2D.disabled and (player.global_position-global_position).length() > 600:
        teleport()
    if health <= 0:
        phase += 1
        health = 12 + 2*phase
        if phase == 3:
            queue_free()


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


func _on_Shoot_timeout():
    if not $Area2D/CollisionShape2D.disabled:
        match phase:
            0:
                var dif = (player.global_position-global_position)
                for i in 5:
                    shoot(dif.angle()+PI/2+i*PI/5, 150, -PI/2.0*(1+i/2.0), 3)
                    shoot(dif.angle()-PI/2-i*PI/5, 150, PI/2.0*(1+i/2.0), 3)
            1:
                var dif = (player.global_position-global_position)
                for i in 6:
                    shoot(dif.angle()+PI/2-i*PI/5, 200, -PI/2.0*(1+i/2.0), 3)
                    shoot(dif.angle()-PI/2+i*PI/5, 200, PI/2.0*(1+i/2.0), 3)       
            2:
                var dif = (player.global_position-global_position)
                for i in 5:
                    shoot(dif.angle()+PI/2+(1+i)*PI/5, 200 - 50*i%2, -PI/2.0*(1+i/2.0), 3)
                    shoot(dif.angle()-PI/2-(1+i)*PI/5, 200 - 50*i%2, PI/2.0*(1+i/2.0), 3)
                    shoot(dif.angle()+PI/2+i*PI/5, 200 - 50*i%2, -PI/2.0*(1+i/2.0), 3)
                    shoot(dif.angle()-PI/2-i*PI/5, 200 - 50*i%2, PI/2.0*(1+i/2.0), 3)
        $Shoot.start(4-phase+rng.randf()*4)
    else:
        $Shoot.start(rng.randf())
        
        
func boss_hit(dmg):
    health -= dmg
    visible = false
    yield(get_tree().create_timer(0.10), "timeout")
    visible = true
    yield(get_tree().create_timer(0.10), "timeout")
    visible = false
    yield(get_tree().create_timer(0.10), "timeout")
    visible = true
    yield(get_tree().create_timer(0.10), "timeout")
    teleport()
    
        
