extends YSort

var coords = Vector2.ZERO
var size = 800

export(PackedScene) var Trees
export(PackedScene) var LeafTree
export(PackedScene) var Rock
export(PackedScene) var SmallRock
export(PackedScene) var Sign

export(PackedScene) var SmallRamp
export(PackedScene) var Ramp
export(PackedScene) var BigRamp

export(PackedScene) var Rough


var rng = RandomNumberGenerator.new()

var foresty = 0
var rocky = 0
var slope = 0
var slopesign = 0

var treetypes 
var rocktypes 
var ramptypes 

func _ready():
    foresty = int(clamp(foresty+0.2,0,1)*50)
    rocky = int(clamp(rocky+0.2,0,1)*20)
    var obsscale = clamp(abs(slope)*0.5-1.2, 0, 2)
    $Snow.frame = floor(clamp(abs(slope*0.8),0,2.99))
    rng.seed = coords.x * 1000 + coords.y*10000 + coords.x + coords.y + 12
    set_types()
    add_objects(treetypes, -2+int(foresty/2*obsscale), 2 + int((2 +foresty)*obsscale))
    add_objects(rocktypes, -3, 1+int((2+rocky)*obsscale))
    add_objects(ramptypes, -2, 4)
    add_objects(Rough, -2+int(obsscale*0.8), 1, true)
    if abs(slope) > 2.5 and (abs(slope) < 3.5 or rng.randf() < 0.5):
        var object = Sign.instance()
        object.position = Vector2(round((rng.randf()-0.5)*size),round((rng.randf()-0.5)*size))
        add_child(object)
        if sign(slope) > 0:
            object.get_node("Sprite").frame = 1 
        
    
    
func add_objects(stuff, mini, maxi, hasrng=false):
    for i in rng.randi_range(mini,maxi):
        var pscene = get_scene(stuff)
        var object = pscene.instance()
        object.position = Vector2(round((rng.randf()-0.5)*size),round((rng.randf()-0.5)*size))
        if hasrng:
            object.rngseed=rng.seed
        add_child(object)


func get_scene(stuff):
    if typeof(stuff) == TYPE_ARRAY:
        var item 
        var weight = -1
        for x in stuff:
            var r = rng.randf()
            if x["weight"] * r > weight:
                weight = x["weight"] * r
                item = x["obj"]
        return item
    else:
        return stuff
    
func set_types():
    treetypes = [
        {"obj": Trees, "weight": 0.6},
        {"obj": LeafTree, "weight": 0.3}
        ]
    rocktypes = [
        {"obj": Rock, "weight": 0.6},
        {"obj": SmallRock, "weight": 0.5}
        ]
    ramptypes = [
        {"obj": SmallRamp, "weight": 0.2 + max(abs(slope)-1,0)/3.0},
        {"obj": Ramp, "weight": 0.5},
        {"obj": BigRamp, "weight": 0.1}
        ]
