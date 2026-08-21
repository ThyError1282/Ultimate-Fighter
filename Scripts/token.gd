extends RigidBody2D

@onready var label: Label = $Label
@onready var token_area: Area2D = $TokenArea

@export var id = 0
@export var min_dist = 100
@export var text_color: Color:
	get:
		return text_color
	set(value):
		text_color = value
		if is_instance_valid(label):
			label.modulate = text_color

var rest_point
var rest_positions
var is_colliding = false
var picked = false

func player_pos():
	var pos
	match id:
		1:
			pos = Globals.css["token_1_pos"]
			return pos
		2:
			pos = Globals.css["token_2_pos"]
			return pos

func _ready() -> void:
	label.modulate = text_color
	rest_positions = get_tree().get_nodes_in_group("CharSelect")
	rest_point = player_pos()
	label.text = ("P" + str(id))

func _physics_process(delta: float) -> void:
	Globals.css["token_%s_pos" % id] = self.global_position
	if picked == true:
		global_position = get_node("../Hand%s/Marker2D" % id).global_position
	else:
		global_position = lerp(global_position, rest_point, 5 * delta)

func auto_snap():
	for child in rest_positions:
		var distance = self.global_position.distance_to(child.get_node("Point").global_position)
		if distance < min_dist:
			rest_point = child.get_node("Point").global_position
	if picked == false:
		var dec = token_area.get_overlapping_areas()
		for b in dec:
			if b.name == "CharacterArea":
				b.get_parent().emit_signal("button_down")
