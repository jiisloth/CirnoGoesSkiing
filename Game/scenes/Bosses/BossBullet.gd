extends Area2D


var speed = 500
var movement = Vector2()
var damage = 5
var health = 5
var height = 20
var btype = 0
var color = false
const moving = true
var graze = true
var rotatespeed = 0

var dropscale = Vector3(0.2, 0.15, 0.15)

func _ready():
    if color:
        $Sprite.modulate = color
        $Shadow.modulate = color
        $Shadow.modulate.a = 0.5
    get_child(btype).disabled = false
    $Sprite.frame = btype
    $Sprite.position = Vector2.UP.rotated(-rotation)*20
    var tween = Tween.new()
    add_child(tween)
    if height != 20:
        tween.interpolate_property(self, "height", height, 20, abs(height-20)*0.008, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
    tween.interpolate_property(self, "height", height, 0, abs(height)*0.05, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT,4)
    tween.start()
        
        
func _physics_process(delta):
    $Shadow.global_rotation = 0
    if btype == 3:
        $Sprite.rotation += delta*sign(rotatespeed)*2
        rotatespeed *= 0.99
    $Sprite.position = Vector2.UP.rotated(-rotation)*height
    if height < 1:
        $Sprite.modulate.a = 0.5 + height/2.0
        $Shadow.modulate.a = height/2.0
    if height == 0:
        die()
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
        if body.height < height:
            graze = false
            body.hit(damage, true, 0.8)



