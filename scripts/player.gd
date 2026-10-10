extends Area2D
class_name Player
@export var speed = 400
var direction = Vector2.ZERO
var shipX
var startBound
var endBound
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var explosion_sprite: AnimatedSprite2D = $ExplosionSprite
signal playerDestroyed

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	shipX = collision_shape_2d.shape.get_rect().size.x

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var input = Input.get_axis("moveLeft", "moveRight")
	if input > 0:
		direction = Vector2.RIGHT
	elif input < 0:
		direction = Vector2.LEFT
	else:
		direction = Vector2.ZERO
	
	var vp = get_viewport()
	var posX = position.x + delta * direction.x * speed
	var halfWidth = sprite_2d.get_rect().size.x * sprite_2d.scale.x / 2 
	if posX > halfWidth and posX < vp.size.x - halfWidth:
		position.x = posX
	
	#var dM = speed * delta * direction.x
	#if position.x + dM < startBound + shipX * transform.get_scale().x:
		#return
	#if position.x + dM < endBound - shipX * transform.get_scale().x:
		#return
	#position.x += dM


func _on_area_entered(area: Area2D) -> void:
	# if area is enemyLaser:
	sprite_2d.visible = false
	%GunNode2D.laserOut = true
	var ship_explosion = load("res://sounds/rocket_explosion.mp3")
	%PlayerNoisemaker.stream = ship_explosion
	%PlayerNoisemaker.play()
	speed = 0 # fixes player being able to move after being shot
	explosion_sprite.visible = true
	explosion_sprite.play()
	await get_tree().create_timer(1).timeout
	playerDestroyed.emit()
	queue_free()
