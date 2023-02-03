extends Control


    
func init_menu():
    show()
    $Main.show()
    $Controls.hide()
    $Credits.hide()
    $Tutorial.hide()
    $Main/Start.grab_focus()


func _on_Start_pressed():
    get_parent().start_game()
    $Click.play()
    


func _on_Controls_pressed():
    $Main.hide()
    $Controls.show()
    $Credits.hide()
    $Tutorial.hide()
    $Controls/Back.grab_focus()
    $Click.play()


func _on_Credits_pressed():
    $Main.hide()
    $Controls.hide()
    $Credits.show()
    $Tutorial.hide()
    $Credits/Back.grab_focus()
    $Click.play()


func _on_HSlider_value_changed(value):
    Global.volume = value
    if value == 0:
        AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), true)
    else:
        AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), false)
        AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear2db(value/100.0))


func _on_Back_pressed():
    init_menu()
    $Click.play()
    
func start_animation():
    $Main/Label/Logo.show()
    $Thump.play()
    yield(get_tree().create_timer(1), "timeout")
    if not get_parent().in_game:
        $Thump.play()
    $Main/Label/Logo.frame += 1
    yield(get_tree().create_timer(1), "timeout")
    if not get_parent().in_game:
        $Thump.play()
    $Main/Label/Logo.frame += 1
    yield(get_tree().create_timer(1), "timeout")
    get_parent().start_audio()
    


func _on_Powerpoint_pressed():
    var url = "https://docs.google.com/presentation/d/e/2PACX-1vS5jUixWXIxeDR92E5u3PyVpWJ7AkRY9JOwZPxE8Bz7mMlAZKI1r-jkHSYjfGSexQx7M8DLIAdG121f/pub?start=false&loop=false&delayms=3000"
    if OS.has_feature('JavaScript'):
        JavaScript.eval("""
            window.open('https://docs.google.com/presentation/d/e/2PACX-1vS5jUixWXIxeDR92E5u3PyVpWJ7AkRY9JOwZPxE8Bz7mMlAZKI1r-jkHSYjfGSexQx7M8DLIAdG121f/pub?start=false&loop=false&delayms=3000', '_blank').focus();
        """)
    else:
# warning-ignore:return_value_discarded
        OS.shell_open(url)


func _on_HowTo_pressed():
    $Main.hide()
    $Controls.hide()
    $Credits.hide()
    $Tutorial.show()
    $Tutorial/Powerpoint.grab_focus()
    $Click.play()
    
