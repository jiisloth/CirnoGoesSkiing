extends CanvasLayer

var volume = 1
var end = false

func _ready():
    $Score.text = "Score: " + str(Global.score)
    $Tween.interpolate_property($ColorRect, "color:a", 0, 1, 4, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
    $Tween.interpolate_property($ColorRect2, "color:a", 0, 0.5, 4, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
    $Tween.interpolate_property($Hold, "rotation_degrees", 120, 2.2, 1, Tween.TRANS_LINEAR, Tween.EASE_IN, 3)
    $Tween.interpolate_property($Hold, "position", $Hold.position, Vector2(1100, 700), 1, Tween.TRANS_LINEAR, Tween.EASE_IN,3)
    $Tween.interpolate_property($Hold/MarisaFaceplant, "modulate:a", 1, 0, 0.7, Tween.TRANS_LINEAR, Tween.EASE_IN,4)
    $Tween.interpolate_property($Label, "modulate:a", 0, 1, 2, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT,4)
    $Tween.interpolate_property($Score, "modulate:a", 0, 1, 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT,5.5)
    $Tween.interpolate_property($Buttons, "modulate:a", 0, 1, 0.1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT,6)
    $Tween.interpolate_property($Buttons, "modulate:a", 1, 0, 0.1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT,6.1)
    $Tween.interpolate_property($Buttons, "modulate:a", 0, 1, 1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT,6.2)
    $Tween.interpolate_property(self, "volume", 1, 0, 2, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
    $Tween.start()
    yield(get_tree().create_timer(6), "timeout")
    $AudioStreamPlayer.play()
    $Buttons/Continue.grab_focus()
    end = true

func _process(_delta):
    if Input.is_action_just_pressed("ui_cancel") and end:
        get_tree().root.get_node("Main").quit_game()
        
    AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear2db(volume))
        




func _on_Restart_pressed():
    if end:
        get_tree().root.get_node("Main").quit_game()


func _on_Continue_pressed():
    if end:
        get_parent().continue_game()
        end = false
        $Tween.interpolate_property($ColorRect, "modulate:a", 1, 0, 1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
        $Tween.interpolate_property($ColorRect2, "modulate:a", 0.5, 0, 1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
        $Tween.interpolate_property($Hold, "modulate:a", 1, 0, 1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
        $Tween.interpolate_property($Label, "modulate:a", 1, 0, 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
        $Tween.interpolate_property($Buttons, "modulate:a", 1, 0, 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
        $Tween.interpolate_property($Score, "modulate:a", 1, 0, 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
        $Tween.interpolate_property(self, "volume", 0, 1, 1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
        $Tween.start()
        yield(get_tree().create_timer(1), "timeout")
        AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear2db(1))
        queue_free()


func _on_Continue_focus_entered():
    $Buttons.text = "> Continue?\n  Restart?"


func _on_Restart_focus_entered():
    $Buttons.text = "  Continue?\n> Restart?"
