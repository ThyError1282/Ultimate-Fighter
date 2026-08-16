extends Area2D

const angle_conversion = PI / 180

var parent = get_parent()
@export var width = 300
@export var height = 500
@export var damage = 50
@export var angle = 90
@export var base_kb = 100
@export var kb_scaling = 2
@export var duration = 1500
@export var hitlag_modifier = 1
@export var type = "normal"
@export var angle_flipper = 0
@export var percentage = 0
@export var weight = 100
@export var base_knockback = 40
@export var ratio = 1

@onready var hitbox = get_node("HitboxShape")
@onready var parentstate = get_parent().selfState

var knockbackval
var framez = 0.0
var player_list = []

func set_parameters(w, h, d, a, b_kb, kb_s, dur, t, p, af, hit, parent = get_parent()) -> void:
	self.position = Vector2(0,0)
	player_list.append(parent)
	player_list.append(self)
	width = w
	height = h
	damage = d
	angle = a
	base_kb = b_kb
	kb_scaling = kb_s
	duration = dur
	type = t
	self.position = p
	hitlag_modifier = hit
	angle_flipper = af
	update_extents()
	set_physics_process(true)

func _on_hitbox_collide(body):
	if !(body in player_list):
		player_list.append(body)
		var charstate
		charstate = body.get_node("StateMachine")
		weight = body.weight
		body.percentage += damage
		knockbackval = knockback(body.percentage, damage, weight, kb_scaling, base_kb, 1)
		s_angle(body)
		charstate.state = charstate.states.HITFREEZE
		charstate.hitfreeze(hitlag(damage, hitlag_modifier), angle_flip_2(Vector2(body.velocity.x, body.velocity.y), body.global_position))
		body.knockback = knockbackval
		body.hitstun = get_hitstun(knockbackval / 0.3)
		get_parent().connected = true
		body.reset_frame()
		
		Globals.hitstun(hitlag(damage, hitlag_modifier), hitlag(damage, hitlag_modifier) / 60)
		get_parent().hit_pause_dur = duration - framez
		get_parent().temp_pos = get_parent().position
		get_parent().temp_vel = get_parent().velocity

func update_extents() -> void:
	hitbox.shape.extents = Vector2(width, height)

func _ready() -> void:
	hitbox.shape = RectangleShape2D.new()
	set_physics_process(false)
	pass

func _physics_process(delta: float) -> void:
	if framez < duration:
		framez += 1
	elif framez == duration:
		queue_free()
		return
	if get_parent().selfState != parentstate:
		Engine.time_scale = 1
		queue_free()
		return

func get_hitstun(knockback):
	return floor(knockback * 0.4)

func hitlag(d, hit):
	damage = d
	hitlag_modifier = hit
	return floor((((floor(d) * 0.65) + 6) * hit))

func knockback(p, d, w, ks, bk, r):
	percentage = p
	damage = d
	weight = w
	kb_scaling = ks
	base_kb = bk
	ratio = r
	return ((((((((percentage / 10) + (percentage * damage / 20)) * (200 / (weight + 100)) * 1.4) + 18) * (kb_scaling)) + base_kb) * 1 )) * 0.004

func s_angle(body):
	if angle == 361:
		if knockbackval > 28:
			if !body.is_on_floor() == true:
				angle = 40
			else:
				angle = 38
		else:
			if !body.is_on_floor() == true:
				angle = 40
			else:
				angle = 25
	elif angle == -181:
		if knockbackval > 28:
			if !body.is_on_floor() == true:
				angle = 140
			else:
				angle = 142
		else:
			if !body.is_on_floor() == true:
				angle = 140
			else:
				angle = 155

func get_horizontal_decay(angle):
	var decay = 0.051 * cos(angle * angle_conversion)
	decay = round(decay * 100000) / 100000
	decay = decay * 1000
	return decay

func get_vertical_decay(angle):
	var decay = 0.051 * sin(angle * angle_conversion)
	decay = round(decay * 100000) / 100000
	decay = decay * 1000
	return abs(decay)

