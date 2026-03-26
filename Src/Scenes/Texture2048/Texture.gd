extends Spatial

# texture 16384x16384 with Mip Maps = 1368 MB VRAM
# texture 8192x8192 with Mip Maps = 344 MB VRAM
# texture 4096x4096 with Mip Maps = 88 MB VRAM
# texture 2048x2048 with Mip Maps = 24 MB VRAM
# texture 1024x1024 with Mip Maps = 8 MB VRAM
# texture 512x512 with Mip Maps = 4 MB VRAM
# texture 256x256 with Mip Maps = 2 MB VRAM
# texture 128x128 with Mip Maps = 2 MB VRAM

var textur = Image(128, 128, false, Image.FORMAT_RGBA)
var dummy = Image(1, 1, false, Image.FORMAT_RGB)
var text = null

func _ready():
	pass

func nfree():
	pass

func blabla():
	#tex_gen()
	text = ImageTexture.new()
	textur.load("res://Scenes/Texture/128.png")
	text.create_from_image(textur)
	get_node("Sprite3D").set_texture(text)
	pass

func nfree2():
	text = ImageTexture.new()
	text.create_from_image(dummy)
	get_node("Sprite3D").set_texture(text)
	text.set_path("")
	text.take_over_path("")
	textur = null
	text = null
	get_node("Sprite3D").set_texture(null)

func tex_gen():
	var tex_size = 4096
	var brick_w = 128
	var brick_h = 64
	var mortar = 4

	var img = Image(tex_size, tex_size, false, Image.FORMAT_RGBA)
	#img.lock() # For Godot 3+...
	
	for y in range(tex_size):
		for x in range(tex_size):
			img.put_pixel(x, y, Color(0.2, 0.2, 0.2))
	
	for y_row in range(0, tex_size, brick_h):
		var offset = 0
		if (y_row / brick_h) % 2 == 1:
			offset = brick_w / 2
	
		for x_col in range(-offset, tex_size, brick_w):
			var r = 0.6 + randf() * 0.2
			var g = 0.2 + randf() * 0.1
			var b = 0.1 + randf() * 0.1
			var brick_color = Color(r, g, b)
			
			for py in range(y_row + mortar, y_row + brick_h - mortar):
				for px in range(x_col + mortar, x_col + brick_w - mortar):
					if px >= 0 and px < tex_size and py >= 0 and py < tex_size:
						img.put_pixel(px, py, brick_color)
	
	#img.unlock() # For Godot 3+...
	
	var tex = ImageTexture.new()
	tex.create_from_image(img)
	get_node("Sprite3D").set_texture(tex)
	#self.set_texture(tex)
	#img.save_png()