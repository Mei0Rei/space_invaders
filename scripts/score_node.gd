extends Node
class_name Score
signal score_change(points: int)
@export var score = 0
@onready var invader_spawner: InvaderSpawner = $"../InvaderSpawner"
@onready var ufo_spawner: Node2D = $"../UFOSpawner"
@onready var score_text: Label = $"../GameDisplay/Control/MarginContainer/ScoreDisplay/ScoreText"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	invader_spawner.inv_destroyed.connect(increaseScore)
	ufo_spawner.s_ufo_destroyed.connect(increaseScore)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func increaseScore(points: int):
	score += points
	Globals.total_score = score
	# print("Score = ",score)
	var text_score = str(score)
	score_text.set_text(text_score) # this has a slight lag but
	# seems to work fine asides from that
