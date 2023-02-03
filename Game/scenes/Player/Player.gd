extends KinematicBody2D

export(PackedScene) var BulletShootter
export(PackedScene) var Effect_text
export(PackedScene) var TrickImg
export(PackedScene) var FacePlant




var velocity = Vector2.ZERO
var slide = Vector2.ZERO
var climb = Vector2()
var dir = 0
var movedir = 0
var movespeed = 0

var stoppingdir
var stopdir

var landed = 0

var lift = 0
var jump = 0
var height = 0

var last_dmg = 0

var jump_turn = 0

const gravity = 10
const turnspeed = 1.6

var active_ramps = []
var active_roughs = []

var tricks = []
var current_trick = trick.NONE
var trick_tick = 0
var trick_total = 0
enum trick {
    NONE,
    MELON,
    INDY,
    NOSE
   }
var trickimg = false

var coyote = 0
var was_on_ground = true
var jumped = false
var casting = false

var power = 0
var graze_boost = 0

var maxhealth = 100
var health = maxhealth

var dead = false
var launch_coyote = 0

var max_height = 0

var trick_coyote = [0.0,0.0,0.0]


func _physics_process(delta):
    if dead:
        dead_move()
        return
    if landed > 0:
        landed -= delta
        if landed <= 0:
            $Character/Jumpbar.hide()
            $Character/Jumpbar/Jump.hide()
            landed = 0
    set_was_on_ground(delta)
    var turn = 0
    if Input.is_action_pressed("left"):
        turn -= 1
    if Input.is_action_pressed("right"):
        turn += 1
    if Input.is_action_just_pressed("stop"):
        if sin(velocity.angle())*cos(velocity.angle()) > 0:
            stopdir = dir - PI/2.0
        else:
            stopdir = dir + PI/2.0
        stoppingdir = dir
    if Input.is_action_pressed("stop"):
        if velocity.length() > 200:
            if sin(velocity.angle())*cos(velocity.angle()) > 0:
                stopdir = dir - PI/2.0
            else:
                stopdir = dir + PI/2.0
            stoppingdir = dir
        if abs(velocity.normalized().dot(Vector2.RIGHT.rotated(stoppingdir))) < 0.6 or velocity.length() < 10:
            
            if cos(dir) > 0:
                stopdir = 0
            else:
                stopdir = PI 

        dir = lerp_angle(dir, stopdir, 0.2*(abs(angle_difference(dir,stopdir))/(PI*2/3))*delta*60)
        if velocity.length() < 15:
            movespeed *= 0.3

    if Input.is_action_pressed("up") and is_on_ground():
        if velocity.length() < 80 and abs(sin(dir)) < 0.3:
            jumped = true
            climb = Vector2(0,-80)
            movespeed = 0
            lift = 2.5
        pass #climb hill
    if Input.is_action_just_pressed("jump") and was_on_ground and not jumped:
        max_height = 0
        jumped = true
        jump_turn = 0
        tricks = []
        if is_on_ground():
            lift = 1+2*(1-landed)
        else:
            lift += 1+2*(1-landed*0.5)
        if len(active_ramps) > 0:
            lift += get_ramp_lift(get_ground_height(active_ramps),movespeed)
            if is_on_ground():
                jump = get_ground_height(active_ramps)
            else:
                jump += get_ground_height(active_ramps)
            active_ramps = []
        if landed > 0.5:
            $Character/Jumpbar/Jump.show()
        landed = 0
        $Character/Jumpbar.hide()
    if Input.is_action_pressed("jump") and $Damaged.time_left <= 0 and climb.length() == 0:
        lift -= delta*gravity*0.5
    else:
        lift -= delta*gravity
        
    #Tricks
    if not is_on_ground() and $Damaged.time_left <= 0:
        if Input.is_action_just_pressed("melon") or trick_coyote[0] < 0.2:
            trick_coyote = [1,1,1]
            if current_trick != trick.MELON:
                add_effect_text(E.Effect.MELON,true)
                add_trick()
            current_trick = trick.MELON
            $Character/Trickbar.start_trick()
            start_trick()
        if Input.is_action_just_pressed("indy") or trick_coyote[1] < 0.2:
            trick_coyote = [1,1,1]
            if current_trick != trick.INDY:
                add_effect_text(E.Effect.INDY,true)
                add_trick()
            current_trick = trick.INDY
            $Character/Trickbar.start_trick()
            start_trick()
        if Input.is_action_just_pressed("nose") or trick_coyote[2] < 0.2:
            trick_coyote = [1,1,1]
            if current_trick != trick.NOSE:
                add_effect_text(E.Effect.NOSEGRAB,true)
                add_trick()
            current_trick = trick.NOSE
            $Character/Trickbar.start_trick()
            start_trick()
            
        match current_trick:
            trick.MELON:
                if Input.is_action_pressed("melon"):
                    trick_tick += delta
                    trick_total += delta
                else:
                    add_trick()
            trick.INDY:
                if Input.is_action_pressed("indy"):
                    trick_tick += delta
                    trick_total += delta
                else:
                    add_trick()
            trick.NOSE:
                if Input.is_action_pressed("nose"):
                    trick_tick += delta
                    trick_total += delta
                else:
                    add_trick()
    else:           
        if Input.is_action_just_pressed("melon"):
            trick_coyote = [0,1,1]
        if Input.is_action_just_pressed("indy"):
            trick_coyote = [1,0,1]
        if Input.is_action_just_pressed("nose"):
            trick_coyote = [1,1,0]
    for i in 3:
        if trick_coyote[i] < 1:
            trick_coyote[i] += delta
                    
    
    if jump > 0 and max(jump + lift, 0) == 0:
        #print(max_height)
        land()
    jump = max(jump + lift, 0)
    var ground_height = 0
    if len(active_ramps) > 0:
        ground_height = get_ground_height(active_ramps)
    if is_on_ground():
        jumped = false
        height = jump + ground_height
    else:
        height = jump
        max_height = max(max_height,height)
    
    if is_on_ground():
        dir += delta*turn*turnspeed
    else:
        dir += delta*turn*turnspeed*3
        jump_turn += delta*turn*turnspeed*3
        
    while dir > PI*2:
        dir -= PI*2
    while dir < 0:
        dir += PI*2
        
    var look = 0 
    if dir < PI:
        look = dir
    else:
        look = dir - PI
    
    if is_on_ground():
        climb = Vector2.ZERO
        var pull = sin(look)*2.5
        if angle_difference(movedir, dir) > PI/2.0:
            movedir += PI
            movespeed = -movespeed
        elif angle_difference(movedir, dir) < -PI/2.0:
            movedir -= PI
            movespeed = -movespeed
        
        var pre_movedir = movedir
        movedir = lerp_angle(movedir, dir, 0.1*delta*60)
    
        var turned = clamp(abs(angle_difference(pre_movedir,dir)), 0, PI/2.0) / (PI/2.0)
        
        var accelerating = sign(sin(movedir))
        
        if abs(pull) < 0.4 and velocity.y >= 0:
            pull = 0
            if movespeed < 100:
                movespeed *= 0.99
                
            
        movespeed = movespeed*0.996*get_ground_speed_scale()+pull*accelerating
        
        var slidespeed = movespeed*abs(turned*turned*turned)*0.95
        movespeed -= slidespeed
        slide = slide * 0.98
        slide += Vector2(slidespeed,0).rotated(pre_movedir)
        movespeed += min(graze_boost, 10)*sign(movespeed)
    else:    
        movespeed += min(graze_boost, 10)*sign(movespeed)*0.5
    graze_boost = max(graze_boost-0.06,0)
    
    velocity = Vector2(movespeed,0).rotated(movedir) + slide + climb
    # warning-ignore:return_value_discarded
    move_and_slide(velocity, Vector2.UP)

