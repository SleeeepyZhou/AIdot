@tool
class_name ImageProcessor

# 图片压缩及转码
const IMAGE_TYPE = ["JPG", "PNG", "BMP", "GIF", "TIF", "TIFF", "JPEG", "WEBP"]
func zip_image(image : Image, quality : String = "auto") -> Image:
	var width = image.get_size().x
	var height = image.get_size().y
	
	var target : int = 512
	var aspect_ratio : float = float(width) / height
	var new_width = width
	var new_height = height
	if quality == "high":
		target = 1024
	elif quality == "low":
		target = 512
	elif quality == "auto":
		if width >= 1024 or height >= 1024:
			target = 1024
	if width > target or height > target:
		if width > height:
			new_width = target
			new_height = int(new_width / aspect_ratio)
		else:
			new_height = target
			new_width = int(new_height * aspect_ratio)
	image.resize(new_width, new_height)
	return image

func image_to_base64(path : String, quality : String = "auto") -> String:
	if !IMAGE_TYPE.has(path.get_extension().to_upper()):
		return ""
	var image = Image.load_from_file(path)
	var zimage = zip_image(image, quality)
	return Marshalls.raw_to_base64(zimage.save_jpg_to_buffer(0.90))

func texture_to_base64(texture : Texture2D, quality : String = "auto"):
	var image = texture.get_image()
	var zimage = zip_image(image, quality)
	return Marshalls.raw_to_base64(zimage.save_jpg_to_buffer(0.90))
