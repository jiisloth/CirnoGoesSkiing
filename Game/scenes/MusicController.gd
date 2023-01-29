extends Node


var loop = "marisa"

func _on_Marisa_finished():
    if loop == "marisa":
        $Marisa.play()


func _on_CirnoIntro_finished():
    if loop == "cirno":
        $Cirno.play()


func _on_Cirno_finished():
    if loop == "cirno":
        $Cirno.play()


func turn_down(time):
    var tween = Tween.new()
    for sound in get_children():
        tween.interpolate_property(sound, "volume_db", 0, -80, time, Tween.TRANS_LINEAR, Tween.EASE_IN)
    get_parent().add_child(tween)
    tween.start()
    yield(get_tree().create_timer(time-1), "timeout")
    tween.queue_free()
    
    
func play(what):
    loop = ""
    for sound in get_children():
        sound.volume_db = 0
        sound.stop()
    loop = what
    match what:
        "cirno":
            $CirnoIntro.play()
        "marisa":
            $Marisa.play()
        "snowball":
            $SnowBall.play()



func _on_SnowBallIntro_finished():
    if loop == "snowball":
        $SnowBall.play()


func _on_SnowBall_finished():
    if loop == "snowball":
        $SnowBall.play()
