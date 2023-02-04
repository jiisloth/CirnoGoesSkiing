extends Area2D

export(PackedScene) var SmallBullet

var speed = 500
var moving = false
var offset = Vector2()
var newoffset = Vector2()
var player
var movement = Vector2()
var damage = 1
var wave = 0
var yspeed = 0
var age = 0
var spawn = 0
var health = 1
var shield = 0
var track = 0
var target = false
var targeting = 0
var hb_scale = 1
var color = false
var dropscale = Vector3.ONE
var height = 20
var blinkspeed = 5
var castready = false
var flytime = 3

func _ready():
    newoffset = offset
    if color:
        $Sprite.modulate = color
        $Shadow.modulate = color
        $Shadow.modulate.a = 0.5
    if shield > 0:
        $Shield.show()        
        
    $CollisionShape2D.scale *= hb_scale
    $Sprite.position = Vector2.UP.rotated(-rotation)*height
    $Shield.position = Vector2.UP.rotated(-rotation)*height
    $Shadow.global_rotation = 0
    if track > 0:
        $Track.monitoring = true
    if height != 20:
        var tween = Tween.new()
        add_child(tween)
        tween.interpolate_property(self, "height", height, 20, abs(height-20)*0.008, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
        tween.start()
        
        
func _physics_process(delta):
    age += delta
    yspeed = cos(age*6)
    if height <= 0 or health <= 0:
        die()
    if moving:
        if track > 0:
            targeting += delta*6*track
            $Track.scale = Vector2.ONE*clamp(targeting, 0, 5)
            if target:
                if is_instance_valid(target):
                    rotation = lerp_angle(rotation, (target.global_position-global_position).angle(), track/(40.0-age/2))
                else:
                    target = false
                    targeting = 0.5
        global_position += ((movement + Vector2(speed,yspeed*wave*200).rotated(rotation))*delta)
    else:
        if offset != newoffset:
            offset = offset.move_toward(newoffset, delta*70)
        global_position = player.global_position + offset


func _process(delta):
    if shield > 0:
        shield -= delta
        $Shield.modulate.a = clamp(shield*2+0.5, 0.5, 1)
        if shield <= 0:
            shield = 0
            $Shield.hide()
    $Shadow.global_rotation = 0
    age += delta
    yspeed = cos(age*6)
    $Sprite.position = Vector2.UP.rotated(-rotation)*height
    $Shield.position = Vector2.UP.rotated(-rotation)*height
    if height < 1:
        $Sprite.modulate.a = 0.5 + height/2.0
        $Shadow.modulate.a = height/2.0
    if moving:
        var frame = int(age*6)%2+1
        $Sprite.frame_coords.x = frame
        $Shield.frame_coords.x = frame
        $Sprite/Color.frame_coords.x = frame
    else:
        if not castready:
            $Sprite.modulate.a = 0.5 + (1+sin((age+6)*blinkspeed*((age+6)*0.2)))/4
        else:
            $Sprite.modulate.a = 1
        if age > 2.5:
            if sin(2*(age+6)*blinkspeed*((age+6)*0.2)) < 0:
                $Sprite.hide()
            else:
                $Sprite.show()
        if age > 4:
            wave = 1
            launch()


func hit(dmg):
    if shield > 0:
        shield -= dmg*0.5
        if shield < 0:
            shield = 0 
            $Shield.hide()
    else:
        health -= dmg
        
func die():
    if spawn > 0 and height > 0 and moving:
        for i in ceil(spawn*8):
            var b = SmallBullet.instance()
            var rot = TAU*randf()
            b.global_position = global_position + Vector2(10,0).rotated(rot)
            b.speed = speed * 0.5
            b.tobedamage = damage*0.5
            b.color = color
            b.rotation = TAU*randf()
            get_parent().add_child(b)
        
    queue_free()


func launch():
    if moving:
        return
    if not castready:
        spawn *= 0.5
        spawn -= 0.1
        damage *= 0.4
        speed *= 0.8
        flytime *= 0.2
        wave = 1
    age = 0
    $Sprite.show()
    var tween = Tween.new()
    movement = player.velocity
    add_child(tween)
    tween.interpolate_property($Sprite, "modulate:a", $Sprite.modulate.a, 1, 0.2, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
    tween.interpolate_property(self, "height", height, 20, abs(height-20)*0.008, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
    tween.interpolate_property(self, "height", height, 0, abs(height)*0.05, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT,flytime)
    tween.start()
    moving = true
    shield = 0
    $Shield.hide()
    
    
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
        hit(2)
    if area.is_in_group("Bossbullet"):
        if shield != 0:
            var areadmg = area.damage
            while health > 0 and area.health > 0:
                area.hit(damage)
                hit(areadmg)
        
