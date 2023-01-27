extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var pos = Vector2.ZERO
var screenSize = Vector2.ZERO
var middle = Vector2.ZERO
var moveTween = Tween.new()
var moving = true

# Called when the node enters the scene tree for the first time.
func _ready():
	#hide()
	screenSize = get_viewport().get_visible_rect().size
	middle = screenSize / 2
	self.position = get_start_pos()
	
	add_child(moveTween)
	moveTween.interpolate_property(self, "position:y", self.position.y, middle.y-middle.y/2, 3)
	moveTween.start()


func get_start_pos():
	var start_pos = middle
	start_pos[1] = -50
	return start_pos


func _process(delta):
	$Sprite.rotation += 1 * delta
	
	if self.position.y == middle.y-middle.y/2 and moving:
		moving = false
		moveTween.interpolate_property(self, "position:x", self.position.x, middle.x-middle.x/2, 3)
	
	if self.position.x == middle.x-middle.x/2:
		moveTween.interpolate_property(self, "position:x", self.position.x, middle.x+middle.x/2, 5)
	elif self.position.x == middle.x+middle.x/2:
		moveTween.interpolate_property(self, "position:x", self.position.x, middle.x-middle.x/2, 5)