func dead_move():
    slide += Vector2(movespeed,0).rotated(movedir)
    slide = slide * 0.7
    movespeed = 0
    velocity = slide
    # warning-ignore:return_value_discarded
    move_and_slide(velocity, Vector2.UP)

func land():
    landed = 1
    if current_trick != trick.NONE:
        hit(0, true, 0.5)
    else:
        shoot()
    $Character/Jumpbar.show()
    $Character/Trickbar.clear()
    end_trick()
    tricks = []
    current_trick = trick.NONE
    trick_tick = 0
    trick_total = 0


func add_trick():
    end_trick()
    show_circle()
    $Character/Trickbar.add_trick()
    if current_trick != trick.NONE:
        tricks.append(Vector2(current_trick, trick_tick))
        trick_tick = 0
    current_trick = trick.NONE


func end_trick():
    if trickimg:
        trickimg.end = true
        trickimg = false
    

func start_trick():
    trickimg = TrickImg.instance()
    trickimg.trick = current_trick-1
    add_child(trickimg)

func show_circle():
    casting = true
    $MagicCircle/Tween.interpolate_property($MagicCircle, "modulate:a", $MagicCircle.modulate.a, 0.5, 0.1)
    $MagicCircle/Tween.start()
    
    
func hide_circle(force=false):
    if not casting and ($Casts.get_child_count() <= 1 or force):
        $MagicCircle/Tween.interpolate_property($MagicCircle, "modulate:a", $MagicCircle.modulate.a, 0, 0.1)
        $MagicCircle/Tween.start()
    


