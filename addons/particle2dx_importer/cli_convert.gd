extends SceneTree

const Converter := preload("res://addons/particle2dx_importer/cocos_particle2dx_converter.gd")

func _init() -> void:
	var parsed := _parse_args(OS.get_cmdline_user_args())
	if parsed.get("help", false):
		_print_usage()
		quit(0)
		return
	if not parsed.get("ok", false):
		push_error(parsed.get("error", "Invalid arguments."))
		_print_usage()
		quit(2)
		return

	var converter := Converter.new()
	var result := converter.convert_file(parsed["input"], parsed.get("output", ""), parsed.get("options", {}))
	if not result.get("ok", false):
		push_error(result.get("error", "Conversion failed."))
		_print_warnings(result.get("warnings", []))
		quit(1)
		return

	print("Converted scene: %s" % result["scene_path"])
	if not String(result.get("texture_path", "")).is_empty():
		print("Decoded texture: %s" % result["texture_path"])
	_print_warnings(result.get("warnings", []))
	quit(0)

func _parse_args(args: PackedStringArray) -> Dictionary:
	var input := ""
	var output := ""
	var options: Dictionary = {"overwrite": true}
	var index := 0

	while index < args.size():
		var arg := args[index]
		match arg:
			"--help", "-h":
				return {"ok": true, "help": true}
			"--input", "-i":
				index += 1
				if index >= args.size():
					return {"ok": false, "error": "%s needs a value." % arg}
				input = args[index]
			"--output", "-o":
				index += 1
				if index >= args.size():
					return {"ok": false, "error": "%s needs a value." % arg}
				output = args[index]
			"--texture-output":
				index += 1
				if index >= args.size():
					return {"ok": false, "error": "%s needs a value." % arg}
				options["texture_output"] = args[index]
			"--root-name":
				index += 1
				if index >= args.size():
					return {"ok": false, "error": "%s needs a value." % arg}
				options["root_name"] = args[index]
			"--preserve-source-position":
				options["preserve_source_position"] = true
			"--no-overwrite":
				options["overwrite"] = false
			_:
				if input.is_empty():
					input = arg
				elif output.is_empty():
					output = arg
				else:
					return {"ok": false, "error": "Unexpected argument: %s" % arg}
		index += 1

	if input.is_empty():
		return {"ok": false, "error": "Missing input plist."}

	return {
		"ok": true,
		"input": input,
		"output": output,
		"options": options
	}

func _print_usage() -> void:
	print("""
Cocos Particle2D plist to Godot scene converter

Usage:
  godot --headless --path <project> --script res://addons/particle2dx_importer/cli_convert.gd -- <input.plist> [output.tscn]
  godot --headless --path <project> --script res://addons/particle2dx_importer/cli_convert.gd -- --input <input.plist> --output res://converted_particles/effect.tscn

Options:
  -i, --input <path>              Source Cocos2d-x particle plist.
  -o, --output <path>             Output .tscn. Must be res://, project-relative, or an absolute path inside the project.
      --texture-output <path>     Output texture path. Defaults next to the scene.
      --root-name <name>          Root GPUParticles2D node name.
      --preserve-source-position  Keep sourcePositionx/y on the root node.
      --no-overwrite              Fail when the output scene already exists.
  -h, --help                      Show this help.
""")

func _print_warnings(warnings: Array) -> void:
	for warning in warnings:
		printerr("Warning: %s" % warning)
