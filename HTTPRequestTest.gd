extends HTTPRequest

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	var headers = [
	"User-Agent: Pirulo/1.0 (Godot)",
	"Accept: */*"
	]
	request("http://www.mocky.io/v2/5185415ba171ea3a00704eed", headers)
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	print(json.result)
	pass # Replace with function body.
