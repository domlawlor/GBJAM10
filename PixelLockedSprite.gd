extends AnimatedSprite

func _ready():
	get_parent().connect("update_position", self, "_on_update_position")

func _on_update_position(pos):
	var offsetX: float = round(pos.x) - pos.x
	var offsetY: float = round(pos.y) - pos.y
	self.offset.x = offsetX
	self.offset.y = offsetY
