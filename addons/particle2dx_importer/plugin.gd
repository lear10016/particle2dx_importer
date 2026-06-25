@tool
extends EditorPlugin

const Converter := preload("res://addons/particle2dx_importer/cocos_particle2dx_converter.gd")
const SINGLE_CONVERT_MENU := "Convert Particle2D Plist..."
const BATCH_CONVERT_MENU := "Convert Particle2D Plist Folder..."
const DEFAULT_OUTPUT_ROOT := "res://converted_particles"
const MESSAGE_DIALOG_SIZE := Vector2i(820, 560)
const MAX_MESSAGE_ITEMS_PER_SECTION := 20

var _open_dialog: FileDialog
var _save_dialog: FileDialog
var _batch_open_dialog: FileDialog
var _batch_save_dialog: FileDialog
var _message_dialog: AcceptDialog
var _message_text: RichTextLabel
var _source_path := ""
var _batch_source_dir := ""

func _enter_tree() -> void:
	add_tool_menu_item(SINGLE_CONVERT_MENU, Callable(self, "_show_open_dialog"))
	add_tool_menu_item(BATCH_CONVERT_MENU, Callable(self, "_show_batch_open_dialog"))
	_create_dialogs()

func _exit_tree() -> void:
	remove_tool_menu_item(SINGLE_CONVERT_MENU)
	remove_tool_menu_item(BATCH_CONVERT_MENU)
	if is_instance_valid(_open_dialog):
		_open_dialog.queue_free()
	if is_instance_valid(_save_dialog):
		_save_dialog.queue_free()
	if is_instance_valid(_batch_open_dialog):
		_batch_open_dialog.queue_free()
	if is_instance_valid(_batch_save_dialog):
		_batch_save_dialog.queue_free()
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

	_batch_open_dialog = FileDialog.new()
	_batch_open_dialog.title = "Select Folder With Cocos Particle2D Plists"
	_batch_open_dialog.access = FileDialog.ACCESS_FILESYSTEM
	_batch_open_dialog.file_mode = FileDialog.FILE_MODE_OPEN_DIR
	_batch_open_dialog.dir_selected.connect(_on_batch_dir_selected)
	base_control.add_child(_batch_open_dialog)

	_batch_save_dialog = FileDialog.new()
	_batch_save_dialog.title = "Select Output Folder For Converted Scenes"
	_batch_save_dialog.access = FileDialog.ACCESS_RESOURCES
	_batch_save_dialog.file_mode = FileDialog.FILE_MODE_OPEN_DIR
	_batch_save_dialog.dir_selected.connect(_on_batch_output_dir_selected)
	base_control.add_child(_batch_save_dialog)

	_message_dialog = AcceptDialog.new()
	_message_dialog.title = "Cocos Particle2D Converter"
	_message_dialog.dialog_text = ""
	_message_dialog.min_size = MESSAGE_DIALOG_SIZE
	_message_text = RichTextLabel.new()
	_message_text.bbcode_enabled = false
	_message_text.fit_content = false
	_message_text.scroll_active = true
	_message_text.selection_enabled = true
	_message_text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_message_text.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_message_text.custom_minimum_size = Vector2(MESSAGE_DIALOG_SIZE.x - 40, MESSAGE_DIALOG_SIZE.y - 120)
	_message_dialog.add_child(_message_text)
	base_control.add_child(_message_dialog)

func _show_open_dialog() -> void:
	_source_path = ""
	_open_dialog.popup_centered_ratio(0.7)

func _show_batch_open_dialog() -> void:
	_batch_source_dir = ""
	_batch_open_dialog.popup_centered_ratio(0.7)

func _on_plist_selected(path: String) -> void:
	_source_path = path
	var default_name := path.get_file().get_basename()
	if default_name.is_empty():
		default_name = "particle"
	_save_dialog.current_path = "%s/%s.tscn" % [DEFAULT_OUTPUT_ROOT, default_name]
	_save_dialog.popup_centered_ratio(0.7)