func get_horizontal_velocity(knockback, angle):
	var initial_velocity = knockback * 30
	var horizontal_angle = cos(angle * angle_conversion)
	var horizontal_velocity = initial_velocity * horizontal_angle
	horizontal_velocity = round(horizontal_velocity * 100000) / 100000
	return horizontal_velocity

func get_vertical_velocity(knockback, angle):
	var initial_velocity = knockback * 30
	var vertical_angle = sin(angle * angle_conversion)
	var vertical_velocity = initial_velocity * vertical_angle
	vertical_velocity = round(vertical_velocity * 100000) / 100000
	return vertical_velocity

func angle_flip(body):
	var xangle
	if get_parent().direction() == -1:
		xangle = -((((body.global_position.angle_to_point(get_parent().global_position)) * 180) / PI))
	else:
		xangle = ((((body.global_position.angle_to_point(get_parent().global_position)) * 180) / PI))
	match angle_flipper:
		0:
			body.velocity.x = (get_horizontal_velocity(knockbackval, -angle))
			body.velocity.y = (get_vertical_velocity(knockbackval, -angle))
			body.hdecay = (get_horizontal_decay(angle + 180))
			body.vdecay = (get_vertical_decay(-angle))
		1:
			if get_parent().direction() == -1:
				xangle = -(((self.global_position.angle_to_point(body.get_parent().global_position)) * 180) / PI)
			else:
				xangle = (((self.global_position.angle_to_point(body.get_parent().global_position)) * 180) / PI)
			body.velocity.x = (get_horizontal_velocity(knockbackval, xangle + 180))
			body.velocity.y = (get_vertical_velocity(knockbackval, -xangle))
			body.hdecay = (get_horizontal_decay(angle + 180))
			body.vdecay = (get_vertical_decay(xangle))
		2:
			if get_parent().direction() == -1:
				xangle = -((((body.global_position.angle_to_point(self.global_position)) * 180) / PI))
			else:
				xangle = ((((body.global_position.angle_to_point(self.global_position)) * 180) / PI))
			body.velocity.x = (get_horizontal_velocity(knockbackval, -xangle + 180))
			body.velocity.y = (get_vertical_velocity(knockbackval, -xangle))
			body.hdecay = (get_horizontal_decay(xangle + 180))
			body.vdecay = (get_vertical_decay(xangle))
		3:
			if get_parent().direction() == -1:
				xangle = -((((body.global_position.angle_to_point(self.global_position)) * 180) / PI)) + 180
			else:
				xangle = ((((body.global_position.angle_to_point(self.global_position)) * 180) / PI))
			body.velocity.x = (get_horizontal_velocity(knockbackval, xangle))
			body.velocity.y = (get_vertical_velocity(knockbackval, -angle))
			body.hdecay = (get_horizontal_decay(xangle))
			body.vdecay = (get_vertical_decay(xangle))
		4:
			if get_parent().direction() == -1:
				xangle = -((((body.global_position.angle_to_point(self.global_position)) * 180) / PI)) + 180
			else:
				xangle = ((((body.global_position.angle_to_point(self.global_position)) * 180) / PI))
			body.velocity.x = (get_horizontal_velocity(knockbackval, -xangle + 180))
			body.velocity.y = (get_vertical_velocity(knockbackval, -angle))
			body.hdecay = (get_horizontal_decay(angle))
			body.vdecay = (get_vertical_decay(angle))
		5:
			body.velocity.x = (get_horizontal_velocity(knockbackval, angle + 180))
			body.velocity.y = (get_vertical_velocity(knockbackval, -angle))
			body.hdecay = (get_horizontal_decay(angle + 180))
			body.vdecay = (get_vertical_decay(angle))
		6:
			body.velocity.x = (get_horizontal_velocity(knockbackval, xangle))
			body.velocity.y = (get_vertical_velocity(knockbackval, -angle))
			body.hdecay = (get_horizontal_decay(xangle))
			body.vdecay = (get_vertical_decay(angle))
		7:
			body.velocity.x = (get_horizontal_velocity(knockbackval, -xangle + 180))
			body.velocity.y = (get_vertical_velocity(knockbackval, -angle))
			body.hdecay = (get_horizontal_decay(angle))
			body.vdecay = (get_vertical_decay(angle))

