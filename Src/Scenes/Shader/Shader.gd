extends MeshInstance

func _ready():
	multilayer()
	pass

func multilayer():
	var layers = 45
	var base_mat = get_material_override()
	
	if base_mat == null:
		print("Ошибка: Назначьте ShaderMaterial в Material Override!")
		return
	
	for i in range(1, layers):
		var shell = MeshInstance.new()
		shell.set_mesh(get_mesh())
		
		var new_mat = base_mat.duplicate()
		
		var idx = float(i) / float(layers)
		new_mat.set_shader_param("layer_index", idx)
		
		shell.set_material_override(new_mat)
		add_child(shell)
