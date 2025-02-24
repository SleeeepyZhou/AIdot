extends Node

## 用户数据
const SAVEPATH = "user://data.api"
func reset():
	var access = DirAccess.open(SAVEPATH.get_base_dir())
	access.remove(SAVEPATH)
func api_save(data : Array = ["https://api.openai.com/v1/chat/completions", ""]):
	var save_data = FileAccess.open(SAVEPATH, FileAccess.WRITE)
	save_data.store_var(data)
	save_data.close()
func readsave():
	var save_data : Array = ["https://api.openai.com/v1/chat/completions", ""]
	if FileAccess.file_exists(SAVEPATH):
		var data = FileAccess.open(SAVEPATH, FileAccess.READ).get_var()
		if not data:
			data = save_data
		save_data = data
	else:
		api_save()
		save_data = readsave()
	api_url = save_data[0]
	api_key = save_data[1]
	return save_data


## API工具

# 线程池
var maxhttp : int = 10
var is_run : bool = false

# API
var api_url : String
var api_key : String
var time_out : int = 10

# 标准化收发
func get_result(head : PackedStringArray, data : String, url : String = "") -> Array:
	retry_times = 0
	if url.is_empty():
		url = api_url
	var response : String = await request_retry(head, data, url)
	if "Error:" in response:
		return [false, response]
	else:
		var json_result = JSON.parse_string(response)
		return [true, json_result]

# 重试方法
const RETRY_ATTEMPTS = 5
var retry_times : int = 0
const status_list = [429, 500, 502, 503, 504]
func request_retry(head : PackedStringArray, data : String, url : String) -> String:
	# 建立请求
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.timeout = time_out
	var error = http_request.request(url, head, HTTPClient.METHOD_POST, data)
	if error != OK:
		return "Error: " + error_string(error)
	
	# 发起成功
	var received = await http_request.request_completed
	http_request.queue_free()
	if received[0] != 0:
		return "Error: " + ClassDB.class_get_enum_constants("HTTPRequest", "Result")[received[0]]
	
	# 重试策略
	if retry_times > RETRY_ATTEMPTS:
		return "Error: Retry count exceeded"
	elif received[1] != 200 and status_list.has(received[1]) and retry_times <= RETRY_ATTEMPTS:
		retry_times += 1
		await get_tree().create_timer(2 ** (retry_times - 1)).timeout
		return await request_retry(head, data, url)
	elif received[1] == 200:
		var result : String = received[3].get_string_from_utf8()
		if "error" in result:
			return "APIError: " + result
		else:
			return result
	else:
		return "Error: Unknown error. Status:" + str(received[1]) + received[3].get_string_from_utf8()
