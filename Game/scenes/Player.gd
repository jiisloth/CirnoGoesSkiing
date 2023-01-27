extends KinematicBody2D

var velocity = Vector2.ZERO
var slide = Vector2.ZERO
var dir = 0
var movedir = 0
var movespeed = 0

var stoppingdir
var stopdir

var lift = 0
var height = 0

const gravity = 10
const turnspeed = 1

func _physics_process(delta):
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

        dir = lerp_angle(dir, stopdir, 0.2*(abs(angle_difference(dir,stopdir))/(PI*2/3)))
#        if abs(movespeed) > 30:
#            turn = sin(dir)*sin(dir)*sin(dir)*20 + sin(dir)*2
#        else:
#            turn = sin(dir)*sin(dir)*sin(dir)*20 + sin(dir)*2
    if Input.is_action_pressed("up") and is_on_ground():
        pass #climb hill
    if Input.is_action_just_pressed("jump") and is_on_ground():
        lift = 3
    if Input.is_action_pressed("jump"):
        lift -= delta*gravity*0.5
    else:
        lift -= delta*gravity
    
    height = max(height + lift, 0)
    $Character.position.y = -height
    
    if is_on_ground():
        dir += delta*turn*turnspeed
    else:
        dir += delta*turn*turnspeed*8
        
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
        var pull = sin(look)
        if angle_difference(movedir, dir) > PI/2.0:
            movedir += PI
            movespeed = -movespeed
        elif angle_difference(movedir, dir) < -PI/2.0:
            movedir -= PI
            movespeed = -movespeed
        
        var pre_movedir = movedir
        movedir = lerp_angle(movedir, dir, 0.1)
    
        var turned = clamp(abs(angle_difference(pre_movedir,dir)), 0, PI/2.0) / (PI/2.0)
        
        var accelerating = 1
        if sin(movedir) < 0:
            accelerating = -1
            
        movespeed = movespeed*0.997+pull*accelerating
        
        var slidespeed = movespeed*(turned*turned)
        movespeed -= slidespeed
        slide = slide * 0.98
        slide += Vector2(slidespeed,0).rotated(pre_movedir)
    
    $Shadow.rotation = dir
    $Character/Board.rotation = dir
    velocity = Vector2(movespeed,0).rotated(movedir) + slide
    move_and_slide(velocity, Vector2.UP)
        
        
func is_on_ground():
    if height == 0:
        return true
    else:
        return false
    
func angle_difference(from,to):
    return Vector2.UP.rotated(from).angle_to(Vector2.UP.rotated(to))
