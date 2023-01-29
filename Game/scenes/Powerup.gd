extends Area2D


var target = false
var dir = 0

var entered = false
var height = 0
var dropscale = Vector3(1, 0.8, 0.9)
var type = 0

func _ready():
    dropscale += Vector3.ONE * 0.2
    dropscale += Vector3(dropscale.x*randf(), dropscale.y*randf(), dropscale.z*randf())
    
    if dropscale.x < dropscale.y:
        type = 1
    if max(dropscale.z, dropscale.y) < dropscale.z:
        type = 2
    $Powerup.frame = type

func _process(delta):
    if target:
        var d = (target.global_position-global_position)
        var dist = d.length()
        var ndir = d.angle()
        var speed = clamp((400-dist)/80.0,0,4)
        dir = lerp_angle(dir, ndir, 0.6)
        position += Vector2(speed,0).rotated(dir)
        height = lerp(height, target.height, max(0,(400.0-dist)/6400.0))
        $Powerup.position.y = -23 -height
    if entered:   
        if abs(entered.height-height) < 8:
            if type == 0:
                entered.add_score()
            elif type == 1:
                entered.add_health()
            elif type == 2:
                entered.add_power()
            queue_free()
    
    
func _on_Track_body_entered(body):
    if body.name == "Player":
        target = body
        dir = (target.global_position-global_position).angle()
        
    


func _on_Powerup_body_entered(body):
    if body.name == "Player":
        entered = body


func _on_Powerup_body_exited(body):
    if body.name == "Player":
        entered = false


func _on_VisibilityNotifier2D_screen_exited():
    queue_free()
