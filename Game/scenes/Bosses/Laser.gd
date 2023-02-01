extends Area2D


var delta_time = 0
var llen = 10
var duration = 3
var damage = 3
var graze = true
var offset = 100
var rotatespeed = 0
var shut = false
var poslock = false

func _ready():
    $Timer.start(duration)
    $Sprites.position.x = offset

func _process(delta):
    if poslock:
        global_position = poslock
    $Sprites.position = Vector2.UP.rotated(-rotation)*20 + Vector2(offset,0)
    delta_time += delta
    rotation += delta*rotatespeed
    $Sprites/Laser.region_rect.position.x = -int(delta_time*500)%24
    if not shut and llen < 2400:
        llen += delta * 60 * 30
        $Sprites/Laser.region_rect.size.x = int(llen)/3.0
        $Sprites/Laser.position.x = int(llen)/2.0/3.0
        $CollisionShape2D.shape.extents.x = int(llen)/2.0
        $CollisionShape2D.position.x = offset + int(llen)/2.0
    if shut:
        if llen > 50:
            llen -= delta * 60 * 30
            $Sprites/Laser.region_rect.size.x = int(llen)/3.0
            $Sprites/Laser.position.x = 2400/3.0 - int(llen)/2.0/3.0
            $CollisionShape2D.shape.extents.x = int(llen)/2.0
            $CollisionShape2D.position.x = offset + 2400 - int(llen)/2.0
        else:
            queue_free()
            

func shutdown():
    if not shut:
        $Sprites/Sprite.hide()
        shut = true
        poslock = global_position
    

func _on_Timer_timeout():
    shutdown()


func _on_Laser_body_entered(body):
    if body.name == "Player":
        if body.height < 20:
            graze = false
            body.hit(damage, true, 0.8)
