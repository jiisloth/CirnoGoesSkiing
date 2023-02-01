extends CanvasLayer


enum {
    LEFT,
    RIGHT
    OUTLEFT,
    OUTRIGHT
   }


var diag = E.SNOWBALL

func _ready():
    var wait = 0
    match diag:
        E.SNOWBALL:
            set_pos($Marisa, OUTRIGHT)
            wait = join($Marisa, RIGHT)
            yield(wait, "completed")
            wait = do_dialogue(0)
            yield(wait, "completed")
            wait = leave($Marisa, RIGHT)
            yield(wait, "completed")
        E.CIRNO:
            set_pos($Marisa, OUTRIGHT)
            set_pos($Cirno, OUTLEFT)
            wait = join($Cirno, LEFT)
            join($Marisa, RIGHT, 0.5)
            yield(wait, "completed")
            wait = do_dialogue(1, 0)
            yield(wait, "completed")
            leave($Cirno, LEFT)
            wait = leave($Marisa, RIGHT, 0.2)
            yield(wait, "completed")
        E.MIMA:
            set_pos($Marisa, OUTRIGHT)
            wait = join($Marisa, RIGHT)
            yield(wait, "completed")
            wait = do_dialogue(2, 0.3,0.9)
            yield(wait, "completed")
            wait = leave($Marisa, RIGHT)
            yield(wait, "completed")
    queue_free()


func do_dialogue(diagnum, wait = 0.3, speed=1):
    yield(get_tree().create_timer(wait), "timeout")
    for text in $Dialogues.get_child(diagnum).get_children():
        text.show()
        $Tween.interpolate_property(text, "modulate:a", 0, 1, 0.2, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
        $Tween.start()
        yield(get_tree().create_timer(1 + (len(text.text)/20.0)*speed), "timeout")
        $Tween.interpolate_property(text, "modulate:a", 1, 0, 0.2, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
        $Tween.start()
        yield(get_tree().create_timer(0.2), "timeout")
        wait += 0.2 + 1 + (len(text.text)/20.0)*speed
    return wait


func join(who, dir, delay=0, duration=0.6):
    who.show()
    var endpos = 140
    match dir:
        LEFT:
            endpos = 140
        RIGHT:
            endpos = 1087
    $Tween.interpolate_property(who, "position:x", who.position.x, endpos, duration, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, delay)
    $Tween.start()
    yield(get_tree().create_timer(delay+duration), "timeout")
    return delay+duration
    
      
func leave(who, dir, delay=0, duration=0.6):
    var endpos = -200
    match dir:
        LEFT:
            endpos = -200
        RIGHT:
            endpos = 1350
    $Tween.interpolate_property(who, "position:x", who.position.x, endpos, duration, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, delay)
    $Tween.start()
    yield(get_tree().create_timer(delay+duration), "timeout")
    who.hide()
    return delay+duration


func set_pos(who, pos):
    match pos:
        LEFT:
            who.position.x = 140
        RIGHT:
            who.position.x = 1087
        OUTLEFT:
            who.position.x = -200
        OUTRIGHT:
            who.position.x = 1350
    
