extends CanvasLayer


enum {
    LEFT,
    RIGHT,
    STOP,
    UP,
    JUMP1,
    JUMP2,
    MELON,
    INDY,
    NOSE,
    CAST1,
    CAST2,
    CAST3,
    POWERUP1,
    POWERUP2,
    POWERUP3,
    RAMP1,
    RAMP2,
    SIGN1,
    SIGN2
   }

var holds = [LEFT,RIGHT,STOP,JUMP1,JUMP2,MELON,INDY,NOSE]
var timed = ["Start1", "Start2", "End1", "End2", "End3"]
var animtime = 0
var animpoint = 0
var buttonpoint = 0
var player
var controller = 0


func _ready():
    player = get_tree().get_nodes_in_group("Player")[0]
    next_quest(true)

var quests = {
    "Start1": {"value": 0, "subvalue": 0, "goal": 3, "text": "Let's see..\nThis should be like flying with my broom.", "icons": []},
    "Start2": {"value": 0, "subvalue": 0, "goal": 3, "text": "I'll go trough the basics quickly.", "icons": []},
    "Jumping": {"value": 0, "subvalue": 0, "goal": 1, "text": "Let's start by JUMPing!", "icons": [JUMP1,JUMP2]},
    "JumpingHigh": {"value": 0, "subvalue": 0, "goal": 3, "text": "Wait for the 'Weak jump' bar to disapear and hold the button to JUMP higher!", "icons": [JUMP1,JUMP2]},
    "Turning": {"value": 0, "subvalue": 0, "goal": PI/3, "text": "Control your snowboard by rotating it with directional inputs.", "icons": [[LEFT, RIGHT]]},
    "TurningLeft": {"value": 0, "subvalue": 0, "goal": PI, "text": "Make a full TURN to Left!", "icons": [LEFT]},
    "TurningRight": {"value": 0, "subvalue": 0, "goal": PI, "text": "Make a full TURN to Right!", "icons": [RIGHT]},
    "Speed": {"value": 0, "subvalue": 0, "goal": 350, "text": "Face down the slope to get some SPEED!", "icons": [[LEFT, RIGHT]]},
    "Stop": {"value": -INF, "subvalue": 0, "goal": -6, "text": "Now hold the STOP button to slow down!", "icons": [STOP]},
    "Climb": {"value": 0, "subvalue": 0, "goal": 2, "text": "While stopped, CLIMB up the hill with small hops.", "icons": [STOP, UP]},
    "Ramp": {"value": 0, "subvalue": 0, "goal": 2, "text": "Try to find a RAMP and get more air by timing your JUMP on it!", "icons": [JUMP1,JUMP2, RAMP1,RAMP2]},
    "Melon": {"value": 0, "subvalue": 0, "goal": 2, "text": "Let's try some tricks!\nWhile in air, do and hold trick called MELON!", "icons": [JUMP1,JUMP2, MELON]},
    "Indy": {"value": 0, "subvalue": 0, "goal": 2, "text": "Another cool trick is called INDY!", "icons": [JUMP1,JUMP2, INDY]},
    "Nosegrab": {"value": 0, "subvalue": 0, "goal": 2, "text": "Grab the nose of the board to do a Nosegrab", "icons": [JUMP1,JUMP2, NOSE]},
    "Cast": {"value": 0, "subvalue": 0, "goal": 2, "text": "You can CAST your spells after tricks! Try it out!", "icons": [[CAST1,CAST2,CAST3]]},
    "180": {"value": 0, "subvalue": 0, "goal": 2, "text": "Now you should try spinning in the air and doing a 180!", "icons": [JUMP1,JUMP2, [LEFT,RIGHT]]},
    "180_trick": {"value": 0, "subvalue": 0, "goal": 3, "text": "Spinning gives you more bullets, Try adding a trick to it.", "icons": [JUMP1,JUMP2, [LEFT,RIGHT]]},
    "Combo": {"value": 0, "subvalue": 0, "goal": 3, "text": "Now try combining multiple tricks to cast a spell with combined properties!", "icons": [JUMP1,JUMP2, MELON, INDY, NOSE]},
    "PowerUps": {"value": 0, "subvalue": 0, "goal": 1, "text": "Collect a Power Ups by destroying some trees and rocks!", "icons": [[POWERUP1,POWERUP2,POWERUP3]]},
    "End1": {"value": 0, "subvalue": 0, "goal": 3, "text": "I should follow the slope signs if I get lost to the woods.", "icons": [SIGN1,SIGN2]},
    "End2": {"value": 0, "subvalue": 0, "goal": 3, "text": "I think I can find more infromation about the tricks and their spell properties from the powerpoin in the menu.", "icons": []},
    "End3": {"value": 0, "subvalue": 0, "goal": 3, "text": "Okay, I think I should manage.\nLet's go!", "icons": []},
   }
