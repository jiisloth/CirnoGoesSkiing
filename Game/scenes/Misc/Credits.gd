extends Node2D


var player
var text_to_play = []

var credits = [
    ["< MarisaSSX >", "A Game By", "pintin anime tiimi"],
    ["< Head Developer >", "jsloth"],
    ["< Main Producer >", "pintti"],
    ["< Music by >", "borb"],
    ["< Art by >", "DebPet"],
    ["< Pixel Art by >", "pintti", "jsloth"],
    ["< Main programmer >", "jsloth"],
    ["< Assisting programmer >", "pintti"],
    ["< Script by >", "pintti"],
    ["Special thanks to", "mom and dad", "borb <3 mima"],
    ["and", "YOU"],
    ["THANKS", "FOR", "PLAYING"],
    ["btw, if you got more than", "100 000 points", "you can now enjoy a small surprise"]
   ]

var true_end = [
    ["Mima went home.", "", "Cirno is dead"],
    ["Thanks again!"],
    ["THE END!"],
    [""],
    [""],
    [""],
    [""],
    [""],
    [""],
    [""],
    [""],
    [">:O"],
   ]

enum {
    CREDITS,
    TRUEEND
   }

var sequence = CREDITS

var pointer = 0

func _ready():
    match sequence:
        CREDITS:
            text_to_play = credits
        TRUEEND:
            text_to_play = true_end
    player = get_tree().get_nodes_in_group("Player")[0]
    next_credit()
    
    
func _process(_delta):
    if $Credit.global_position.y < player.global_position.y-800:
        next_credit()
    
    
func next_credit():
    if pointer >= len(text_to_play):
        get_parent().level += 1
        queue_free()
        return
    var c = text_to_play[pointer]
    $Credit/Label.text = ""
    for line in c:
        $Credit/Label.text += line
        $Credit/Label.text += "\n"
    pointer += 1
    $Credit.global_position = player.global_position + Vector2.DOWN*500
        
