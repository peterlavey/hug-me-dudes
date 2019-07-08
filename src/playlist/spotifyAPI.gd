class_name SpotifyAPI extends HTTPRequest

var http = HTTPClient.new()

func _init():
	connect("request_completed", self, "qweqwe")	
	request("http://www.mocky.io/v2/5185415ba171ea3a00704eed")

func qweqwe(result, response_code, headers, body):
	print("erwerwer")