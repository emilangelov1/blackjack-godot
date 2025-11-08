extends Button


func _ready() -> void:
	pressed.connect(onPressed)


func onPressed():
	Singleton.hit()
