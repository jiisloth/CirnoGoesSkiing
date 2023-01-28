extends KinematicBody2D

export(PackedScene) var BulletShootter
export(PackedScene) var Effect_text



var velocity = Vector2.ZERO
var slide = Vector2.ZERO
var dir = 0
var movedir = 0
var movespeed = 0

var stoppingdir
var stopdir

var lift = 0
var jump = 0
var height = 0

var jump_turn = 0

const gravity = 10
const turnspeed = 1.6

var active_ramps = []

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

var coyote = 0
var was_on_ground = true
var jumped = false


func _physics_process(delta):
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
        if abs(velocity.normalized().dot(Vector2.RIGHT.rotated(stoppingdir))) < 0.6 or velocity.length() < 10:
            
            if cos(dir) > 0:
                stopdir = 0
            else:
                stopdir = PI 

        dir = lerp_angle(dir, stopdir, 0.2*(abs(angle_difference(dir,stopdir))/(PI*2/3))*delta*60)
        if velocity.length() < 15:
            movespeed *= 0.5 *delta*60

    if Input.is_action_pressed("up") and is_on_ground():
        pass #climb hill
    if Input.is_action_just_pressed("jump") and was_on_ground and not jumped:
        jumped = true
        jump_turn = 0
        tricks = []
        if is_on_ground():
            lift = 3
        else:
            lift += 3
        if len(active_ramps) > 0:
            lift += get_ramp_lift(get_ground_height(active_ramps),movespeed)
            if is_on_ground():
                jump = get_ground_height(active_ramps)
            else:
                jump += get_ground_height(active_ramps)
            active_ramps = []
    if Input.is_action_pressed("jump") and $Damaged.time_left <= 0:
        lift -= delta*gravity*0.5
    else:
        lift -= delta*gravity
        
    #Tricks
    if not is_on_ground() and $Damaged.time_left <= 0:
        if Input.is_action_just_pressed("melon"):
            if current_trick != trick.MELON:
                add_trick()
            current_trick = trick.MELON
            $Character/Trickbar.start_trick()
        if Input.is_action_just_pressed("indy"):
            if current_trick != trick.INDY:
                add_trick()
            current_trick = trick.INDY
            $Character/Trickbar.start_trick()
        if Input.is_action_just_pressed("nose"):
            if current_trick != trick.NOSE:
                add_trick()
            current_trick = trick.NOSE
            $Character/Trickbar.start_trick()
            
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
            
    
    if jump > 0 and max(jump + lift, 0) == 0:
        $Character/Trickbar.clear()
        shoot()
        tricks = []
        current_trick = trick.NONE
        trick_tick = 0
        trick_total = 0
    jump = max(jump + lift, 0)
    var ground_height = 0
    if len(active_ramps) > 0:
        ground_height = get_ground_height(active_ramps)
    if is_on_ground():
        jumped = false
        height = jump + ground_height
    else:
        height = jump
    
    if is_on_ground():
        dir += delta*turn*turnspeed
    else:
        dir += delta*turn*turnspeed*5
        jump_turn += delta*turn*turnspeed*5
        
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
        
        var accelerating = 1
        if sin(movedir) < 0:
            accelerating = -1
            
        movespeed = movespeed*0.997+pull*accelerating*delta*60
        
        var slidespeed = movespeed*(turned*turned)*0.9
        movespeed -= slidespeed
        slide = slide * 0.98*delta*60
        slide += Vector2(slidespeed,0).rotated(pre_movedir)
    
    velocity = Vector2(movespeed,0).rotated(movedir) + slide
    move_and_slide(velocity, Vector2.UP)

func add_trick():
    $Character/Trickbar.add_trick()
    if current_trick != trick.NONE:
        tricks.append(Vector2(current_trick, trick_tick))
        trick_tick = 0
    current_trick = trick.NONE

func _process(delta):
    animate(delta)

var breath = 0
    
func animate(delta):
    if $Damaged.time_left > 0:
        if int($Damaged.time_left * 10) % 2:
            $Character.visible = false
        else:
            $Character.visible = true
    var animation_dir = 12 - round(((dir)/TAU) * 12)
    if animation_dir == 12:
        animation_dir = 0
        
    
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
        
    
    
    if is_on_ground():
        $Particles2D.rotation = dir
        $Particles2D.emitting = true
    else:
        $Particles2D.emitting = false


func hit(damage, stop):
    if stop:
        movespeed *= 0.2
    $Damaged.start()


func shoot():
    if $Damaged.time_left > 0:
        return
    var shootter = BulletShootter.instance()
    shootter.rotation = dir
    shootter.tricks = tricks
    shootter.trick_total = trick_total
    shootter.player_rotation = jump_turn
    add_child(shootter)

func on_ramp(ramp):
    if not ramp in active_ramps:
        active_ramps.append(ramp)
  
func off_ramp(ramp):
    if ramp in active_ramps:
        active_ramps.erase(ramp)

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
    return clamp(h*abs(movespeed)*0.0001,0,5)

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

func graze():
    var txt = Effect_text.instance()
    txt.etype = "Graze"
    add_child(txt)

func angle_difference(from,to):
    return Vector2.UP.rotated(from).angle_to(Vector2.UP.rotated(to))
