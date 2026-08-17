extends CharacterBody2D

# Onready variables
@onready var sprite: AnimatedSprite2D = $Sprite
@onready var frames: Label = $Frames
@onready var state: Label = $State
@onready var health: Label = $Health
@onready var GroundL: RayCast2D = $Raycasts/GroundL
@onready var GroundR: RayCast2D = $Raycasts/GroundR
@onready var Ledge_Grab_F: RayCast2D = $Raycasts/LedgeGrabF
@onready var Ledge_Grab_B: RayCast2D = $Raycasts/LedgeGrabB
@onready var animation_player: AnimationPlayer = $Sprite/AnimationPlayer
@onready var gun_pos: Marker2D = $GunPos
@onready var hurtbox: CollisionShape2D = %Hurtbox
@onready var parrybox: CollisionShape2D = %Parrybox

# Attributes
@export var percentage = 0
@export var stocks = 3
@export var weight = 100
var freezeframes = 0

# Buffers
var l_cancel = 0
var cooldown = 0
var shield_buffer = 0

# Knockback
var hdecay
var vdecay
var knockback
var hitstun
var connected: bool

# Hitbox variables
@export var hitbox: PackedScene
@export var projectile: PackedScene
@export var grabbox: PackedScene
var selfState

# Temp variables
var hit_pause = 0
var hit_pause_dur = 0
var temp_pos = Vector2(0,0)
var temp_vel = Vector2(0,0)

# Attacks
var projectile_cooldown = 0
var grabbing = false

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

func create_grabbox(width, height, damage, duration, points):
	var grabbox_instance = grabbox.instantiate()
	self.add_child(grabbox_instance)
	if direction() == 1:
		grabbox_instance.set_parameters(width, height, damage, duration, points)
	else:
		var flip_x_points = Vector2(-points.x, points.y)
		grabbox_instance.set_parameters(width, height, damage, duration, flip_x_points)
	return grabbox_instance

func create_projectile(dir_x, dir_y, point):
	var projectile_instance = projectile.instantiate()
	projectile_instance.player_list.append(self)
	get_parent().add_child(projectile_instance)
	gun_pos.set_position(point)
	if direction() == 1:
		projectile_instance.dir(dir_x, dir_y)
		projectile_instance.set_global_position(gun_pos.get_global_position())
	else:
		gun_pos.position.x = -gun_pos.position.x
		projectile_instance.dir(-dir_x, dir_y)
		projectile_instance.set_global_position(gun_pos.get_global_position())
	return projectile_instance

func update_frames(delta) -> void:
	frame += floor(delta * 60)
	l_cancel -= floor(delta * 60)
	clamp(l_cancel, 0, l_cancel)
	cooldown += floor(delta * 60)
	cooldown = clamp(cooldown, cooldown, 0)
	if not Input.is_action_pressed("shield_%s" % id):
		shield_buffer = 0
	elif Input.is_action_pressed("shield_%s" % id):
		shield_buffer += floor(delta * 60)
	if freezeframes > 0:
		freezeframes -= floor(delta * 60)
	freezeframes = clamp(freezeframes, 0, freezeframes)

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
	health.text = str(100 - percentage)
	selfState = state.text
	death_check()

func death_check():
	if percentage >= 100:
		queue_free()
	else:
		return

func pause(delta):
	if hit_pause < hit_pause_dur:
		self.position = temp_pos
		hit_pause += floor((1 * delta) * 60)
	else:
		if temp_vel != Vector2(0, 0):
			self.velocity.x = temp_vel.x
			self.velocity.y = temp_vel.y
			temp_vel = Vector2(0, 0)
		hit_pause_dur = 0
		hit_pause = 0

# Special attacks
func neutral_special():
	if frame == 4:
		create_projectile(1, 0, Vector2(50, 0))
	if frame == 14:
		return true

# Tilt attacks
func jab():
	if frame == 2:
		create_grabbox(30, 40, 0, 3, Vector2(64, 0))
	if frame == 5:
		if grabbing == true:
			return false
	if frame >= 20:
		return true

func jab_1():
	if frame == 1:
		grabbing = false
		create_grabbox(30, 40, 0, 13, Vector2(64, 0))
	if frame == 12:
		create_hitbox(40, 20, 8, 90, 8800, 0, 9, "normal", Vector2(48, 8), 0, 0)
	if frame >= 32:
		return true

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
