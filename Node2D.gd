extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text
var test = Polygon2D.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	test.draw_rect(Rect2(Vector2(30, 30), Vector2(600, 600)), Color.yellow)
	add_child(test)
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
