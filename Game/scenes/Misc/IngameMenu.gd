extends ColorRect


func _ready():
    $Menu/HSlider.value = Global.volume


func _on_HSlider_value_changed(value):
    Global.volume = value
    if value == 0:
        AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), true)
    else:
        AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), false)
        AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear2db(value/100.0))


func _on_Quit_pressed():
    get_tree().paused = false
    get_tree().root.get_node("Main").quit_game()


func _on_Resume_pressed():
    get_tree().paused = false
    hide()
