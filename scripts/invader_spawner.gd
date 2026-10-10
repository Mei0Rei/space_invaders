extends Node2D
class_name InvaderSpawner
const HORIZSPACE = 32
const VERTSPACE = 32
const STARTY = 50
const START_X = 200
const INVADERPOSX = 10
const INVADERPOSY = 20
const INVADER_WIDTH = 24
#var c_spawn_position = 50
var rows = 1 # 5
var cols = 1 # 10
var first_round = true
var movedirection = 1
var invader = preload("uid://dglr23iebb666")
var invaderLaser = preload("res://scenes/enemy_laser.tscn")
var destroyedInvaderCount = 0
var totalCount = 0 #rows * cols
var spawner_pos
var aln_types: Array = [10, 20, 50]
@onready var move_timer: Timer = $MoveTimer
@onready var shoot_timer: Timer = $ShootTimer
signal inv_destroyed(points)

func _ready() -> void:
	spawner_pos = global_position
	shoot_timer.timeout.connect(shootLaser)
	move_timer.timeout.connect(moveInvaders)
	spawnInvaders()

func spawnInvader(pos:Vector2, type:int):
	var inv = invader.instantiate() as Invader
	inv.invadertype = type
	inv.global_position = pos
	add_child(inv)
	totalCount += 1
	inv.invader_destroyed.connect(onInvaderDestroyed)

func moveInvaders():
	position.x += INVADERPOSX * movedirection

func _process(_delta: float) -> void:
	pass

func _on_left_wall_area_entered(area: Area2D) -> void:
	if area is Invader:
		if movedirection == -1:
			movedirection = 1
			position.y += INVADERPOSY

func _on_right_wall_area_entered(area: Area2D) -> void:
	if area is Invader:
		if movedirection == 1:
			movedirection = -1
			position.y += INVADERPOSY

func spawnInvaders():
	%InvaderSpawner.global_position = spawner_pos
	destroyedInvaderCount = 0
	totalCount = 0
	movedirection = 1
	var screenWidth = get_viewport_rect().size.x
	var halfWidth = screenWidth / 2 - 25
	for row in rows:
		var startx = START_X
		var randomNum = randi_range(3, 6)
		if first_round == false:
			cols = randi_range(7, 12)
		for col in cols:
			var x = halfWidth - cols / 2 * 24 + col * HORIZSPACE
			if rows > 3:
				# var x = startx + (col * 24 * 1.5) + (col * HORIZSPACE)
				var y = STARTY + (row * 24 ) + (row * VERTSPACE)
				var type = 10
				if row == 0:
					type = 50
				elif row <3:
					type = 20
				spawnInvader(Vector2(x, y), type)
			elif rows == 3:
				# var x = startx + (col * 24 * 1.5) + (col * HORIZSPACE)
				var y = STARTY + (row * 24 ) + (row * VERTSPACE)
				var type = 10
				if row == 0:
					type = 50
					spawnInvader(Vector2(x, y), type)
				elif row == 1:
					type = 20
					spawnInvader(Vector2(x, y), type)
				else:
					spawnInvader(Vector2(x, y), aln_types.pick_random())
			else:
				# var x = startx + (col * 24 * 1.5) + (col * HORIZSPACE)
				var y = STARTY + (row * 24 ) + (row * VERTSPACE)
				spawnInvader(Vector2(x, y), aln_types.pick_random())
		await get_tree().create_timer(0.2).timeout
	move_timer.autostart = true
	move_timer.start()
	shoot_timer.start()
	if first_round == true:
		first_round = false
	rows = randi_range(1, 5)


func shootLaser():
	var invaderGroup = get_children().filter(func(c): return c is Invader)
	if not invaderGroup.is_empty():
		var shootInvader = invaderGroup.pick_random()
		var shot = invaderLaser.instantiate() as enemyLaser
		shot.global_position = shootInvader.global_position
		var noise = load("res://sounds/enemy_laser.mp3")
		%InvaderShootNoisemaker.stream = noise
		%InvaderShootNoisemaker.play()
		get_tree().root.add_child(shot)

func onInvaderDestroyed(points):
	inv_destroyed.emit(points)
	destroyedInvaderCount += 1
	if destroyedInvaderCount >= totalCount:
		movedirection = 0
		shoot_timer.stop()
		await get_tree().create_timer(0.5).timeout
		spawnInvaders()
