extends Node2D


var end = false
var can_end = false

var trick = 0

func _process(delta):
    if end and can_end:
        can_end = false
        go_away()
        

func _ready():
    $Holder/Images.get_child(trick).show()
    $Roll.interpolate_property($Holder,"rotation_degrees",-30, 100, 9)
    $Roll.interpolate_property($Holder/Images,"rotation_degrees",0, 60, 9)
    $Roll.interpolate_property($Holder,"position:x", 450, 650, 9)
    $Roll.start()
    $Start.interpolate_property($Holder,"position:y", 800, 400, 0.3, Tween.TRANS_LINEAR, Tween.EASE_OUT)
    $Start.start()

func go_away():
    $Stop.interpolate_property($Holder,"position:y", $Holder.position.y, 1000, 0.3, Tween.TRANS_LINEAR, Tween.EASE_IN)
    $Stop.start()

    
    


func _on_Start_tween_all_completed():
    can_end = true


func _on_Stop_tween_all_completed():
    queue_free()
