extends YSort

export(PackedScene) var Chunk
export(PackedScene) var SnowBallBoss
export(PackedScene) var Mima
export(PackedScene) var Cirno
export(PackedScene) var Credits

export(PackedScene) var Death

export(PackedScene) var Dialogue


var level = 0
var goal = 30000

var seek = 0

var active_chunks = []
var noise = OpenSimplexNoise.new()

func _ready():
    $MusicController/Marisa.seek(seek)
    setup_noise()


func _process(_delta):
    if Input.is_action_just_pressed("ui_cancel"):
        if not $Player.dead:
            open_menu()
    check_chunks()
    match level:
        1:
            if $Player.position.length() > goal:
                spawn_boss(E.SNOWBALL)
                level += 1
        3:
            if $Player.position.length() > goal:
                spawn_boss(E.CIRNO)
                level += 1
        5:  
            if $Player.position.length() > goal:
                level += 1
                var credits = Credits.instance()
                add_child(credits)
                goal = 100000
        6:
                $CanvasLayer/Timer.running = true
        7:
            if Global.score > goal:
                spawn_boss(E.MIMA)
                level += 1
        9:
            if $Player.position.length() > goal:
                level += 1
                var credits = Credits.instance()
                credits.sequence = credits.TRUEEND
                add_child(credits)
    
func setup_noise():
    noise.seed = 123123
    noise.octaves = 4
    noise.period = 20.0
    noise.persistence = 0.8
    

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
    chunk.foresty = noise.get_noise_2d(coords.x,coords.y)
    chunk.rocky = noise.get_noise_2d(coords.x*1.5,-coords.y*1.5-5)
    chunk.position = coords*800
    chunk.slope = get_closest_slope(coords)
    $Chunks.add_child(chunk)
    
            
func get_chunky_position(node):
    return Vector2(round(node.global_position.x / 800),round(node.global_position.y / 800))

func get_closest_slope(pos):
    var slopedist = 12
    var slope = INF
    for i in 3:
        var s = pos.x - get_slope(pos + Vector2(i-1,0)*(slopedist/2), slopedist)
        if abs(s) < abs(slope):
            slope = s
    return slope
    
func get_slope(pos, slopedist):
    var y = pos.y
    var x = round(pos.x/slopedist)*slopedist
    var slopepos = -2 + x + sin((y+x+10)/5.0)+sin((y+10)/10.0)*3+sin((y-10)/8.0)*1.2+sin((y-10)/3)+sin(y-10)*0.2
    return slopepos#-int(pos.x)%(slopedist/2)
    

func died():
    level = -level
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

func end_tutorial():
    goal = $Player.position.length() + 25000
    level += 1
                
 
func boss_died(who):
    var wait = 4
    $MusicController.turn_down(wait)
    yield(get_tree().create_timer(wait), "timeout")
    $MusicController.play(E.MARISA)
    match who:
        E.SNOWBALL:
            Global.score += 5000
            level += 1
            goal = $Player.position.length() + 12000
        E.CIRNO:
            Global.score += 20000
            level += 1
            goal = $Player.position.length() + 1000
            $CanvasLayer/Timer.running = false
        E.MIMA:
            Global.score += 69000
            level += 1
            goal = $Player.position.length() + 500
            $CanvasLayer/Timer.running = false


func continue_game():
    $MusicController.turn_down(1)
    $MusicController.play(E.MARISA)
    $Player.continue_game()
    Global.score = floor(Global.score * 0.075)*10
    for boss in get_tree().get_nodes_in_group("Boss"):
        boss.get_parent().queue_free()
    for bullet in get_tree().get_nodes_in_group("Bossbullet"):
        bullet.queue_free()
    level = -level
    match level:
        2:
            level -= 1
            goal = $Player.position.length() + 1000
        4:
            level -= 1
            goal = $Player.position.length() + 1000
        8:  
            level -= 1
            goal = $Player.position.length() + 1000
    
func open_menu():
    $CanvasLayer/Menu.show()
    $CanvasLayer/Menu/Menu/Resume.grab_focus()
    get_tree().paused = true