var current_quest = 0
var pre_current_quest = 0
var do_anim = false

func _process(delta):
    animate_icons(delta)
    check_quests(delta)
    
func check_quests(delta):
    if pre_current_quest >= len(quests.keys()):
        return
    var q = quests.keys()[pre_current_quest]
    if q in timed:
        quests[q]["value"] += delta
    
    #Turning
    quests["Turning"]["value"] += abs(angle_difference(quests["Turning"]["subvalue"], player.dir))
    quests["Turning"]["subvalue"] = player.dir
    #TurningLeft
    quests["TurningLeft"]["value"] = max(quests["TurningLeft"]["value"] - angle_difference(quests["TurningLeft"]["subvalue"], player.dir), 0)
    quests["TurningLeft"]["subvalue"] = player.dir
    #TurningRight
    quests["TurningRight"]["value"] = max(quests["TurningRight"]["value"] + angle_difference(quests["TurningRight"]["subvalue"], player.dir), 0)
    quests["TurningRight"]["subvalue"] = player.dir
    #stop
    quests["Speed"]["value"] = max(quests["Speed"]["value"], player.velocity.length())
    if quests["Speed"]["value"] >= quests["Speed"]["goal"]:
        quests["Stop"]["value"] = max(quests["Stop"]["value"], -player.velocity.length())
    #Climb
    if player.climb != Vector2.ZERO:
        quests["Climb"]["subvalue"] = 1
    elif quests["Climb"]["subvalue"] == 1:
        quests["Climb"]["value"] += 1
        quests["Climb"]["subvalue"] = 0
        
    #Jumping
    if player.jumped:
        quests["Jumping"]["subvalue"] = 1
        #JumpingHigh
        if player.height > 45:
            quests["JumpingHigh"]["subvalue"] = 1
        #ramp
        if player.height > 80:
            quests["Ramp"]["subvalue"] = 1
    elif quests["Jumping"]["subvalue"] == 1:
        quests["Jumping"]["subvalue"] = 0
        quests["Jumping"]["value"] = quests["Jumping"]["goal"]       
        if quests["JumpingHigh"]["subvalue"] == 1:
            quests["JumpingHigh"]["subvalue"] = 0
            quests["JumpingHigh"]["value"] += 1
        if quests["Ramp"]["subvalue"] == 1:
            quests["Ramp"]["subvalue"] = 0
            quests["Ramp"]["value"] += 1
    #180
    if player.jumped and abs(player.jump_turn) > PI:
        quests["180"]["subvalue"] = 1
    elif not player.jumped and quests["180"]["subvalue"] == 1:
        quests["180"]["subvalue"] = 0
        quests["180"]["value"] += 1 
    #180
    if player.jumped and abs(player.jump_turn) > PI and (quests["Melon"]["subvalue"] < 0.2 or quests["Indy"]["subvalue"] < 0.2 or quests["Nosegrab"]["subvalue"] < 0.2):
        quests["180_trick"]["subvalue"] = 1
    elif not player.jumped and quests["180_trick"]["subvalue"] == 1:
        quests["180_trick"]["subvalue"] = 0
        quests["180_trick"]["value"] += 1 
    #Tricks
    if player.current_trick == player.trick.MELON:
        quests["Melon"]["subvalue"] += delta
    if player.current_trick == player.trick.INDY:
        quests["Indy"]["subvalue"] += delta
    if player.current_trick == player.trick.NOSE:
        quests["Nosegrab"]["subvalue"] += delta
        
    if not player.jumped:
        #Combo
        if (quests["Melon"]["subvalue"] > 0.2 and quests["Indy"]["subvalue"] > 0.2) or (quests["Melon"]["subvalue"] > 0.2 and quests["Nosegrab"]["subvalue"] > 0.2) or (quests["Indy"]["subvalue"] > 0.2 and quests["Nosegrab"]["subvalue"] > 0.2):
            quests["Combo"]["value"] += 1
            
        if quests["Melon"]["subvalue"] > 0.3:
            quests["Melon"]["value"] += 1
        quests["Melon"]["subvalue"] = 0
        
        if quests["Indy"]["subvalue"] > 0.3:
            quests["Indy"]["value"] += 1
        quests["Indy"]["subvalue"] = 0
        
        if quests["Nosegrab"]["subvalue"] > 0.3:
            quests["Nosegrab"]["value"] += 1
        quests["Nosegrab"]["subvalue"] = 0
    #Powerups
    quests["PowerUps"]["value"] = player.powerups
    quests["Cast"]["value"] = player.castcount
    next_quest()
        

