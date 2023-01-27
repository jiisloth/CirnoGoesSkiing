extends Control


var player

var current_rekt = false
var tricks = []

func _process(delta):
    update_rekt()

func start_trick():
    var rekt = ColorRect.new()
    match player.current_trick:
        player.trick.MELON:
            rekt.color = Color("#c63d42")
        player.trick.INDY:
            rekt.color = Color("#a2e387")
        player.trick.NOSE:
            rekt.color = Color("#62abd2")
    rekt.anchor_bottom = 1
    current_rekt = rekt
    $Bars.add_child(rekt)

func add_trick():
    if player.current_trick != player.trick.NONE and current_rekt:
        tricks.append([player.current_trick, player.trick_tick, current_rekt])
    current_rekt = false


func update_rekt():
    margin_left = -max(player.trick_total, 2)*20
    margin_right = max(player.trick_total, 2)*20
    var pointer = 0
    for t in tricks:
        var size = t[1]/max(player.trick_total, 2)
        t[2].anchor_left = pointer
        pointer += size
        t[2].anchor_right = pointer
    if current_rekt:
        current_rekt.anchor_left = pointer
        pointer += player.trick_tick/max(player.trick_total, 2)
        current_rekt.anchor_right = pointer
    
    $Separators/Separator.anchor_left = pointer / 3.0
    $Separators/Separator.anchor_right = pointer / 3.0
    $Separators/Separator2.anchor_left = pointer / 3.0 * 2
    $Separators/Separator2.anchor_right = pointer / 3.0 * 2
    
func clear():
    current_rekt = false
    tricks = []
    for rekt in $Bars.get_children():
        rekt.queue_free()

    
