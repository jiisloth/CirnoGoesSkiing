extends Node2D

export(PackedScene) var Bullet

var jump_rotation = 0

var bullets = []
var dir = 0
var next = 0
var bullet_count = 0
var speed = 6
var extra_dmg = 0

var player

var rot_dir = 1

var tricks = []
var trick_total = 0

var launch = Vector3.ZERO
var fly = Vector3.ZERO
var hit = Vector3.ZERO
var total = Vector3.ZERO

var color = Color(1,1,1)

var loading = true 
var launchwhenready = false

func _ready():
    bullet_count = 4 + floor((abs(jump_rotation)+TAU/16)/PI)*4
    if jump_rotation < 0:
        rot_dir =- 1
    if len(tricks) == 0:
        queue_free()
        return
    var pointer = 0
    var score = 0
    var score_trick = 1
    for trick in tricks:
        score += trick.y*trick.y*10
        if trick.y > 0.2:
            score_trick += 1
        if pointer < 0.3333*trick_total:
            var to_point = 0.3333*trick_total-pointer
            if trick.y > to_point:
                launch[trick.x-1] += to_point
                var extra = trick.y - to_point
                to_point = 0.6667*trick_total - 0.3333*trick_total
                if extra > to_point:
                    fly[trick.x-1] += to_point
                    extra = extra - to_point
                    hit[trick.x-1] += extra
                else:
                    fly[trick.x-1] += extra
                    
            else:
                launch[trick.x-1] += trick.y
        elif pointer < 0.6667*trick_total:
            var to_point = 0.6667*trick_total-pointer
            if trick.y > to_point:
                fly[trick.x-1] += to_point
                var extra = trick.y - to_point
                hit[trick.x-1] += extra
            else:   
                fly[trick.x-1] += trick.y
        else:
            hit[trick.x-1] += trick.y
        total[trick.x-1] += trick.y
        pointer += trick.y
    Global.score += int(score*score_trick*score_trick)*10
    var c = total.normalized()
    color.r = (color.r + Color("#62abd2").r*c.x+Color("#a2e387").r*c.y+Color("#c63d42").r*c.z)/4.0
    color.g = (color.g + Color("#62abd2").g*c.x+Color("#a2e387").g*c.y+Color("#c63d42").g*c.z)/4.0
    color.b = (color.b + Color("#62abd2").b*c.x+Color("#a2e387").b*c.y+Color("#c63d42").b*c.z)/4.0
    color.s = 0.5
    color.v = 1
    launch = scale_property(launch)/(2/3.0)
    fly = scale_property(fly)/(2/3.0)
    hit = scale_property(hit)/(2/3.0)
        
func scale_property(prop):
    var ptotal = prop.x + prop.y + prop.z
    if ptotal > 2/3.0:
        var pscale = (2/3.0)/ptotal
        prop = prop*pscale
    return prop
        
func _process(delta):
    if loading:
        dir += delta*(speed + launch.z*6)
        if dir > next:
            add_bullet(next)
            next += TAU/bullet_count
            if next >= TAU:
                next = INF
                loading = false
                for bullet in bullets:
                    if is_instance_valid(bullet):
                        bullet.castready = true
                if launchwhenready:
                    launch_bullets()
    else:
        var has_bullets = false
        for bullet in bullets:
            if is_instance_valid(bullet):
                has_bullets = true
                break
        if not has_bullets:
            player.hide_circle()
            queue_free()

func add_bullet(d):
    d = d*rot_dir
    var bullet = Bullet.instance()
    bullet.rotation = (d + rotation)
    bullet.offset = Vector2(50,0).rotated(d+ rotation)
    bullet.global_position = player.global_position + Vector2(50,0).rotated(d+ rotation)
    bullet.color = color
    bullet.height = player.height + 20
    bullet.castspeed = speed + launch.z*6
    bullet.speed = 400 + 400*fly.z
    bullet.basedamage = 1 + hit.z*3
    bullet.trickbonus = trick_total*0.5
    bullet.powerupdmg = extra_dmg*0.5
    bullet.age -= trick_total*trick_total*5
    bullet.blinkspeed = (speed + launch.z*6)*0.2
    bullet.health = 1 + fly.y * 2.0
    bullet.shield = launch.y * 2.5
    bullet.spawn = hit.y
    bullet.track = fly.x
    bullet.dropscale = total
    bullet.targetingscale = launch.x
    var bosses = get_tree().get_nodes_in_group("Boss")
    if len(bosses) > 0:
        bullet.rotation = lerp_angle(d + rotation, (bosses[0].global_position - global_position).angle(), launch.x*0.8)
        if launch.x <= randf():
            bullet.target = bosses[0]
    bullet.hb_scale = 1 + 3*hit.x
    bullet.player = player
    bullets.append(bullet)
    player.get_parent().add_child(bullet)
    
func launch_bullets(fail=false):
    player.hide_circle()
    for bullet in bullets:
        if is_instance_valid(bullet):
            if fail:
                bullet.damage *= 0.5
                bullet.rotation += PI/8 - randf()*PI/4
            bullet.launch()
    queue_free()

func advance_position(jump_rot):
    for bullet in bullets:
        if is_instance_valid(bullet):
            bullet.newoffset = bullet.newoffset.rotated(PI/8*sign(jump_rot)) * 1.5
            bullet.rotation += PI/8*sign(jump_rot) 
