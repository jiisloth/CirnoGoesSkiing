extends YSort

export(PackedScene) var Chunk
export(PackedScene) var SnowBallBoss
export(PackedScene) var Mima
export(PackedScene) var Cirno
export(PackedScene) var Credits

export(PackedScene) var Death

export(PackedScene) var Dialogue


var level = 0
var goal = 25000

var seek = 0

func _ready():
    $MusicController/Marisa.seek(seek)

func _process(_delta):
    if Input.is_action_just_pressed("ui_cancel"):
        get_parent().quit_game()
    check_chunks()
    match level:
        0:
            if $Player.position.length() > goal:
                spawn_boss(E.SNOWBALL)
                level += 1
        2:
            if $Player.position.length() > goal:
                spawn_boss(E.CIRNO)
                level += 1
        4:  
            if $Player.position.length() > goal:
                level += 1
                var credits = Credits.instance()
                add_child(credits)
                goal = 100000
        6:
            if Global.score > goal:
                spawn_boss(E.MIMA)
                level += 1
        8:
            if $Player.position.length() > goal:
                level += 1
                var credits = Credits.instance()
                credits.sequence = credits.TRUEEND
                add_child(credits)
    
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
    
func died():
    level = -10
    var death = Death.instance()
    add_child(death)
    
func play_dialoque(what):
    var dialogue = Dialogue.instance()
    dialogue.diag = what
    add_child(dialogue)

func spawn_boss(who):
    var wait = 4
    $MusicController.turn_down(wait)
    yield(get_tree().create_timer(wait), "timeout")
    $MusicController.play(who)
    var boss = false
    match who:
        E.SNOWBALL:
            boss = SnowBallBoss.instance()
        E.CIRNO:
            boss = Cirno.instance()
        E.MIMA:
            boss = Mima.instance()
    if boss:
        add_child(boss)
        play_dialoque(who)
            
 
func boss_died(who):
    var wait = 4
    $MusicController.turn_down(wait)
    yield(get_tree().create_timer(wait), "timeout")
    $MusicController.play(E.MARISA)
    match who:
        E.SNOWBALL:
            Global.score += 5000
            level += 1
            goal = $Player.position.length() + 10000
        E.CIRNO:
            Global.score += 20000
            level += 1
            goal = $Player.position.length() + 1000
        E.MIMA:
            Global.score += 69000
            level += 1
            goal = $Player.position.length() + 500
