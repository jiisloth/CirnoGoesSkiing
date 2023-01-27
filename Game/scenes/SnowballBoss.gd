extends Node2D

export(PackedScene) var Bullet

var pos = Vector2.ZERO
var screenSize = Vector2.ZERO
var middle = Vector2.ZERO
var moveTween = Tween.new()

var moving = true
var shooting = false
var phase2 = false

var deltaTime = 0.0
var bossHealth = 100
var movTime = 5

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
	$Sprite.rotation -= 1 * delta
	deltaTime += delta
	
	if self.position.y == middle.y-middle.y/2 and moving and deltaTime > 4.0:
		moving = false
		shooting = true
		moveTween.interpolate_property(self, "position:x", self.position.x, middle.x-middle.x/2, 3)
		moveTween.start()
		deltaTime = 0.0
	
	if self.position.x <= middle.x-middle.x/2 and shooting == true:
		print("here")
		moveTween.interpolate_property(self, "position:x", self.position.x, middle.x+middle.x/2, movTime)
	elif self.position.x >= middle.x+middle.x/2 and shooting == true:
		print("not here")
		moveTween.interpolate_property(self, "position:x", self.position.x, middle.x-middle.x/2, movTime)

	if bossHealth <= 50 and phase2 == false and shooting == true:
		shooting = false
		deltaTime = 0.0
	elif bossHealth <= 50 and phase2 == false and deltaTime > 3.0:
		shooting = true
		phase2 = true
		movTime = 3


	if deltaTime > 1.0 and shooting == true:
		if bossHealth > 50:
			bullet_phase1()
			deltaTime = 0.0
		else:
			bullet_phase2()
			deltaTime = 0.0
		bossHealth -= 1


func create_bullet(d, speed):
	var bullet = Bullet.instance()
	bullet.speed = speed
	bullet.scale *= 2
	bullet.rotation = self.rotation + deg2rad(d)
	bullet.position = self.position
	get_parent().add_child(bullet)
	bullet.moving = true
	
func bullet_phase1():
	create_bullet(90, 100)
	create_bullet(135, 100)
	create_bullet(45, 100)
	
func bullet_phase2():
	create_bullet(90, 150)
	create_bullet(90-22.5, 150)
	create_bullet(45, 150)
	create_bullet(112.5, 150)
	create_bullet(135, 150)