func angle_flip_2(body_vel: Vector2, body_position: Vector2, hdecay = 0, vdecay = 0):
	var xangle
	if get_parent().direction() == -1:
		xangle = -((((body_position.angle_to_point(get_parent().global_position)) * 180) / PI))
	else:
		xangle = ((((body_position.angle_to_point(get_parent().global_position)) * 180) / PI))
	match angle_flipper:
		0:
			body_vel.x = (get_horizontal_velocity(knockbackval, -angle))
			body_vel.y = (get_vertical_velocity(knockbackval, -angle))
			hdecay = (get_horizontal_decay(-angle))
			vdecay = (get_vertical_decay(angle))
			return ([body_vel.x, body_vel.y, hdecay, vdecay])
		1:
			if get_parent().direction() == -1:
				xangle = -(((self.global_position.angle_to_point(body_position)) * 180) / PI)
			else:
				xangle = (((self.global_position.angle_to_point(body_position)) * 180) / PI)
			body_vel.x = (get_horizontal_velocity(knockbackval, xangle + 180))
			body_vel.y = (get_vertical_velocity(knockbackval, -xangle))
			hdecay = (get_horizontal_decay(angle + 180))
			vdecay = (get_vertical_decay(xangle))
			return ([body_vel.x, body_vel.y, hdecay, vdecay])
		2:
			if get_parent().direction() == -1:
				xangle = -((((body_position.angle_to_point(self.global_position)) * 180) / PI))
			else:
				xangle = ((((body_position.angle_to_point(self.global_position)) * 180) / PI))
			body_vel.x = (get_horizontal_velocity(knockbackval, -xangle + 180))
			body_vel.y = (get_vertical_velocity(knockbackval, -xangle))
			hdecay = (get_horizontal_decay(xangle + 180))
			vdecay = (get_vertical_decay(xangle))
			return ([body_vel.x, body_vel.y, hdecay, vdecay])
		3:
			if get_parent().direction() == -1:
				xangle = -((((body_position.angle_to_point(self.global_position)) * 180) / PI)) + 180
			else:
				xangle = ((((body_position.angle_to_point(self.global_position)) * 180) / PI))
			body_vel.x = (get_horizontal_velocity(knockbackval, xangle))
			body_vel.y = (get_vertical_velocity(knockbackval, -angle))
			hdecay = (get_horizontal_decay(xangle))
			vdecay = (get_vertical_decay(xangle))
			return ([body_vel.x, body_vel.y, hdecay, vdecay])
		4:
			if get_parent().direction() == -1:
				xangle = -((((body_position.angle_to_point(self.global_position)) * 180) / PI)) + 180
			else:
				xangle = ((((body_position.angle_to_point(self.global_position)) * 180) / PI))
			body_vel.x = (get_horizontal_velocity(knockbackval, -xangle + 180))
			body_vel.y = (get_vertical_velocity(knockbackval, -angle))
			hdecay = (get_horizontal_decay(angle))
			vdecay = (get_vertical_decay(angle))
			return ([body_vel.x, body_vel.y, hdecay, vdecay])
		5:
			body_vel.x = (get_horizontal_velocity(knockbackval, angle + 180))
			body_vel.y = (get_vertical_velocity(knockbackval, -angle))
			hdecay = (get_horizontal_decay(angle + 180))
			vdecay = (get_vertical_decay(angle))
			return ([body_vel.x, body_vel.y, hdecay, vdecay])
		6:
			body_vel.x = (get_horizontal_velocity(knockbackval, xangle))
			body_vel.y = (get_vertical_velocity(knockbackval, -angle))
			hdecay = (get_horizontal_decay(xangle))
			vdecay = (get_vertical_decay(angle))
			return ([body_vel.x, body_vel.y, hdecay, vdecay])
		7:
			body_vel.x = (get_horizontal_velocity(knockbackval, -xangle + 180))
			body_vel.y = (get_vertical_velocity(knockbackval, -angle))
			hdecay = (get_horizontal_decay(angle))
			vdecay = (get_vertical_decay(angle))
			return ([body_vel.x, body_vel.y, hdecay, vdecay])
