extends Label

@export var minutes = 1
@export var seconds = ":30"

func _ready() -> void:
	minutes = Globals.css["time"]
	set_text(str(Globals.css["time"]) + seconds)

func decrease():
	if minutes == 1:
		minutes = 60
		Globals.css["time"] = minutes
		self.text = str((Globals.css["time"])) + seconds
	elif minutes <= 10:
		self.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		minutes -= 1
		Globals.css["time"] = minutes
		self.text = str((Globals.css["time"])) + seconds
	elif minutes > 9:
		self.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		minutes -= 1
		Globals.css["time"] = minutes
		self.text = str((Globals.css["time"])) + seconds

func increase():
	if minutes == 60:
		minutes = 1
		Globals.css["time"] = minutes
		self.text = str((Globals.css["time"])) + seconds
	elif minutes <= 10:
		self.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		minutes += 1
		Globals.css["time"] = minutes
		self.text = str((Globals.css["time"])) + seconds
	elif minutes > 9:
		self.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		minutes += 1
		Globals.css["time"] = minutes
		self.text = str((Globals.css["time"])) + seconds
