extends CanvasLayer


func _ready():
    $Tween.interpolate_property($Marisa, "position:x", 1350, 1087, 0.6, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
    $Tween.start()
    yield(get_tree().create_timer(1), "timeout")
    for text in $Control.get_children():
        $Tween.interpolate_property(text, "modulate:a", 0, 1, 0.2, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
        $Tween.start()
        yield(get_tree().create_timer(2), "timeout")
        $Tween.interpolate_property(text, "modulate:a", 1, 0, 0.2, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
        $Tween.start()
        yield(get_tree().create_timer(0.2), "timeout")
    $Tween.interpolate_property($Marisa, "position:x", 1087,1350, 0.6, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
    yield(get_tree().create_timer(0.6), "timeout")
    queue_free()