func _process(delta):
    if Input.is_action_pressed("cast"):
        cast_bullets()
    $Camera2D.position = velocity/4
    if health <= 0 and not dead:
        dead = true
        $Shadow.hide()
        $Character.hide()
        $CollisionShape2D.disabled = true
        $Graze/CollisionShape2D.disabled = true
        $Death.show()
        get_parent().died()
    if dead:
        return
        
    animate(delta)
    
    if casting:
        set_stars()

var breath = 0
    
func set_stars():
    $MagicCircle/MagicStar.rotation = dir
    $MagicCircle/Stars.rotation = dir
    var currentstarcount = $MagicCircle/Stars.get_child_count() + 1
    var starcount = floor((abs(jump_turn)+TAU/16)/PI) + 1
    if currentstarcount != starcount:
        if currentstarcount < starcount:
            var star = $MagicCircle/MagicStar.duplicate()
            $MagicCircle/Tween.interpolate_property(star, "modulate:a", 0, 1, 0.1)
            $MagicCircle/Tween.start()
            $MagicCircle/Stars.add_child(star)
        else:
            $MagicCircle/Stars.get_child(0).queue_free()
        var rot = PI/2.0/starcount
        for s in $MagicCircle/Stars.get_children():
            s.rotation = rot
            rot += PI/2.0/starcount
    
func animate(delta):
    if $Damaged.time_left > 0:
        if int($Damaged.time_left * 10) % 2:
            $Character.visible = false
        else:
            $Character.visible = true
    var animation_dir = 12 - round(((dir)/TAU) * 12)
    if animation_dir == 12:
        animation_dir = 0
    
    if landed > 0:
        $Character/Jumpbar.margin_right = ceil(11*landed)*3
        $Character/Jumpbar.margin_left = ceil(-11*landed)*3
        if landed > 0.66:
            $Character/Jumpbar.color = Color("#262e76")
        elif landed > 0.33:
            $Character/Jumpbar.color = Color("#62abd2")
        else:
            $Character/Jumpbar.color = Color("#7adaeb")
    
    $Shadow.frame_coords.x = animation_dir
    $Character/Feet.frame_coords.x = animation_dir
    $Character/Torso.frame_coords.x = animation_dir
    $Character/Head.frame_coords.x = animation_dir
    if movespeed > 2:
        $Character/Head.frame_coords.y = 0
    if movespeed < -2:
        $Character/Head.frame_coords.y = 1
        
    $Character.position.y = -height
    
    breath += delta*1.2
    if breath > TAU:
        breath -= TAU
    
    if sin(breath) > 0.2:
        $Character/Head.position.y = -27
    else:
        $Character/Head.position.y = -30
        
    if sin(breath) > 0.3:
        $Character/Torso.position.y = -27
    else:
        $Character/Torso.position.y = -30
        
    
    
    if is_on_ground() and velocity.length() > 100:
        $Particles2D.rotation = dir
        $Particles2D.emitting = true
    else:
        $Particles2D.emitting = false


