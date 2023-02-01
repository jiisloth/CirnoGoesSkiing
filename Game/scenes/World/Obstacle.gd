extends Node2D


export(int) var height = 30
export(int) var damage = 1
export(int) var health = 1
export(float) var dropchance = 0.2
export(bool) var flippable = true
var pkill = false
var imma_die = false

var graze = true
var extra_drop = 0
var dropscale = Vector3(0.2, 0.15, 0.15)

func _ready():
    if flippable:
        $Sprite.scale.x = $Sprite.scale.x * sign(randf()-0.5)

func _process(_delta):
    if imma_die:
        queue_free()
    if health <= 0:
        die()   

func _on_Area2D_body_entered(body):
    if body.name == "Player":
        if body.height < height:
            graze = false
            body.hit(damage, true)
            
            
func die():
    if pkill:
        Global.score += 10
    drop()
    queue_free()


func drop():
    if pkill:
        if randf() < dropchance:
            var ds = dropscale*2
            if ds.x > randf():
                spawn_drop()
            if ds.y > randf():
                spawn_drop()
            if ds.z > randf():
                spawn_drop()
    elif randf() < dropchance/2.0:
        spawn_drop()

func spawn_drop():
    var p = load("res://scenes/Player/Powerup.tscn").instance()
    p.position = position + Vector2(randi()%12-6,randi()%12-6)
    p.dropscale = dropscale
    get_parent().add_child(p)

func _on_Area2D_area_entered(area):
    if area.is_in_group("Ramp"):
        if not area.get_parent().imma_die:
            imma_die = true
    if area.is_in_group("Obstacle"):
        if not area.get_parent().imma_die:
            imma_die = true
    if area.is_in_group("Bullet"):
        if area.moving or area.health > 1:
            dropscale = area.dropscale
            if area.moving:
                pkill = true
            while health > 0 and area.health > 0:
                if area.moving:
                    health -= area.damage
                else:
                    health -= area.damage/2.0
                if health <= 0 and not area.moving:
                    dropchance = 0
                    area.hit(area.health)
                    break
                area.hit(damage)
        else:
            area.hit(damage)
        if not area.is_in_group("BossBullet"):
            pkill = false
    if area.is_in_group("Boss"):
        health = 0
        pkill = false

