extends Node2D


export(int) var height = 30
export(int) var damage = 1

func _on_Area2D_body_entered(body):
    if body.name == "Player":
        if body.height < height:
            body.hit(damage, true)
