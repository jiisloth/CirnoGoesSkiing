extends Area2D


var speed = 500
var moving = false
var offset = Vector2()
var player
var movement = Vector2()
var damage = 1
var wave = 0
var yspeed = 0
var age = 0
var health = 1
var track = 0
var target = false
var targeting = 0
var hb_scale = 1
var color = false
var dropscale = Vector3.ONE
var height = 20

func _ready():
    if color:
        $Sprite.modulate = color
        $Shadow.modulate = color
        $Shadow.modulate.a = 0.5
    $CollisionShape2D.scale *= hb_scale
    $Sprite.position = Vector2.UP.rotated(-rotation)*height
    $Shadow.global_rotation = 0
    if track > 0:
        $Track.monitoring = true
    var tween = Tween.new()
    add_child(tween)
    if height != 20:
        tween.interpolate_property(self, "height", height, 20, abs(height-20)*0.008, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
    tween.interpolate_property(self, "height", height, 0, abs(height)*0.05, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT,3)
    tween.start()
        
        
func _physics_process(delta):
    $Shadow.global_rotation = 0
    age += delta
    yspeed = cos(age*40+wave*10)
    $Sprite.position = Vector2.UP.rotated(-rotation)*height
    if height < 1:
        $Sprite.modulate.a = 0.5 + height/2.0
        $Shadow.modulate.a = height/2.0
    if height == 0:
        die()
    if moving:
        var frame = int(age*6)%2+1
        $Sprite.frame = frame
        $Sprite/Color.frame = frame
        if track > 0:
            targeting += delta*6*track
            $Track.scale = Vector2.ONE*clamp(targeting, 0, 5)
            if target:
                if is_instance_valid(target):
                    rotation = lerp_angle(rotation, (target.global_position-global_position).angle(), track/50.0)
                else:
                    target = false
                    targeting = 0.5
        global_position += ((movement + Vector2(speed,yspeed*wave*500).rotated(rotation))*delta)
    else:
        global_position = player.global_position + offset
    

func hit(dmg):
    health -= dmg
    if health <= 0:
        die()
        
func die():
    queue_free()


func _on_Track_area_entered(area):
    if area.is_in_group("Obstacle"):
        if not target:
            target = area
    if area.is_in_group("Boss"):
        target = area
            


func _on_VisibilityNotifier2D_screen_exited():
    queue_free()


func _on_Bullet_area_entered(area):
    if area.is_in_group("Boss"):
        area.get_parent().boss_hit(damage)
        if moving or health > 1:
            hit(3)
    
    if area.is_in_group("BossBullet"):
        if not moving and health > 1:
            area.hit(damage)
            hit(area.damage)
            
