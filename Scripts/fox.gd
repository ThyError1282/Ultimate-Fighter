extends CharacterBody2D

# Onready variables
@onready var sprite: AnimatedSprite2D = $Sprite
@onready var frames: Label = $Frames
@onready var state: Label = $State
@onready var GroundL: RayCast2D = $Raycasts/GroundL
@onready var GroundR: RayCast2D = $Raycasts/GroundR
@onready var Ledge_Grab_F: RayCast2D = $Raycasts/LedgeGrabF
@onready var Ledge_Grab_B: RayCast2D = $Raycasts/LedgeGrabB
@onready var animation_player: AnimationPlayer = $Sprite/AnimationPlayer

# Attributes
@export var percentage = 0
@export var stocks = 3
@export var weight = 100

# Buffers
var l_cancel = 0
var cooldown = 0

# Knockback
var hdecay
var vdecay
var knockback
var hitstun
var connected: bool

# Hitbox variables
@export var hitbox: PackedScene
var selfState

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

# Main attributes
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

# Global variable
var frame = 0
@export var id: int

func create_hitbox(width, height, damage, angle, base_kb, kb_scaling, duration, type, points, angle_flipper, hitlag = 1):
	var hitbox_instance = hitbox.instantiate()
	self.add_child(hitbox_instance)
	# Rotates points
	if direction() == 1:
		hitbox_instance.set_parameters(width, height, damage, angle, base_kb, kb_scaling, duration, type, points, angle_flipper, hitlag)
	else:
		var flip_x_points = Vector2(-points.x, points.y)
		hitbox_instance.set_parameters(width, height, damage, 180 - angle, base_kb, kb_scaling, duration, type, flip_x_points, angle_flipper, hitlag)
	return hitbox_instance

func update_frames(delta) -> void:
	frame += 1
	l_cancel -= floor(delta * 60)
	clamp(l_cancel, 0, l_cancel)
	cooldown -= floor(delta * 60)
	cooldown = clamp(cooldown, 0, cooldown)

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
	selfState = state.text

func jab():
	if frame == 11:
		create_hitbox(30, 75, 8, 90, 3, 120, 3, "normal", Vector2(-35, -11), 0, 1)
	if frame >= 24:
		return true

# Tilt attacks
func down_tilt():
	if frame == 5:
		create_hitbox(40, 20, 8, 90, 3, 120, 3, "normal", Vector2(64, 32), 0, 1)
	if frame >= 10:
		return true

func up_tilt():
	if frame == 5:
		create_hitbox(40, 60, 8, 110, 20, 110, 3, "normal", Vector2(-22, -15), 0, 1)
	if frame >= 12:
		return true

func forward_tilt():
	if frame == 3:
		create_hitbox(52, 20, 6, 120, 40, 80, 3, "normal", Vector2(22, 8), 0, 1)
	if frame >= 8:
		return true

func nair():
	if frame == 1:
		create_hitbox(56, 56, 12, 361, 0, 100, 3, "normal", Vector2(0, 0), 0, 0.4)
	if frame > 1:
		if connected == true:
			if frame == 36:
				connected = false
				return true
		else:
			if frame == 5:
				create_hitbox(46, 56, 9, 361, 0, 100, 10, "normal", Vector2(0, 0), 0, 0.1)
			if frame == 36:
				return true

func uair():
	if frame == 2:
		create_hitbox(32, 36, 5, 90, 130, 0, 2, "normal", Vector2(0, -45), 0, 1)
	if frame == 6:
		create_hitbox(56, 46, 10, 90, 20, 108, 3, "normal", Vector2(0, -48), 0, 2)
	if frame == 15:
		return true

func bair():
	if frame == 2:
		create_hitbox(52, 55, 15, 45, 1, 100, 5, "normal", Vector2(-47, 7), 6, 1)
	if frame > 1:
		if connected == true:
			if frame == 18:
				connected = false
				return true
		else:
			if frame == 7:
				create_hitbox(52, 55, 5, 45, 3, 140, 10, "normal", Vector2(-47, 7), 6, 1)
			if frame == 10:
				return true

func fair():
	if frame == 2:
		create_hitbox(35, 47, 3, 76, 10, 150, 3, "normal", Vector2(60, -7), 0, 1)
	if frame == 10:
		create_hitbox(35, 47, 3, 76, 10, 150, 3, "normal", Vector2(60, -7), 0, 1)
	if frame == 11:
		return true

func dair():
	if frame == 2:
		create_hitbox(36, 58, 2, 290, 140, 0, 2, "normal", Vector2(28, 18), 0, 1)
	if frame == 3:
		create_hitbox(36, 58, 2, 290, 140, 0, 2, "normal", Vector2(28, 18), 0, 1)
	if frame == 5:
		create_hitbox(36, 58, 2, 290, 140, 0, 2, "normal", Vector2(28, 18), 0, 1)
	if frame == 7:
		create_hitbox(36, 58, 2, 290, 140, 0, 2, "normal", Vector2(28, 18), 0, 1)
	if frame == 9:
		create_hitbox(36, 58, 2, 290, 140, 0, 2, "normal", Vector2(28, 18), 0, 1)
	if frame == 11:
		create_hitbox(36, 58, 2, 290, 140, 0, 2, "normal", Vector2(28, 18), 0, 1)
	if frame == 14:
		create_hitbox(36, 58, 4, 45, 12, 120, 2, "normal", Vector2(28, 18), 0, 1)
	if frame == 17:
		return true
