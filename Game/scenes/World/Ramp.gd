extends Node2D


export(int) var height = 20
export(int) var dist = 24


var imma_die = false
func _process(_delta):
    if imma_die:
        queue_free()
    

func _on_Area2D_body_entered(body):
    if body.name == "Player":
        if body.height < height:
            body.on_ramp(self)


func _on_Area2D_body_exited(body):
    if body.name == "Player":
        body.off_ramp(self)


func _on_ForceJump_body_entered(body):
    if body.name == "Player":
        body.force_jump(height)


func _on_Area2D_area_entered(area):
    if area.is_in_group("Ramp"):
        if not area.get_parent().imma_die:
            imma_die = true
    if area.is_in_group("Obstacle"):
        if not area.get_parent().imma_die:
            imma_die = true
