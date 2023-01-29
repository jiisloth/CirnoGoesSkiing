extends Control



onready var player := get_tree().get_root().get_node("World/Player")
var score = 0

func _process(delta):
    var hp =  player.health/float(player.maxhealth)
    $HP/Fill.anchor_right = hp
    if hp > 0.4:
        $HP/Fill.color = Color("#a2e387")
    elif hp > 0.2:
        $HP/Fill.color = Color("#deab71")
    else:
        $HP/Fill.color = Color("#ba0a45")
    $Power.margin_right = 39 + player.power*9
    if score != Global.score:
        score = Global.score
        $Score/Label.text = str(score)
        for s in $Score/Label.get_children():
            s.text = str(score)
