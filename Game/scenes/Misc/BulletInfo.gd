extends VBoxContainer


var b

func _ready():
    if not Global.show_bullet_info:
        queue_free()

func _process(_delta):
    var bullets = get_tree().get_nodes_in_group("NormalPlayerBullet")
    if len(bullets) == 0:
        hide()
        return
    if b != bullets[len(bullets)-1]:
        show()
        b = bullets[len(bullets)-1]
        $Total/PowerUp/Number.text = "%.2f" % b.powerupdmg
        $Total/Trick/Number.text = "%.2f" % b.trickbonus
        $Total/Total/Number.text = "%.2f" % (b.powerupdmg + b.trickbonus)
        
        $Melon/Cast/Number.text = "%.2f" % b.targetingscale
        $Melon/Fly/Number.text = "%.2f" % b.track
        $Melon/Finish/Number.text = "%.2f" % b.hb_scale
        
        $Indy/Cast/Number.text = "%.2f" % b.shield
        $Indy/Fly/Number.text = "%.2f" % b.health
        $Indy/Finish/Number.text = "%.2f" % b.spawn
        
        $Nose/Cast/Number.text = "%.2f" % b.castspeed
        $Nose/Fly/Number.text = "%.2f" % b.speed
        $Nose/Finish/Number.text = "%.2f" % b.basedamage
        $Timer.start()
    


func _on_Timer_timeout():
    hide()
