extends Area2D
@export var sprite: Sprite2D
@export var textures: Array[Texture2D]
var damage = 0
const MAX_DAMAGE = 3

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.area_entered.connect(on_area_entered)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func on_area_entered(area):
	if area is Laser || area is enemyLaser:
		area.queue_free()
		if damage < MAX_DAMAGE:
			damage += 1
			sprite.texture = textures[damage-1]
		else:
			queue_free()
	if area is Invader:
		queue_free()