func _on_batch_dir_selected(path: String) -> void:
	_batch_source_dir = path
	_batch_save_dialog.current_dir = _default_batch_output_dir(path)
	_batch_save_dialog.popup_centered_ratio(0.7)

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

func _on_batch_output_dir_selected(path: String) -> void:
	if _batch_source_dir.is_empty():
		_show_message("No source folder was selected.")
		return

	await _convert_plist_folder(_batch_source_dir, path)

func _convert_plist_folder(source_dir: String, output_dir: String) -> void:
	var plist_paths := _list_plist_files(source_dir)
	if plist_paths.is_empty():
		_show_message("No .plist files were found in:\n%s" % source_dir)
		return

	var filesystem := get_editor_interface().get_resource_filesystem()
	var converted_count := 0
	var warning_count := 0
	var converted_paths := PackedStringArray()
	var warning_lines := PackedStringArray()
	var error_lines := PackedStringArray()

	for plist_path in plist_paths:
		var scene_path := "%s/%s.tscn" % [output_dir.trim_suffix("/"), plist_path.get_file().get_basename()]
		var converter := Converter.new()
		var result := converter.convert_file(plist_path, scene_path, {
			"overwrite": true,
			"editor_file_system": filesystem
		})
		if not result.get("ok", false):
			error_lines.append("%s: %s" % [plist_path.get_file(), String(result.get("error", "Conversion failed."))])
			continue

		converted_count += 1
		converted_paths.append(String(result.get("scene_path", scene_path)))

		var texture_path := String(result.get("texture_path", ""))
		if not texture_path.is_empty():
			await _wait_for_texture_import(texture_path)

		var warnings: Array = result.get("warnings", [])
		if warnings.is_empty():
			continue

		warning_count += warnings.size()
		var warning_text := PackedStringArray()
		for warning in warnings:
			warning_text.append(String(warning))
		warning_lines.append("%s: %s" % [plist_path.get_file(), " | ".join(warning_text)])

	filesystem.scan()

	var summary := "Converted %d of %d plist files to:\n%s" % [converted_count, plist_paths.size(), output_dir]
	if converted_count > 0:
		summary += _format_message_section("Scenes", converted_paths)
	if warning_count > 0:
		summary += _format_message_section("Warnings (%d)" % warning_count, warning_lines)
	if not error_lines.is_empty():
		summary += _format_message_section("Failed (%d)" % error_lines.size(), error_lines)
	_show_message(summary)

func _list_plist_files(source_dir: String) -> PackedStringArray:
	var dir := DirAccess.open(source_dir)
	if dir == null:
		return PackedStringArray()

	var paths := PackedStringArray()
	dir.list_dir_begin()
	while true:
		var entry := dir.get_next()
		if entry.is_empty():
			break
		if entry.begins_with(".") or dir.current_is_dir():
			continue
		if entry.get_extension().to_lower() != "plist":
			continue
		paths.append(source_dir.path_join(entry))
	dir.list_dir_end()
	paths.sort()
	return paths

func _default_batch_output_dir(source_dir: String) -> String:
	var folder_name := source_dir.get_file().strip_edges()
	if folder_name.is_empty():
		folder_name = "batch"
	return "%s/%s" % [DEFAULT_OUTPUT_ROOT, folder_name]

func _format_message_section(title: String, items: PackedStringArray) -> String:
	if items.is_empty():
		return ""

	var visible_items := PackedStringArray()
	var visible_count := mini(items.size(), MAX_MESSAGE_ITEMS_PER_SECTION)
	for index in range(visible_count):
		visible_items.append(items[index])

	var section := "\n\n%s:\n- %s" % [title, "\n- ".join(visible_items)]
	var remaining_count := items.size() - visible_count
	if remaining_count > 0:
		section += "\n- ... and %d more" % remaining_count
	return section

func _show_message(text: String) -> void:
	_message_text.clear()
	_message_text.text = text
	_message_text.scroll_to_line(0)
	_message_dialog.popup_centered_clamped(MESSAGE_DIALOG_SIZE, 0.8)

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
