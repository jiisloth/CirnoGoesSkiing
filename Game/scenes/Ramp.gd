extends Node2D


export(int) var height = 20

func _on_Area2D_body_entered(body):
    if body.name == "Player":
        if body.height < height:
            body.on_ramp(self)


func _on_Area2D_body_exited(body):
    if body.name == "Player":
        body.off_ramp(self)
