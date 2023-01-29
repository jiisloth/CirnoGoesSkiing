extends Node2D


var player

var credits = [
    ["< aa >","cc","bb"],
   ]

var pointer = 0

func _ready():
    player = get_tree().get_nodes_in_group("Player")[0]
    next_credit()
    
    
func _process(delta):
    if $Credit.global_position.y < player.global_position.y-800:
        next_credit()
    
    
func next_credit():
    if pointer >= len(credits):
        get_parent().level += 1
        queue_free()
        return
    var c = credits[pointer]
    $Credit/Label.text = ""
    for line in c:
        print(line)
        $Credit/Label.text += line
        $Credit/Label.text += "\n"
    pointer += 1
    $Credit.global_position = player.global_position + Vector2.DOWN*500
        
