@tool
@icon("res://addons/AIdot/Res/UI/key_icon.png")
extends HTTPRequest
class_name AIAPI
## AIAPI abstract base class, used to encapsulate Godot's HTTP interface, containing commonly 
## used API methods.

## The model used by the API.
@export var model : BaseModel = null

## Reply signal contains a parsed reply string or error message Dictionary for debug. 
signal response_debug(debug : Dictionary, requset_id : int)
## Reply signal contains a parsed reply string or error String and debug Dictionary.
signal response(answer : String, debug : Dictionary, requset_id : int)

func _init(mod : BaseModel = null, time_out : int = 10):
	model = mod
	timeout = time_out

# 标准化收发
var _running : bool = false
func _get_result(head : PackedStringArray, data : String, url : String = "") -> Array:
	assert(model,"API Node has no model!!!")
	if _running:
		return [false, "API Node is busy."]
	_running = true
	_retry_times = 0
	if url.is_empty():
		url = model.api_url
	var response : String = await _request_retry(head, data, url)
	_running = false
	if "Error:" in response:
		return [false, response]
	else:
		var json_result = JSON.parse_string(response)
		return [true, json_result]
# 重试方法
## Max retry. 
var RETRY_ATTEMPTS = 5
var _retry_times : int = 0
## The state of attempting to retry. Default is [429, 500, 502, 503, 504]
var status_list = [429, 500, 502, 503, 504]
func _request_retry(head : PackedStringArray, data : String, url : String) -> String:
	# 建立请求
	var error = request(url, head, HTTPClient.METHOD_POST, data)
	if error != OK:
		return "Error: " + error_string(error)
	
	# 发起成功
	var received = await request_completed
	if received[0] != 0:
		return "Error: " + ClassDB.class_get_enum_constants("HTTPRequest", "Result")[received[0]]
	
	# 重试策略
	if _retry_times > RETRY_ATTEMPTS:
		return "Error: Retry count exceeded"
	elif received[1] != 200 and status_list.has(received[1]) and _retry_times <= RETRY_ATTEMPTS:
		_retry_times += 1
		await get_tree().create_timer(2 ** (_retry_times - 1)).timeout
		return await _request_retry(head, data, url)
	elif received[1] == 200:
		var result : String = received[3].get_string_from_utf8()
		if "error" in result:
			return "APIError: " + result
		else:
			return result
	else:
		return "Error: Unknown error. Status:" + str(received[1]) + received[3].get_string_from_utf8()
