extends Control



var player
var score = 0

var playerhp = 0

var bosshealth = 0
var bossmaxhealth = 0
var bossphase = 0
var show_boss = false

var bpcolors = ["d3895a","c63d42","ba0a45","970156","a24090"]

func _ready():
    player = get_tree().get_nodes_in_group("Player")[0]
    playerhp = player.health/float(player.maxhealth)
    $Phase.hide()

func _process(_delta):
    if playerhp != player.health/float(player.maxhealth):
        playerhp = player.health/float(player.maxhealth)
        $HP/Fill.anchor_left = 1-playerhp
        if playerhp > 0.4:
            $Tween.interpolate_property($HP/Fill, "color", $HP/Fill.color, Color("#a2e387"), 0.5)
            $Tween.start()
        elif playerhp > 0.2:
            $Tween.interpolate_property($HP/Fill, "color", $HP/Fill.color, Color("#deab71"), 0.5)
            $Tween.start()
        else:
            $Tween.interpolate_property($HP/Fill, "color", $HP/Fill.color, Color("#ba0a45"), 0.5)
            $Tween.start()
    $Power/Power.margin_left =  - player.power*15
    if score != Global.score:
        score = Global.score
        $Score/Label.text = str(score)
        for s in $Score/Label.get_children():
            s.text = str(score)
    
    var bosses = get_tree().get_nodes_in_group("Boss")
    if len(bosses) >= 1:
        var boss = bosses[0].get_parent()
        if boss.ready:
            if not show_boss:
                $Phase/Label.text = str(boss.displayname)
                for s in $Phase/Label.get_children():
                    s.text = str(boss.displayname)
                bossmaxhealth = 0
                bosshealth = 0
                bossphase = 0
                $Phase.margin_right = 4
                $Phase/Fill/Fill.anchor_right = 1
                show_boss = true
                $Phase.show()
            if bossmaxhealth != max(4, boss.maxhealth):
                bossmaxhealth = max(4, boss.maxhealth)
                $Tween.interpolate_property($Phase, "margin_right", $Phase.margin_right, 15 * bossmaxhealth, abs($Phase.margin_right - 10 * bossmaxhealth)/100.0)
                $Tween.start()
            if bosshealth != max(0, boss.health):
                bosshealth = max(0, boss.health)
                $Tween.interpolate_property($Phase/Fill/Fill, "anchor_right", $Phase/Fill/Fill.anchor_right, bosshealth/(bossmaxhealth+0.001), abs($Phase/Fill/Fill.anchor_right - bosshealth/(bossmaxhealth+0.001)))
                $Tween.start()
            if bossphase != boss.phase:
                bossphase = boss.phase
                $Tween.interpolate_property($Phase/Fill/Fill, "color", $Phase/Fill/Fill.color, Color(bpcolors[bossphase-1]), 2, Tween.TRANS_ELASTIC)
                $Tween.start()  
    elif show_boss:
        show_boss = false
        $Tween.interpolate_property($Phase, "margin_right", $Phase.margin_right, 4, 1)
        $Tween.start()
        yield(get_tree().create_timer(1), "timeout")
        $Phase.hide()
            
