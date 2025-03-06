@tool
@icon("res://addons/matrix_calc/Icon/Float32Matrix.svg")
class_name Float32Matrix
extends Resource

@export var x : int = 1 :
	set(i):
		if !is_resize:
			resize(Vector2i(i,y))
		x = i

@export var y : int = 1 :
	set(i):
		if !is_resize:
			resize(Vector2i(x,i))
		y = i

@export var data : PackedFloat32Array = [0.0] :
	set(a):
		if a != null:
			a.resize(data.size())
			data = a

func _init(rect : Vector2i = Vector2i(1,1)) -> void:
	resize(rect)

func rect() -> Vector2i:
	return Vector2i(x,y)

var is_resize := false
func resize(rect : Vector2i) -> void:
	is_resize = true
	var old_data := data.duplicate()
	data.resize(rect.x * rect.y)
	for i in range(rect.y):
		for j in range(rect.x):
			if j < x and i < y:
				data[i*rect.x+j] = old_data[i*x+j]
			else:
				data[i*rect.x+j] = 0
	x = rect.x
	y = rect.y
	is_resize = false

func get_value(pos : Vector2i) -> float:
	var e = pos < rect() and pos >= Vector2i.ZERO
	assert(e, "Error: The index exceeds the boundary of the matrix!")
	return data[pos.y*x+pos.x]

func set_value(pos : Vector2i, f : float) -> void:
	var e = pos < rect() and pos >= Vector2i.ZERO
	assert(e, "Error: The index exceeds the boundary of the matrix!")
	data[pos.y*x+pos.x] = f

func random(min : float, max : float, rect : Vector2i) -> void:
	is_resize = true
	x = rect.x
	y = rect.y
	data.resize(rect.x * rect.y)
	randomize()
	for i in range(x*y):
		data[i] = randf_range(min, max)
	is_resize = false

func zeros(rect : Vector2i) -> void:
	is_resize = true
	x = rect.x
	y = rect.y
	data = []
	data.resize(rect.x * rect.y)
	is_resize = false

func transpose() -> Float32Matrix:
	var matrixT := Float32Matrix.new(rect())
	for i in y:
		for j in x:
			matrixT.data[j*y+i] = data[i*x+j]
	return matrixT

func Hadamard(B : Float32Matrix) -> Float32Matrix:
	var e : bool = rect() == B.rect()
	assert(e, "Error: Matrix dimension mismatch!")

	var C := Float32Matrix.new(rect())
	if !MatrixLib.use_render or x*y <= 4096:
		for i in range(data.size()):
			C.data[i] = data[i] * B.data[i]
	else:
		var matrices := PackedInt32Array([x,y])
		var input := [data, B.data, C.data, matrices]
		var gsize := Vector3i(ceil(x/16.0),ceil(y/16.0),1)
		var rd : RenderingDevice = RenderingServer.create_local_rendering_device()
		var out = MatrixLib.binding_uniform(rd, input, MatrixLib.MATRIX_HAD.get_spirv(), gsize)
		rd.submit()
		rd.sync()
		var output := rd.buffer_get_data(out[2]).to_float32_array()
		C.data = output
		MatrixLib.freebuffer(rd, out)
	return C

func mul_scalar(f : float) -> void:
	for i in range(data.size()):
		data[i] *= f

func mul(B : Float32Matrix) -> Float32Matrix:
	var K : int = x
	var e : bool = K == B.y
	assert(e, "Error: Incompatible matrix dimensions for multiplication.")
	
	var M : int = y
	var N : int = B.x
	var C := Float32Matrix.new(Vector2i(N,M))
	
	if !MatrixLib.use_render or M*N*K < 4096:
		for row in range(M):
			for col in range(N):
				for k in range(K):
					C.data[row*N+col] += data[row*K+k] * B.data[k*N+col]
		#push_warning("Warning: GL Compatibility unable to use acceleration.")
		return C
	
	var matrices := PackedInt32Array([M,N,K])
	var input := [data, B.data, C.data, matrices]
	var gsize := Vector3i(ceil(N/16.0),ceil(M/16.0),1)
	var rd : RenderingDevice = RenderingServer.create_local_rendering_device()
	var out = MatrixLib.binding_uniform(rd, input, MatrixLib.MATRIX_MUL.get_spirv(), gsize)
	rd.submit()
	rd.sync()
	var output := rd.buffer_get_data(out[2]).to_float32_array()
	C.data = output
	
	MatrixLib.freebuffer(rd, out)
	return C

func add(B : Float32Matrix) -> Float32Matrix:
	var e : bool = rect() == B.rect()
	assert(e, "Error: Matrix dimension mismatch!")
	
	var C := Float32Matrix.new(rect())
	if !MatrixLib.use_render or x*y <= 4096:
		for i in range(data.size()):
			C.data[i] = data[i] + B.data[i]
	else:
		var matrices := PackedInt32Array([x,y])
		var input := [data, B.data, C.data, matrices]
		var gsize := Vector3i(ceil(x/16.0),ceil(y/16.0),1)
		var rd : RenderingDevice = RenderingServer.create_local_rendering_device()
		var out = MatrixLib.binding_uniform(rd, input, MatrixLib.MATRIX_ADD.get_spirv(), gsize)
		rd.submit()
		rd.sync()
		var output := rd.buffer_get_data(out[2]).to_float32_array()
		C.data = output
		MatrixLib.freebuffer(rd, out)
	return C

func sub(B : Float32Matrix) -> Float32Matrix:
	var e : bool = rect() == B.rect()
	assert(e, "Error: Matrix dimension mismatch!")
	
	var C := Float32Matrix.new(rect())
	if !MatrixLib.use_render or x*y <= 4096:
		for i in range(data.size()):
			C.data[i] = data[i] - B.data[i]
	else:
		var matrices := PackedInt32Array([x,y])
		var input := [data, B.data, C.data, matrices]
		var gsize := Vector3i(ceil(x/16.0),ceil(y/16.0),1)
		var rd : RenderingDevice = RenderingServer.create_local_rendering_device()
		var out = MatrixLib.binding_uniform(rd, input, MatrixLib.MATRIX_SUB.get_spirv(), gsize)
		rd.submit()
		rd.sync()
		var output := rd.buffer_get_data(out[2]).to_float32_array()
		C.data = output
		MatrixLib.freebuffer(rd, out)
	return C
