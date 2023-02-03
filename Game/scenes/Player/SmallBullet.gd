extends Area2D

var speed = 500
var movement = Vector2()
var moving = true
var shield = 0
var damage = 0
var age = 0
var spawn = 0
var health = 0.5
var color = false
var dropscale = Vector3.ZERO
var height = 15
var flytime = 0.5

var tobedamage = 0

var notonscreen = 0

func _ready():
    if color:
        $Sprite.modulate = color
        $Shadow.modulate = color
        $Shadow.modulate.a = 0.5       
         
    $Sprite.position = Vector2.UP.rotated(-rotation)*height
    $Shadow.global_rotation = 0
    
    var tween = Tween.new()
    add_child(tween)
    tween.interpolate_property(self, "height", height, 0, abs(height)*0.02, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT,flytime)
    tween.start()
    
    
        
func _physics_process(delta):
    $Shadow.global_rotation = 0
    age += delta
    if age > 0.1 and damage == 0:
        damage = tobedamage
    $Sprite.position = Vector2.UP.rotated(-rotation)*height
    if height < 1:
        $Sprite.modulate.a = 0.5 + height/2.0
        $Shadow.modulate.a = height/2.0
    if height <= 0 or health <= 0:
        die()

    var frame = int(age*6)%2+1
    $Sprite.frame_coords.x = frame
    $Sprite/Color.frame_coords.x = frame
    global_position += ((Vector2(speed,0).rotated(rotation))*delta)


func _process(_delta):
    if not $VisibilityNotifier2D.is_on_screen():
        notonscreen += 1
        if notonscreen >= 5:
            queue_free()

func hit(dmg):
    health -= dmg


func die():
    queue_free()            


func _on_VisibilityNotifier2D_screen_exited():
    queue_free()





func _on_SmallBullet_area_entered(area):
    if area.is_in_group("Boss"):
        area.get_parent().boss_hit(damage)
        hit(3)
    if area.is_in_group("Bossbullet"):
        if damage > 0:
            var areadmg = area.damage
            while health > 0 and area.health > 0:
                area.hit(damage)
                hit(areadmg)
