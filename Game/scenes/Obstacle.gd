extends Node2D


export(int) var height = 30
export(int) var damage = 1
export(int) var health = 1

func _on_Area2D_body_entered(body):
    if body.name == "Player":
        if body.height < height:
            body.hit(damage, true)
func die():
    queue_free()


func _on_Area2D_area_entered(area):
    if area.is_in_group("Bullet"):
        area.hit(damage)
        if area.moving or area.health > 1:
            health -= area.damage
            if health < 0:
                die()   

