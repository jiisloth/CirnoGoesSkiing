extends YSort

export(PackedScene) var Chunk
export(PackedScene) var SnowBallBoss
export(PackedScene) var Mima

var level = 0
var goal = 10000

func _process(delta):
    check_chunks()
    match level:
        0:
            if $Player.position.length() > goal:
                spawn_boss("snowball")
                level += 1
        2:
            if $Player.position.length() > goal:
                spawn_boss("cirno")
                level += 1
        4:
            if $Player.position.length() > goal:
                spawn_boss("mima")
                level += 1
    
var active_chunks = []

func check_chunks():
    var ppos = get_chunky_position($Player)
    var active = []
    for x in range(-2,3):
        for y in range(-2,3):
            var current = ppos+Vector2(x,y)
            if not current in active_chunks:
                generate_chunk(current)
            active.append(current)
    for chunk in $Chunks.get_children():
        if not chunk.coords in active:
            chunk.queue_free()
    active_chunks = active
            
func generate_chunk(coords):
    var chunk = Chunk.instance()
    chunk.coords = coords
    chunk.position = coords*800
    $Chunks.add_child(chunk)
            
func get_chunky_position(node):
    return Vector2(round(node.global_position.x / 800),round(node.global_position.y / 800))
    


func spawn_boss(who):
    var wait = 4
    $MusicController.turn_down(wait)
    yield(get_tree().create_timer(wait), "timeout")
    $MusicController.play(who)
    match who:
        "snowball":
            var boss = SnowBallBoss.instance()
            add_child(boss)
        "mima":
            var boss = Mima.instance()
            add_child(boss)
            
 
func boss_died(who):
    var wait = 4
    $MusicController.turn_down(wait)
    yield(get_tree().create_timer(wait), "timeout")
    $MusicController.play("marisa")
    match who:
        "snowball":
            level += 1
            goal = $Player.position.y + 10000

