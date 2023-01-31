extends Node2D

export(Rect2) var notifrect = Rect2(-1000,-1000,2000,2000)

func _ready():
    var visnotif = VisibilityNotifier2D.new()
    visnotif.rect = notifrect
    add_child(visnotif)
    visnotif.connect("screen_exited", self, "on_screen_exit")
    
func on_screen_exit():
    queue_free()
