extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
    $Tween.interpolate_property($Hold, "rotation_degrees", 90, 0, 0.2, Tween.TRANS_LINEAR, Tween.EASE_IN)
    $Tween.interpolate_property($Hold, "position:x", 600, 550, 2)
    $Tween.interpolate_property($Hold, "position:y", 380, 900, 0.5, Tween.TRANS_CUBIC, Tween.EASE_IN, 1.2)
    $Tween.start()
    


func _on_Tween_tween_all_completed():
    queue_free()
