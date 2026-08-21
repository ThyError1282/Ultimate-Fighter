@tool
extends Control

@export var id: int
@onready var full: TextureRect = $Full
@onready var hover: TextureRect = $Hover
@onready var character_name: Label = %CharacterName
@onready var background: ColorRect = $Background
@onready var color_rect: ColorRect = $BottomText/ColorRect

signal char_ready(character, id)
signal char_unready(character, id)

@export var FOX: Texture

@export var banner_color: Color = Color(1, 0, 0):
	get:
		return banner_color
	set(value):
		banner_color = value
		if is_instance_valid(color_rect):
			color_rect.color = banner_color

@export var bg_color: Color = Color(1, 0, 0.086, 0.243):
	get:
		return bg_color
	set(value):
		bg_color = value
		if is_instance_valid(background):
			background.color = bg_color

func _ready() -> void:
	color_rect.color = banner_color
	background.color = bg_color

func _on_character_hovered(character, child, id):
	if self.id == id:
		match character:
			"FOX":
				character = FOX
				hover.texture = FOX
				full.visible = false
				full.texture = FOX
				character_name.text = "FOX"

func _on_character_selected(character, child, id):
	if self.id == id:
		match character:
			"FOX":
				character = FOX
				hover.visible = false
				full.visible = true
				emit_signal("char_ready", "FOX", id)

func _on_character_deselected(character, child, id):
	if self.id == id:
		match character:
			"FOX":
				character = FOX
				hover.visible = true
				full.visible = false
				emit_signal("char_unready", "FOX", id)
