extends CharacterBody2D

# Onready Variables
@onready var sprite: AnimatedSprite2D = $Sprite
@onready var frames: Label = $Frames
@onready var state: Label = $State
@onready var GroundL: RayCast2D = $Raycasts/GroundL
@onready var GroundR: RayCast2D = $Raycasts/GroundR
@onready var Ledge_Grab_F: RayCast2D = $Raycasts/LedgeGrabF
@onready var Ledge_Grab_B: RayCast2D = $Raycasts/LedgeGrabB
@onready var animation_player: AnimationPlayer = $Sprite/AnimationPlayer

# Ground variables
var move_velocity = Vector2(0,0)
var dash_duration = 15

# Landing variables
var landing_frames = 10
var lag_frames = 5
var perfect_wavedash_modifier = .67

# Air variables
var jump_squat = 3
var fastfall = false
var air_jump = 0
@export var air_jump_max = 1

# Ledge variables
var last_ledge = false
var regrab = 30
var catch = false

# Main Attributes
var RUNSPEED = 340
var DASHSPEED = 390
var WALKSPEED = 200
var GRAVITY = 1000
var JUMPFORCE = 500
var MAX_JUMPFORCE = 900
var DOUBLEJUMPFORCE = 1000
var MAXAIRSPEED = 300
var AIR_ACCEL = 25
var FALLSPEED = 60
var FALLINGSPEED = 900
var MAXFALLSPEED = 900
var TRACTION = 40
var ROLL_DISTANCE = 350
var AIR_DODGE_SPEED = 500
var UP_B_LAUNCHSPEED = 700

# Global Variable
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
	Ledge_Grab_F.target_position = Vector2(dir * abs(Ledge_Grab_F.target_position.x), Ledge_Grab_F.target_position.y)
	Ledge_Grab_F.position.x = dir * abs(Ledge_Grab_F.position.x)
	Ledge_Grab_B.position.x = dir * abs(Ledge_Grab_B.position.x)
	Ledge_Grab_B.target_position = Vector2(-dir * abs(Ledge_Grab_F.target_position.x), Ledge_Grab_F.target_position.y)

func direction():
	if Ledge_Grab_F.target_position.x > 0:
		return 1
	else:
		return -1

func reset_frame() -> void:
	frame = 0

func reset_jumps():
	air_jump = air_jump_max

func reset_ledge() -> void:
	last_ledge = false

func play_animation(name) -> void:
	animation_player.play(name)

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	frames.text = str(frame)
