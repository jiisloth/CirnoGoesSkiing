extends Node2D

var coords = Vector2.ZERO
var size = 800

export(PackedScene) var Trees

var rng = RandomNumberGenerator.new()



func _ready():
    rng.seed = coords.x * 1000 + coords.y*10000 + coords.x + coords.y 
    add_objects(Trees, 8, 15)
    
func add_objects(pscene, mini, maxi):
    for i in rng.randi_range(mini,maxi):
        var object = pscene.instance()
        object.position = Vector2(round((rng.randf()-0.5)*size),round((rng.randf()-0.5)*size))
        $YSort.add_child(object)
