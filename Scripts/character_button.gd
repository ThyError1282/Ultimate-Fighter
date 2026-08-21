extends TextureButton

@export var character: String = "FOX"
@export var normal_texture: Texture
@export var pressed_texture: Texture
@onready var character_area: Area2D = $CharacterArea

var id

signal character_selected(character, child, id)
signal character_deselected(character, child, id)

signal character_hovered(character, child, id)
signal character_dehovered(character, child, id)

func on_character_button_down():
	set_texture_normal(pressed_texture)
	set_modulate(Color(1.1, 1.1, 1.1, 1.1))
	emit_signal("character_selected", character, self, id)

func on_character_button_up():
	set_texture_normal(normal_texture)
	set_modulate(Color(1.1, 1.1, 1.1, 1.1))
	emit_signal("character_deselected", character, self, id)

func on_character_mouse_entered():
	emit_signal("character_hovered", character, self, id)

func on_character_mouse_exited():
	emit_signal("character_dehovered", character, self, id)

func on_area_2d_area_entered(area):
	if area.name == "TokenArea":
		self.id = area.get_parent().id
		emit_signal("character_hovered", character, self, id)
		if area.get_parent().picked == false:
			emit_signal("button_down")

func on_area_2d_area_exited(area):
	if area.name == "TokenArea":
		self.id = area.get_parent().id
		if area.get_parent().picked == true:
			emit_signal("button_up")
