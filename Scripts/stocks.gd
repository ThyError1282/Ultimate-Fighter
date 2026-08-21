extends Label

@export var stocks = 4

func _ready() -> void:
	stocks = Globals.css["stocks"]
	set_text(str(Globals.css["stocks"]))

func decrease():
	if stocks == 1:
		stocks = 99
		Globals.css["stocks"] = stocks
		self.text = str(Globals.css["stocks"])
	elif stocks <= 10:
		self.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		stocks -= 1
		Globals.css["stocks"] = stocks
		self.text = str(Globals.css["stocks"])
	elif stocks > 9:
		self.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		stocks -= 1
		Globals.css["stocks"] = stocks
		self.text = str(Globals.css["stocks"])

func increase():
	if stocks == 99:
		stocks = 1
		Globals.css["stocks"] = stocks
		self.text = str(Globals.css["stocks"])
	elif stocks <= 10:
		self.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		stocks += 1
		Globals.css["stocks"] = stocks
		self.text = str(Globals.css["stocks"])
	elif stocks > 9:
		self.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		stocks += 1
		Globals.css["stocks"] = stocks
		self.text = str(Globals.css["stocks"])
