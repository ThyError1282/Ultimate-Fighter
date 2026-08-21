extends Control

@onready var animation_player: AnimationPlayer = $ReadyToFightBanner/AnimationPlayer
@onready var ready_to_fight_banner: Node2D = %ReadyToFightBanner
var selected = true
var start = {
	"char_1": "",
	"char_2": ""
}

func _process(delta: float) -> void:
	Globals.css["char_1"] = start["char_1"]
	Globals.css["char_2"] = start["char_2"]
	Globals.player_1["stocks"] = Globals.css["stocks"]
	Globals.player_2["stocks"] = Globals.css["stocks"]

func ready_to_fight():
	if start["char_1"] and start["char_2"] != "":
		selected = true
		if selected == true:
			ready_to_fight_banner.visible = true
			animation_player.play("ready")
			selected = false
	else:
		if selected == false:
			animation_player.play("not_ready")
		selected = true

func _on_player_1_char_ready(character, id):
	start["char_1"] = character
	ready_to_fight()

func _on_player_2_char_ready(character, id):
	start["char_2"] = character
	ready_to_fight()

func _on_player_1_char_unready(character, id):
	start["char_1"] = ""
	ready_to_fight()

func _on_player_2_char_unready(character, id):
	start["char_2"] = ""
	ready_to_fight()
