extends Area2D


var target = false
var dir = 0

var entered = false
var height_get = randf()

func _process(delta):
    if target:
        var d = (target.global_position-global_position)
        var dist = d.length()
        var ndir = d.angle()
        var speed = clamp((320-dist)/100.0,0,2)
        dir = lerp_angle(dir, ndir, 0.7)
        position += Vector2(speed,0).rotated(dir)
    if entered:   
        if entered.height < 1 + 8*height_get:
            entered.power()
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
