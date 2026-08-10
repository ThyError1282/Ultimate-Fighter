extends CharacterBody2D

@onready var sprite: AnimatedSprite2D = $Sprite
@onready var frames: Label = $Frames
@onready var state: Label = $State

var move_velocity = Vector2(0,0)
var dash_duration = 10

var RUNSPEED = 340
var DASHSPEED = 390
var WALKSPEED = 200
var GRAVITY = 1000
var JUMPFORCE = 500
var MAX_JUMPFORCE = 800
var DOUBLE_JUMPFORCE = 1000
var MAXAIRSPEED = 300
var AIR_ACCEL = 25
var FALLSPEED = 60
var FALLINGSPEED = 900
var MAXFALLSPEED = 900
var TRACTION = 40
var ROLL_DISTANCE = 350
var AIR_DODGE_SPEED = 500
var UP_B_LAUNCHSPEED = 700

var frame = 0

func update_frames(delta) -> void:
	frame += 1

func turn(direction) -> void:
	var dir = 0
	if direction:
		dir = -1
	else:
		dir = 1
	sprite.flip_h = direction

func reset_frame() -> void:
	frame = 0

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	frames.text = str(frame)
