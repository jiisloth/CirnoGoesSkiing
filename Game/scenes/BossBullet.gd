extends Area2D


var speed = 500
var movement = Vector2()
var damage = 5
var health = 1
var btype = 0
const moving = true
var graze = true
var rotatespeed = 0

var dropscale = Vector3(0.2, 0.15, 0.15)

func _ready():
    get_child(btype).disabled = false
    $Sprite.frame = btype
    $Sprite.position = Vector2.UP.rotated(-rotation)*20
        
        
func _physics_process(delta):
    if btype == 3:
        $Sprite.rotation += delta*sign(rotatespeed)*2
        rotatespeed *= 0.99
    $Sprite.position = Vector2.UP.rotated(-rotation)*20
    rotation += delta*rotatespeed
    global_position += ((movement + Vector2(speed,0).rotated(rotation))*delta)
    

func hit(dmg):
    health -= dmg
    if health <= 0:
        die()
        
func die():
    queue_free()



func _on_VisibilityNotifier2D_screen_exited():
    queue_free()


func _on_Bullet_body_entered(body):
    if body.name == "Player":
        if body.height < 20:
            graze = false
            body.hit(damage, true, 0.8)
