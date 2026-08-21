extends Node2D

@onready var hand_sprite: AnimatedSprite2D = %HandSprite
@onready var hand_area: Area2D = $HandArea
@onready var player: Label = %Player

@export var id: int

var velocity: Vector2
var speed = 1000
var picking = false

enum States {
	POINT,
	GRAB,
	OPEN
}

var current_state = States.OPEN

func _ready() -> void:
	player.text = "P" + str(id)

func _physics_process(delta: float) -> void:
	self.name = ("Hand%s" % id)
	match current_state:
		0:
			hand_sprite.play("Point")
			player.position = Vector2(0, 0)
		1:
			hand_sprite.play("Grab")
			player.position = Vector2(0, 0)
		2:
			hand_sprite.play("Open")
			player.position = Vector2(-27, -3)

func _process(delta: float) -> void:
	var input: Vector2 = Vector2.ZERO
	input = Vector2(Input.get_action_strength("right_%s" % id) - Input.get_action_strength("left_%s" % id), Input.get_action_strength("down_%s" % id) - Input.get_action_strength("up_%s" % id))
	global_position += input * speed * delta
	var dec = hand_area.get_overlapping_areas()
	for b in dec:
		if b.name == "ButtonArea":
			current_state = States.POINT
	if Input.is_action_just_pressed("ui_select_%s" % id):
		for b in dec:
			if b.name == "TokenArea" and b.get_parent().id == id:
				if self.picking == false:
					current_state = States.GRAB
					b.get_parent().picked = true
					self.picking = true
				else:
					current_state = States.OPEN
					b.get_parent().picked = false
					b.get_parent().rest_point = b.get_parent().global_position
					b.get_parent().auto_snap()
					self.picking = false
			elif b.name == "ButtonArea":
				b.get_parent().emit_signal("pressed")
			elif b.name == "ReadyToFight":
				if current_state == States.POINT:
					get_tree().change_scene_to_file("res://Stages/smashville.tscn")

func _on_hand_area_entered(area):
	if area.name == "ButtonArea":
		current_state = States.POINT
		var dec = hand_area.get_overlapping_areas()
		for b in dec:
			if b.name == "TokenArea" and b.get_parent().id == id and b.get_parent().picked == true:
				b.get_parent().picked = false
				b.get_parent().rest_point = b.get_parent().global_position
				b.get_parent().auto_snap()
				picking = false
	elif area.name == "ReadyToFight":
		current_state = States.POINT
		var dec = hand_area.get_overlapping_areas()
		for b in dec:
			if b.name == "TokenArea" and b.get_parent().id == id and b.get_parent().picked == true:
				b.get_parent().picked = false
				b.get_parent().rest_point = b.get_parent().global_position
				b.get_parent().auto_snap()
				picking = false

func _on_hand_area_exited(area):
	if area.name == "ButtonArea":
		current_state = States.OPEN
	elif area.name == "ReadyToFight":
		current_state = States.OPEN
