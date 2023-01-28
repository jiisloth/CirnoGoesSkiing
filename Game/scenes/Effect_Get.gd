extends Label

var types = {
    "Graze": Color("#a24090")
   }
var etype = "Graze"

func _ready():
    text = etype + " +1"
    for s in get_children():
        s.text = text
        s.add_color_override("font_color", types[etype])
    var tween = Tween.new()
    add_child(tween)
    tween.interpolate_property(self, "margin_top", -8, -70,1.5, Tween.TRANS_ELASTIC, Tween.EASE_OUT)
    tween.start()
    yield(get_tree().create_timer(2), "timeout")
    queue_free()
