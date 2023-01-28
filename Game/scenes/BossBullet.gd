extends Area2D

var tex1 = preload("res://img/pixelart/pikkulumipallo.png")
var tex2 = preload("res://img/pixelart/jaapuikkotaijotain.png")

var speed = 500
var movement = Vector2()
var damage = 5
var health = 1
var texType = 0
const moving = true

var graze = true

func _ready():
    if texType == 2:
        $Sprite.rotation = deg2rad(-90)
        $Sprite.texture = tex2
        $Sphere.disabled = true
        $Stick.disabled = false
    else:
        $Sprite.texture = tex1
        $Sphere.disabled = false
        $Stick.disabled = true
    $Sprite.position = Vector2.UP.rotated(-rotation)*20
        
        
func _physics_process(delta):
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
            body.hit(damage, 0)
