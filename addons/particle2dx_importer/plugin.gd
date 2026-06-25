@tool
extends EditorPlugin

const Converter := preload("res://addons/particle2dx_importer/cocos_particle2dx_converter.gd")

var _open_dialog: FileDialog
var _save_dialog: FileDialog
var _message_dialog: AcceptDialog
var _source_path := ""

func _enter_tree() -> void:
	add_tool_menu_item("Convert Particle2D Plist...", Callable(self, "_show_open_dialog"))
	_create_dialogs()

func _exit_tree() -> void:
	remove_tool_menu_item("Convert Particle2D Plist...")
	if is_instance_valid(_open_dialog):
		_open_dialog.queue_free()
	if is_instance_valid(_save_dialog):
		_save_dialog.queue_free()
	if is_instance_valid(_message_dialog):
		_message_dialog.queue_free()

func _create_dialogs() -> void:
	var base_control := get_editor_interface().get_base_control()

	_open_dialog = FileDialog.new()
	_open_dialog.title = "Select Cocos Particle2D Plist"
	_open_dialog.access = FileDialog.ACCESS_FILESYSTEM
	_open_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	_open_dialog.filters = PackedStringArray(["*.plist ; Cocos Particle2D plist"])
	_open_dialog.file_selected.connect(_on_plist_selected)
	base_control.add_child(_open_dialog)

	_save_dialog = FileDialog.new()
	_save_dialog.title = "Save Godot Particle Scene"
	_save_dialog.access = FileDialog.ACCESS_RESOURCES
	_save_dialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE
	_save_dialog.filters = PackedStringArray(["*.tscn ; Godot scene"])
	_save_dialog.file_selected.connect(_on_scene_selected)
	base_control.add_child(_save_dialog)

	_message_dialog = AcceptDialog.new()
	_message_dialog.title = "Cocos Particle2D Converter"
	base_control.add_child(_message_dialog)

func _show_open_dialog() -> void:
	_source_path = ""
	_open_dialog.popup_centered_ratio(0.7)

func _on_plist_selected(path: String) -> void:
	_source_path = path
	var default_name := path.get_file().get_basename()
	if default_name.is_empty():
		default_name = "particle"
	_save_dialog.current_path = "res://converted_particles/%s.tscn" % default_name
	_save_dialog.popup_centered_ratio(0.7)

func _on_scene_selected(path: String) -> void:
	if _source_path.is_empty():
		_show_message("No source plist was selected.")
		return

	var converter := Converter.new()
	var result := converter.convert_file(_source_path, path, {
		"overwrite": true,
		"editor_file_system": get_editor_interface().get_resource_filesystem()
	})
	if not result.get("ok", false):
		var error_text := String(result.get("error", "Conversion failed."))
		push_error(error_text)
		_show_message(error_text)
		return

	var texture_path := String(result.get("texture_path", ""))
	if not texture_path.is_empty():
		await _wait_for_texture_import(texture_path)

	get_editor_interface().get_resource_filesystem().scan()
	get_editor_interface().open_scene_from_path(result["scene_path"])

	var message := "Converted plist to:\n%s" % result["scene_path"]
	if not String(result.get("texture_path", "")).is_empty():
		message += "\n\nDecoded texture:\n%s" % result["texture_path"]
	var warnings: Array = result.get("warnings", [])
	if not warnings.is_empty():
		var warning_lines := PackedStringArray()
		for warning in warnings:
			warning_lines.append(String(warning))
		message += "\n\nWarnings:\n- %s" % "\n- ".join(warning_lines)
	_show_message(message)

func _show_message(text: String) -> void:
	_message_dialog.dialog_text = text
	_message_dialog.popup_centered()

func _wait_for_texture_import(path: String) -> void:
	if not path.begins_with("res://"):
		return

	var filesystem := get_editor_interface().get_resource_filesystem()
	if filesystem.has_method("update_file"):
		filesystem.call("update_file", path)
	if filesystem.has_method("reimport_files"):
		filesystem.call("reimport_files", PackedStringArray([path]))

	var import_marker := "%s.import" % path
	for _attempt in range(60):
		if FileAccess.file_exists(import_marker):
			return
		await get_tree().create_timer(0.05).timeout

	push_warning("Timed out waiting for texture import: %s" % path)
