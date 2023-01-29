extends Control


# Declare member variables here. Examples:
var texts = [
    "Finally it's winter, and you know what that means!",
    "It's time for winter sports!",
    "And who better to show you the ropes than me, Cir",
    "AGH"
    ]

var pointer = 0
var caret = 0
var lineready = false
var deltatime = 0

func _ready():
    $Tween.interpolate_property($MarisaBroom, "position", $MarisaBroom.position, Vector2(-600,500), 1, Tween.TRANS_LINEAR, 2, 10)
    $Tween.interpolate_property($MarisaBroom, "rotation_degrees", -30, 10, 1, Tween.TRANS_LINEAR, 2, 10)
    $Tween.start()

func _process(delta):
    if Input.is_action_just_pressed("ui_cancel") and pointer >= 0 and pointer < 3:
        print("?")
        $Recordo.play(0.6)
        $Cirno2.stop()
        $Intro.stop()
        $MarisaBroom.hide()
        $Label.hide()
        $Cirno.hide()
        pointer = -1
        $Tween.interpolate_property($Bg, "position:x", 477, 709, 0.8,Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
        $Tween.start()
        yield(get_tree().create_timer(1), "timeout")
        get_parent().end_intro()
        $Tween.interpolate_property($Bg, "modulate:a", 1, 0, 1,Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
        $Tween.start()
        yield(get_tree().create_timer(1), "timeout")
        queue_free()
    if pointer == -1:
        return
    deltatime += delta
    if deltatime > 0.05 and caret < len(texts[pointer]) and pointer < len(texts):
        deltatime = 0
        $Label.text += texts[pointer][caret]
        caret += 1
    if pointer < len(texts):
        if not lineready and caret == len(texts[pointer]):
            lineready = true
            next_line()
    
func next_line():
    caret += 1
    var wait = 0 
    match pointer:
        0:
            wait = 2
        1:
            wait = 2
        2:
            wait = 0.1
            $Recordo.play(0.6)
            $Tween.interpolate_property($Cirno, "position", $Cirno.position, Vector2(50,300), 0.5)
            $Tween.interpolate_property($Cirno, "scale", Vector2(0.323,0.323), Vector2(0.10,0.1), 0.5)
            $Tween.interpolate_property($Cirno, "rotation_degrees", 0, 360*3, 0.6)
            $Tween.start()
            $Cirno2.stop()
        3:
            wait = 0.4
            
    
    yield(get_tree().create_timer(wait), "timeout")
    if pointer == 3:#709 
        $Label.hide()
        $Cirno.hide()
        $Tween.interpolate_property($Bg, "position:x", 477, 709, 0.8,Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
        $Tween.start()
        yield(get_tree().create_timer(1), "timeout")
        get_parent().end_intro()
        $Tween.interpolate_property($Bg, "modulate:a", 1, 0, 1,Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
        $Tween.start()
        yield(get_tree().create_timer(1), "timeout")
        queue_free()
        return
    lineready = false
    $Label.text = ""
    caret = 0
    pointer += 1
    
    


func _on_Intro_finished():
    $Cirno2.play()
