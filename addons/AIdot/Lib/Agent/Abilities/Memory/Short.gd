extends AIMemory
class_name ShortMemory

var history : Array = [
	
]

func add_block(block : Dictionary):
	history.append(block)
