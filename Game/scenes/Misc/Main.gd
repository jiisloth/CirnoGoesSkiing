extends Node

export(PackedScene) var Level

var level

var in_game = false

func _ready():
    $Menu/Main.show()
    $Menu.hide()
    $Menu/Controls.hide()
    $Menu/Credits.hide()
    $Menu/Tutorial.hide()
    $Intro.show()
    

func start_game():
    $Menu.hide()
    if get_node_or_null("Intro"):
        $Intro.hide()
    in_game = true
    Global.score = 0
    level = Level.instance()
    level.seek = $AudioStreamPlayer.get_playback_position()
    add_child(level)
    $AudioStreamPlayer.stop()
    

func quit_game():
    $Menu.init_menu()
    in_game = false
    Global.score = 0
    level.queue_free()
    yield(get_tree().create_timer(0.2), "timeout")
    AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear2db(1))
    $Menu/Main/HSlider.value = Global.volume
    $AudioStreamPlayer.play()
    
    
    
func end_intro():
    $Menu.show()
    $Menu.init_menu()
    yield(get_tree().create_timer(1), "timeout")
    $Menu.start_animation()


func _on_AudioStreamPlayer_finished():
    if not in_game:
        $AudioStreamPlayer.play()

func start_audio():
    if not in_game:
        $AudioStreamPlayer.play()
