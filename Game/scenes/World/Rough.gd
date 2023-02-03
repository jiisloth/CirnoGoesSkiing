extends Area2D



var rng = RandomNumberGenerator.new()
var rngseed = 0
var imma_die = false

func _ready():
    rng.seed = rngseed
    var first = true
    var rot = TAU*randf()
    for patch in get_children():
        if rng.randi()%2 == 0:
            patch.get_child(0).scale.x = -3 
        if first:
            first = false
            continue
        var pos = Vector2(56+randi()%25,0).rotated(rot)
        patch.position = Vector2(floor(pos.x/3),floor(pos.y/3))*3
        rot += TAU/6 - TAU/24 + randf()*(TAU/12)
        if randf() < 0.4:
            patch.queue_free()


func _process(_delta):
    if imma_die:
        queue_free()
        




func _on_Rough_body_entered(body):
    if body.name == "Player":
        body.add_rough(self)


func _on_Rough_body_exited(body):
    if body.name == "Player":
        body.remove_rough(self)