func next_quest(set=false):
    if pre_current_quest >= len(quests.keys()):
        return
    var q = quests.keys()[pre_current_quest]
    if quests[q]["value"] >= quests[q]["goal"]:
        pre_current_quest += 1
        if pre_current_quest >= len(quests.keys()):
            end_tutorial()
            return
        next_quest(true)
    elif set:
        set_quest()

        
        
        
func set_quest():
    var holder = $Dialogues/Quests
    var text = $Dialogues/Quests/Text
    $Tween.interpolate_property(holder, "modulate:a", 1, 0, 0.2, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
    $Tween.start()
    yield(get_tree().create_timer(0.2), "timeout")
    current_quest = pre_current_quest
    var q = quests.keys()[current_quest]
    text.text = quests[q]["text"]
    set_icons()
    holder.show()
    $Tween.interpolate_property(holder, "modulate:a", 0, 1, 0.2, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
    $Tween.start()


func animate_icons(delta):
    animtime += delta
    var i = 0
    var q = quests.keys()[current_quest]
    var icons = quests[q]["icons"]
    if q in timed:
        $Dialogues/Quests/Count.text = "."
        for s in int(quests[q]["value"]):
            $Dialogues/Quests/Count.text += "."
    else:
        if quests[q]["goal"] in [1,2,3,4,5]:
            $Dialogues/Quests/Count.text = str(quests[q]["value"]) + "/" + str(quests[q]["goal"])
        else:
            if quests[q]["goal"] <= quests[q]["value"]:
                $Dialogues/Quests/Count.text = "1/1"
            else:
                $Dialogues/Quests/Count.text = "0/1"
            
    if len(icons) != $Dialogues/Quests/Control/Icons.get_child_count():
        return
    if animtime > 1 and animpoint == 0:
        animpoint += 1
        for icon in $Dialogues/Quests/Control/Icons.get_children():
            if typeof(icons[i]) == TYPE_ARRAY:
                icon.frame_coords.y = controller*2 + 1
            else:
                icon.frame_coords.y = controller*2 + 1
            i += 1
    if animtime > 1.25 and animpoint == 1:
        animpoint += 1
        for icon in $Dialogues/Quests/Control/Icons.get_children():
            if typeof(icons[i]) == TYPE_ARRAY:
                if not icons[i][buttonpoint%len(icons[i])] in holds:
                    icon.frame_coords.y = controller*2
            else:
                if not icons[i] in holds:
                    icon.frame_coords.y = controller*2
            i += 1
    if animtime > 2 and animpoint == 2:
        animpoint = 0
        animtime -= 2
        buttonpoint += 1
        for icon in $Dialogues/Quests/Control/Icons.get_children():
            if typeof(icons[i]) == TYPE_ARRAY:
                if icons[i][buttonpoint%len(icons[i])] in holds:
                    icon.frame_coords.y = controller*2
            else:
                if icons[i] in holds:
                    icon.frame_coords.y = controller*2
            i += 1
        i = 0
        for icon in $Dialogues/Quests/Control/Icons.get_children():
            if typeof(icons[i]) == TYPE_ARRAY:
                icon.frame_coords.x = quests[q]["icons"][i][buttonpoint%len(icons[i])]
            else:
                icon.frame_coords.x = quests[q]["icons"][i]
            i += 1          


func set_icons():
    for i in $Dialogues/Quests/Control/Icons.get_children():
        i.queue_free()
    var q = quests.keys()[current_quest]
    var icons = quests[q]["icons"]
    var width = 12 * len(icons) * 3
    var offst = -width + 6 * 3
    for i in icons:
        var icon = init_icon()
        icon.position.x = offst
        $Dialogues/Quests/Control/Icons.add_child(icon)
        offst += 12*3

        if typeof(i) == TYPE_ARRAY:
            icon.frame_coords.x = i[buttonpoint%len(i)]
        else:
            icon.frame_coords.x = i


func end_tutorial():
    var holder = $Dialogues/Quests
    $Tween.interpolate_property(holder, "modulate:a", 1, 0, 0.2, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
    $Tween.start()
    yield(get_tree().create_timer(0.2), "timeout")
    get_parent().end_tutorial()
    queue_free()

   
func init_icon():
    var sprite = Sprite.new()
    sprite.texture = load("res://img/pixelart/tutorialicons.png")
    sprite.hframes = 19
    sprite.vframes = 4
    sprite.scale = Vector2(3,3)
    return sprite
    
func angle_difference(angle1, angle2):
    var diff = angle2 - angle1
    return diff if abs(diff) < PI else diff + (TAU * -sign(diff))
