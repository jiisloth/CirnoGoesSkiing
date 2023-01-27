extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var pos = Vector2.ZERO
var screenSize = get_viewport().get_visible_rect().size

# Called when the node enters the scene tree for the first time.
func _ready():
	#hide()
	self.position = get_start_pos()
	

	
func get_start_pos():
	var middle = screenSize / 2
	middle[1] = -50
	return middle
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
