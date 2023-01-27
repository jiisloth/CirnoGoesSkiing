extends YSort

var coords = Vector2.ZERO
var size = 800

export(PackedScene) var Trees

export(PackedScene) var Rocks

export(PackedScene) var Ramp


var rng = RandomNumberGenerator.new()


func _ready():
    rng.seed = coords.x * 1000 + coords.y*10000 + coords.x + coords.y 
    add_objects(Trees, 3, 10)
    add_objects(Rocks, 3, 8)
    add_objects(Ramp, -2, 15)
    
func add_objects(pscene, mini, maxi):
    for i in rng.randi_range(mini,maxi):
        var object = pscene.instance()
        object.position = Vector2(round((rng.randf()-0.5)*size),round((rng.randf()-0.5)*size))
        add_child(object)
