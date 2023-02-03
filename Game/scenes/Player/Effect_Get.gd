extends Label

var types = {
    E.Effect.GRAZE: {"color": Color("#a24090"), "text": "Graze +1"},
    E.Effect.POWER: {"color": Color("#ba0a45"), "text": "Power +1"},
    E.Effect.HEALTH: {"color": Color("#59a997"), "text": "Healt +1"},
    E.Effect.SCORE: {"color": Color("#262e76"), "text": "Score +1K"},
    E.Effect.MELON: {"color": Color("#62abd2"), "text": "Melon"},
    E.Effect.INDY: {"color": Color("#a2e387"), "text": "Indy"},
    E.Effect.NOSEGRAB: {"color": Color("#c63d42"), "text": "Nosegrab"},
   }

var etype = "Graze"
var will_drop = false
var offset 

func _ready():
    offset = Vector2(randi()%3,randi()%3)*3
    margin_left = 22+offset.x
    text = types[etype]["text"]
    for s in $Outlines.get_children():
        s.text = text
        s.add_color_override("font_color", types[etype]["color"])
    var tween = Tween.new()
    add_child(tween)
    tween.interpolate_property(self, "margin_top", -8+offset.y, -70+offset.y,1.5, Tween.TRANS_ELASTIC, Tween.EASE_OUT)
    tween.start()


func drop():
    if will_drop:
        will_drop = false
        var tween = Tween.new()
        add_child(tween)
        tween.interpolate_property(self, "margin_top", margin_top, -18+offset.y, 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
        tween.interpolate_property(self, "modulate:a", modulate.a, 0,0.5)
        tween.interpolate_property(self, "rect_rotation", rect_rotation, 10, 0.5, Tween.TRANS_ELASTIC, Tween.EASE_OUT)
        tween.start()
        $Die.start(0.5)
    


func _on_Die_timeout():
    queue_free()


func _on_StartFade_timeout():
    var tween = Tween.new()
    add_child(tween)
    tween.interpolate_property(self, "modulate:a", modulate.a, 0,0.5)
    tween.start()
    $Die.start(0.5)
