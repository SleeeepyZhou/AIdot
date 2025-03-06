extends Node

const MATRIX_ADD = preload("res://addons/matrix_calc/Shader/matrix_add.glsl")
const MATRIX_SUB = preload("res://addons/matrix_calc/Shader/matrix_sub.glsl")
const MATRIX_MUL = preload("res://addons/matrix_calc/Shader/matrix_mul.glsl")
const MATRIX_SMUL = preload("res://addons/matrix_calc/Shader/matrix_smul.glsl")

const MATRIX_HAD = preload("res://addons/matrix_calc/Shader/matrix_hadamard.glsl")
const MATRIX_TRA = preload("res://addons/matrix_calc/Shader/matrix_transpose.glsl")

var use_render : bool = ProjectSettings.get_setting("rendering/renderer/rendering_method") != "gl_compatibility":
	set(b):
		return

enum ASHT {ADD, SUB, HAD, TRA}
func A_S_H_T(rdevice : RenderingDevice, type : ASHT, Abuffer : RID, Bbuffer : RID, rect : Vector2i) -> RID:
	var size : int = rect.x * rect.y
	
	var A_uniform := RDUniform.new()
	A_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
	A_uniform.binding = 0
	A_uniform.add_id(Abuffer)
	
	var output := PackedFloat32Array()
	output.resize(size)
	var obuffer = rdevice.storage_buffer_create(output.to_byte_array().size(), output.to_byte_array())
	var o_uniform := RDUniform.new()
	o_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
	o_uniform.binding = 2
	o_uniform.add_id(obuffer)
	
	var matrices := PackedInt32Array([rect.x,rect.y])
	var mbuffer = rdevice.storage_buffer_create(matrices.to_byte_array().size(), matrices.to_byte_array())
	var m_uniform := RDUniform.new()
	m_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
	m_uniform.binding = 3
	m_uniform.add_id(mbuffer)
	
	var uniforms = [A_uniform, o_uniform, m_uniform]
	
	if type != ASHT.TRA:
		var B_uniform := RDUniform.new()
		B_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
		B_uniform.binding = 1
		B_uniform.add_id(Bbuffer)
		uniforms.append(B_uniform)
	
	var type_a = [MATRIX_ADD, MATRIX_SUB, MATRIX_HAD, MATRIX_TRA]
	var shader : RID = rdevice.shader_create_from_spirv(type_a[type].get_spirv())
	var uniform_set : RID = rdevice.uniform_set_create(uniforms, shader, 0)
	var pipeline : RID = rdevice.compute_pipeline_create(shader)
	var compute_list := rdevice.compute_list_begin()
	rdevice.compute_list_bind_compute_pipeline(compute_list, pipeline)
	rdevice.compute_list_bind_uniform_set(compute_list, uniform_set, 0)
	rdevice.compute_list_dispatch(compute_list, rect.x/16, rect.y/16, 1)
	rdevice.compute_list_end()
	
	rdevice.submit()
	rdevice.sync()
	return obuffer

func mul(rdevice : RenderingDevice, Abuffer : RID, Bbuffer : RID, matrix : PackedInt32Array):
	
	
	#var A_uniform := RDUniform.new()
	#A_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
	#A_uniform.binding = 0
	#A_uniform.add_id(Abuffer)
	#
	#var output := PackedFloat32Array()
	#output.resize(size)
	#var obuffer = rdevice.storage_buffer_create(output.to_byte_array().size(), output.to_byte_array())
	#var o_uniform := RDUniform.new()
	#o_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
	#o_uniform.binding = 2
	#o_uniform.add_id(obuffer)
	#
	#var mbuffer = rdevice.storage_buffer_create(matrices.to_byte_array().size(), matrices.to_byte_array())
	#var m_uniform := RDUniform.new()
	#m_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
	#m_uniform.binding = 3
	#m_uniform.add_id(mbuffer)
	pass

func binding_uniform(rdevice : RenderingDevice, ingroup : Array, 
					spirv : RDShaderSPIRV, groupsize : Vector3i) -> Array:
	var shader : RID = rdevice.shader_create_from_spirv(spirv)
	var uniforms : Array[RDUniform] = []
	var buffers : Array[RID] = []
	for i in ingroup.size():
		var data = ingroup[i]
		var byte = data.to_byte_array()
		var buffer = rdevice.storage_buffer_create(byte.size(), byte)
		buffers.append(buffer)
		var tempuniform := RDUniform.new()
		tempuniform.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
		tempuniform.binding = i
		tempuniform.add_id(buffer)
		uniforms.append(tempuniform)
	
	var uniform_set : RID = rdevice.uniform_set_create(uniforms, shader, 0)
	var pipeline : RID = rdevice.compute_pipeline_create(shader)
	var compute_list := rdevice.compute_list_begin()
	rdevice.compute_list_bind_compute_pipeline(compute_list, pipeline)
	rdevice.compute_list_bind_uniform_set(compute_list, uniform_set, 0)
	rdevice.compute_list_dispatch(compute_list, groupsize.x, groupsize.y, groupsize.z)
	rdevice.compute_list_end()
	
	rdevice.free_rid(shader)
	return buffers

func freebuffer(rdevice : RenderingDevice, buffers : Array[RID]):
	for buffer in buffers:
		rdevice.free_rid(buffer)
	rdevice.free()
	#print("Buffer free completed.")