func hit(damage, stop, speed=0.2):
    cast_bullets(true)
    if $Damaged.time_left != 0:
        if last_dmg < damage:
            health -= damage-last_dmg
        last_dmg = damage
        return
    for effect in $Character/EffectTxts.get_children():
        effect.drop()
    if stop:
        movespeed *= speed
    power = power*0.66
    if power < 0.5:
        power = 0
    graze_boost = 0
    casting = false
    $Damaged.start(1.5)
    $Character/Trickbar.clear()
    end_trick()
    tricks = []
    current_trick = trick.NONE
    hide_circle()
    trick_tick = 0
    trick_total = 0
    health -= damage
    last_dmg = damage
    if health > 0:
        var faceplant = FacePlant.instance()
        add_child(faceplant)


func shoot():
    casting = false
    if $Damaged.time_left > 0 or len(tricks) == 0:
        return
    var shootter = BulletShootter.instance()
    shootter.extra_dmg = power
    shootter.rotation = dir  + max(0, sign(sin(movedir)))*PI
    shootter.tricks = tricks
    shootter.player = self
    shootter.trick_total = trick_total
    shootter.jump_rotation = jump_turn
    add_to_cast_que(shootter)
        
func add_to_cast_que(cast):
    var casts = $Casts.get_children()
    for c in casts:
        c.advance_position(jump_turn)
    if len(casts) == 6:
        casts[0].launch_bullets()
    $Casts.add_child(cast)

func cast_bullets(fail=false):
    for c in $Casts.get_children():
        if not c.loading or fail:
            c.launch_bullets(fail)
        else:
            c.launchwhenready = true
    hide_circle(true)
    
        
    

func on_ramp(ramp):
    if not ramp in active_ramps:
        active_ramps.append(ramp)
  
func off_ramp(ramp):
    if ramp in active_ramps:
        active_ramps.erase(ramp)

func get_ground_speed_scale():
    var ss = 1
    if len(active_roughs) > 0 and velocity.length() > 100:
        ss = 0.9
    return ss

func get_ground_height(ramps):
    var gh = 0
    for ramp in ramps:
        var distance = abs(ramp.global_position.y - global_position.y)
        gh = max(gh, (1-distance/24) * ramp.height)
    return gh

func force_jump(h):
    if was_on_ground:
        if is_on_ground():
            lift = get_ramp_lift(h,movespeed)
            jump = h
        else:
            lift += get_ramp_lift(h,movespeed)
            jump += h
        active_ramps = []

func get_ramp_lift(h,s):
    return clamp(h*abs(s)*0.00015,0,6)

func is_on_ground():
    if jump == 0:
        return true
    else:
        return false

func set_was_on_ground(delta):
    if not is_on_ground():
        coyote += delta
    else:
        coyote = 0
    if coyote < 0.2:
        was_on_ground = true
    else:
        was_on_ground = false

func add_graze():
    add_effect_text(E.Effect.GRAZE)
    if graze_boost == 0:
        graze_boost = 3
    elif graze_boost * 1.5 < 3:
        graze_boost = 4
    else:
        graze_boost *= 1.5 
        
    
func add_power():
    add_effect_text(E.Effect.POWER)
    power += 1  
    
func add_health():
    add_effect_text(E.Effect.HEALTH)
    health = min(health+3, maxhealth)
    
func add_score():
    add_effect_text(E.Effect.SCORE)
    Global.score += 1000

func add_effect_text(t, will_drop=false):
    var txt = Effect_text.instance()
    txt.etype = t
    txt.will_drop = will_drop
    $Character/EffectTxts.add_child(txt)

func angle_difference(from,to):
    return Vector2.UP.rotated(from).angle_to(Vector2.UP.rotated(to))


func _on_Graze_area_exited(area):
    if area.is_in_group("Bossbullet") or area.is_in_group("Obstacle") or area.is_in_group("Boss"):
        if area.is_in_group("Obstacle") or area.is_in_group("Boss"):
            area = area.get_parent()
        if area.graze:
            add_graze()
        area.graze = true

func add_rough(rough):
    if not rough in active_roughs:
        active_roughs.append(rough)

func remove_rough(rough):
    if rough in active_roughs:
        active_roughs.erase(rough)


func continue_game():
    health = maxhealth
    power = 0
    graze_boost = 0
    Global.score = 0
    $Damaged.start(3)
    $Shadow.show()
    $Character.show()
    $CollisionShape2D.disabled = false
    $Graze/CollisionShape2D.disabled = false
    $Death.hide()
    yield(get_tree().create_timer(1), "timeout")
    health = maxhealth
    dead = false
