extends Label

var types = {
    "Graze": Color("#a24090"),
    "Power": Color("#ba0a45")
   }
var etype = "Graze"

func _ready():
    var offset = Vector2(randi()%3,randi()%3)*3
    margin_left = 22+offset.x
    text = etype + " +1"
    for s in get_children():
        s.text = text
        s.add_color_override("font_color", types[etype])
    var tween = Tween.new()
    add_child(tween)
    tween.interpolate_property(self, "margin_top", -8+offset.y, -70+offset.y,1.5, Tween.TRANS_ELASTIC, Tween.EASE_OUT)
    tween.start()
    yield(get_tree().create_timer(2), "timeout")
    queue_free()
