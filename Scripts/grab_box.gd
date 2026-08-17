extends Area2D

var parent = get_parent()
@export var width = 300
@export var height = 400
@export var damage = 50
@export var duration = 1500
@export var type = "normal"
@onready var grab_box_shape: CollisionShape2D = $GrabBoxShape

var framezz = 0.0
var player_list = []
var points = []
var point

func set_parameters(w, h, d, dur, p, parent = get_parent()):
	self.position = Vector2(0, 0)
	player_list.append(parent)
	player_list.append(self)
	width = w
	height = h
	damage = d
	duration = dur
	self.position = p
	point = p
	update_extents()
	self.body_entered.connect(grab_box_collide)
	set_physics_process(true)

func grab_box_collide(body):
	if !(body in player_list):
		body.percentage += damage
		var charstate
		charstate = body.get_node("StateMachine")
		body.reset_frame()
		charstate.grabbed(get_parent().name, get_parent().get_node("StateMachine").state)
		charstate.state = charstate.states.GRABBED
		body.global_position = grab_box_shape.global_position
		body.velocity.x = 0
		body.velocity.y = 0
		player_list.append(body)
		get_parent().grabbing = true

func _ready() -> void:
	grab_box_shape.shape = RectangleShape2D.new()
	set_physics_process(false)
	pass

func update_extents():
	grab_box_shape.shape.extents = Vector2(width, height)

func _physics_process(delta: float) -> void:
	if framezz < duration:
		framezz += floor(delta * 60)
	elif framezz >= duration:
		get_parent().grabbing = false
		queue_free()
		return
