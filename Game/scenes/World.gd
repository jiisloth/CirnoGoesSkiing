extends Node2D

export(PackedScene) var Chunk

func _process(delta):
    check_chunks()
    
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
