extends Control

const SOURCE_GROUPS := [
	{
		"label": "Reference",
		"dir": "res://particle",
		"summary": "Reference corpus",
	},
	{
		"label": "Generated",
		"dir": "res://generated_particles",
		"summary": "Generated outputs",
	},
	{
		"label": "Showcase",
		"dir": "res://examples",
		"summary": "Authored experiments",
	},
]
const ITEMS_PER_PAGE := 6
const CARD_PREVIEW_SIZE := Vector2i(156, 88)
const TEXT_COLOR := Color(0.16, 0.22, 0.29)
const MUTED_TEXT_COLOR := Color(0.35, 0.43, 0.49)
const BUTTON_TEXT_COLOR := Color(0.18, 0.25, 0.33)

var _particle_entries: Array[Dictionary] = []
var _current_source_index := 0
var _current_page := 0
var _selected_index := -1
var _selected_view_offset := Vector2.ZERO
var _is_dragging_stage := false

@onready var _summary_label: Label = %SummaryLabel
@onready var _selected_name_label: Label = %SelectedNameLabel
@onready var _selected_path_label: Label = %SelectedPathLabel
@onready var _browse_summary_label: Label = %BrowseSummaryLabel
@onready var _source_tabs: TabBar = %SourceTabs
@onready var _page_label: Label = %PageLabel
@onready var _previous_button: Button = %PreviousButton
@onready var _next_button: Button = %NextButton
@onready var _card_grid: GridContainer = %CardGrid
@onready var _empty_label: Label = %EmptyLabel
@onready var _stage_panel: PanelContainer = %StagePanel
@onready var _library_panel: PanelContainer = %LibraryPanel
@onready var _stage_frame: PanelContainer = %StageFrame
@onready var _stage_viewport_container: SubViewportContainer = %StageViewportContainer
@onready var _stage_viewport: SubViewport = %StageViewport
@onready var _stage_root: Node2D = %StageRoot

func _ready() -> void:
	_apply_static_styles()
	_build_source_tabs()
	_previous_button.pressed.connect(_show_previous_page)
	_next_button.pressed.connect(_show_next_page)
	_source_tabs.tab_changed.connect(_on_source_tab_changed)
	_stage_viewport_container.gui_input.connect(_on_stage_viewport_gui_input)
	_load_particle_entries()
	if not _particle_entries.is_empty():
		_select_entry(0, false)
	else:
		_render_page()
	_update_stage_viewport()

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		_update_stage_viewport()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_left"):
		_show_previous_page()
	elif event.is_action_pressed("ui_right"):
		_show_next_page()

func _apply_static_styles() -> void:
	_stage_panel.add_theme_stylebox_override("panel", _make_surface_style(Color(0.98, 0.986, 0.995), Color(0.84, 0.88, 0.93)))
	_library_panel.add_theme_stylebox_override("panel", _make_surface_style(Color(1.0, 1.0, 1.0), Color(0.84, 0.88, 0.93)))
	_stage_frame.add_theme_stylebox_override("panel", _make_surface_style(Color(0.09, 0.12, 0.16), Color(0.15, 0.22, 0.29)))
	_summary_label.add_theme_color_override("font_color", MUTED_TEXT_COLOR)
	_selected_name_label.add_theme_color_override("font_color", TEXT_COLOR)
	_selected_path_label.add_theme_color_override("font_color", MUTED_TEXT_COLOR)
	_browse_summary_label.add_theme_color_override("font_color", MUTED_TEXT_COLOR)
	_page_label.add_theme_color_override("font_color", TEXT_COLOR)
	_empty_label.add_theme_color_override("font_color", MUTED_TEXT_COLOR)
	_apply_button_style(_previous_button)
	_apply_button_style(_next_button)

func _load_particle_entries() -> void:
	_particle_entries.clear()

	var source_dir := String(_current_source()["dir"])
	var dir := DirAccess.open(source_dir)
	if dir == null:
		return

	dir.list_dir_begin()
	while true:
		var entry := dir.get_next()
		if entry.is_empty():
			break
		if dir.current_is_dir() or entry.begins_with(".") or entry.get_extension().to_lower() != "tscn":
			continue

		var scene_path := source_dir.path_join(entry)
		var scene := load(scene_path) as PackedScene
		if scene == null:
			continue

		_particle_entries.append({
			"name": _prettify_name(entry.get_basename()),
			"path": scene_path,
			"scene": scene
		})
	dir.list_dir_end()

	_particle_entries.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return String(a["name"]).naturalnocasecmp_to(String(b["name"])) < 0
	)

func _render_page() -> void:
	for child in _card_grid.get_children():
		child.queue_free()

	var source := _current_source()
	var source_summary := String(source["summary"])
	var source_dir := String(source["dir"])

	if _particle_entries.is_empty():
		_clear_stage()
		_empty_label.visible = true
		_summary_label.text = "No particle previews found in %s" % source_dir
		_browse_summary_label.text = "%s: 0 effects" % source_summary
		_page_label.text = "Page 0 / 0"
		_selected_name_label.text = "No Effect Selected"
		_selected_path_label.text = ""
		_previous_button.disabled = true
		_next_button.disabled = true
		return

	_empty_label.visible = false

	var start_index := _current_page * ITEMS_PER_PAGE
	var end_index := mini(start_index + ITEMS_PER_PAGE, _particle_entries.size())
	for index in range(start_index, end_index):
		_card_grid.add_child(_build_library_card(index, _particle_entries[index]))

	_summary_label.text = "%s: %d particle scenes from %s" % [source_summary, _particle_entries.size(), source_dir]
	_browse_summary_label.text = "Showing %d-%d of %d" % [start_index + 1, end_index, _particle_entries.size()]
	_page_label.text = "Page %d / %d" % [_current_page + 1, _page_count()]
	_previous_button.disabled = _current_page <= 0
	_next_button.disabled = _current_page >= _page_count() - 1

func _build_library_card(index: int, entry: Dictionary) -> Control:
	var card := PanelContainer.new()
	card.custom_minimum_size = Vector2(176.0, 144.0)
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.mouse_filter = Control.MOUSE_FILTER_STOP
	card.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	card.gui_input.connect(_on_card_gui_input.bind(index))
	card.add_theme_stylebox_override("panel", _make_card_style(index == _selected_index))

	var body := VBoxContainer.new()
	body.mouse_filter = Control.MOUSE_FILTER_IGNORE
	body.add_theme_constant_override("separation", 6)
	card.add_child(body)

	var preview_frame := PanelContainer.new()
	preview_frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	preview_frame.custom_minimum_size = Vector2(0.0, CARD_PREVIEW_SIZE.y)
	preview_frame.add_theme_stylebox_override("panel", _make_surface_style(Color(0.10, 0.13, 0.18), Color(0.16, 0.22, 0.30), 10))
	body.add_child(preview_frame)

	var viewport_container := SubViewportContainer.new()
	viewport_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	viewport_container.stretch = true
	viewport_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	viewport_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	preview_frame.add_child(viewport_container)

	var viewport := SubViewport.new()
	viewport.disable_3d = true
	viewport.transparent_bg = false
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	viewport.size = CARD_PREVIEW_SIZE
	viewport_container.add_child(viewport)

	var preview_root := Node2D.new()
	viewport.add_child(preview_root)

	var instance := (entry["scene"] as PackedScene).instantiate()
	preview_root.add_child(instance)
	_layout_preview_root(preview_root, instance, CARD_PREVIEW_SIZE)
	_restart_particles(instance)

	var name_label := Label.new()
	name_label.text = String(entry["name"])
	name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	name_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	name_label.add_theme_color_override("font_color", TEXT_COLOR)
	body.add_child(name_label)

	return card

func _on_card_gui_input(event: InputEvent, index: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		_select_entry(index, false)

func _select_entry(index: int, change_page: bool) -> void:
	if index < 0 or index >= _particle_entries.size():
		return

	_selected_index = index
	_selected_view_offset = Vector2.ZERO
	_is_dragging_stage = false
	if change_page:
		_current_page = int(index / ITEMS_PER_PAGE)

	_apply_stage_canvas_offset()
	_show_selected_entry()
	_render_page()

func _show_selected_entry() -> void:
	_clear_stage()

	if _selected_index < 0 or _selected_index >= _particle_entries.size():
		_selected_name_label.text = "No Effect Selected"
		_selected_path_label.text = ""
		return

	var entry := _particle_entries[_selected_index]
	_selected_name_label.text = String(entry["name"])
	_selected_path_label.text = String(entry["path"]).trim_prefix("res://")

	var instance := (entry["scene"] as PackedScene).instantiate()
	_stage_root.add_child(instance)
	_layout_stage_preview()
	_restart_particles(instance)

func _update_stage_viewport() -> void:
	if _stage_viewport_container == null:
		return

	var container_size := _stage_viewport_container.size.floor()
	var viewport_size := Vector2i(maxi(int(container_size.x), 1), maxi(int(container_size.y), 1))
	if _stage_viewport.size != viewport_size:
		_stage_viewport.size = viewport_size

	_layout_stage_preview()
	_apply_stage_canvas_offset()

func _build_source_tabs() -> void:
	_source_tabs.clear_tabs()
	for source_index in range(SOURCE_GROUPS.size()):
		_source_tabs.add_tab(String(SOURCE_GROUPS[source_index]["label"]))
	_source_tabs.current_tab = _current_source_index

func _on_source_tab_changed(tab: int) -> void:
	if tab < 0 or tab >= SOURCE_GROUPS.size():
		return

	_current_source_index = tab
	_current_page = 0
	_selected_index = -1
	_selected_view_offset = Vector2.ZERO
	_is_dragging_stage = false
	_apply_stage_canvas_offset()
	_load_particle_entries()
	if _particle_entries.is_empty():
		_render_page()
	else:
		_select_entry(0, false)
	_update_stage_viewport()

func _center_preview(node: Node, viewport_size: Vector2i) -> void:
	if node is Node2D:
		_layout_preview_root(node as Node2D, node, viewport_size)

func _layout_stage_preview() -> void:
	for child in _stage_root.get_children():
		_layout_preview_root(_stage_root, child, _stage_viewport.size)

func _on_stage_viewport_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		_is_dragging_stage = event.pressed
		if _is_dragging_stage:
			accept_event()
		return

	if event is InputEventMouseMotion and _is_dragging_stage:
		_selected_view_offset += event.relative
		_apply_stage_canvas_offset()
		accept_event()

func _apply_stage_canvas_offset() -> void:
	_stage_viewport.canvas_transform = Transform2D(0.0, _selected_view_offset)

func _clear_stage() -> void:
	for child in _stage_root.get_children():
		child.queue_free()

func _layout_preview_root(preview_root: Node2D, content: Node, viewport_size: Vector2i) -> void:
	preview_root.position = Vector2.ZERO
	preview_root.scale = Vector2.ONE
	var bounds := _collect_preview_bounds(content)
	if bounds.size.is_zero_approx():
		preview_root.position = Vector2(viewport_size) * 0.5
		return
	preview_root.position = Vector2(viewport_size) * 0.5 - bounds.get_center()

func _restart_particles(node: Node) -> void:
	if node is GPUParticles2D:
		var particles := node as GPUParticles2D
		particles.emitting = true
		particles.restart()

	for child in node.get_children():
		_restart_particles(child)

func _show_previous_page() -> void:
	if _current_page <= 0:
		return

	_current_page -= 1
	_select_entry(_current_page * ITEMS_PER_PAGE, false)

func _show_next_page() -> void:
	if _current_page >= _page_count() - 1:
		return

	_current_page += 1
	_select_entry(_current_page * ITEMS_PER_PAGE, false)

func _page_count() -> int:
	if _particle_entries.is_empty():
		return 0
	return int(ceil(float(_particle_entries.size()) / float(ITEMS_PER_PAGE)))

func _current_source() -> Dictionary:
	return SOURCE_GROUPS[_current_source_index]

func _prettify_name(file_stem: String) -> String:
	var parts := file_stem.replace("_", " ").split(" ", false)
	for index in range(parts.size()):
		parts[index] = String(parts[index]).capitalize()
	return " ".join(parts)

func _apply_button_style(button: Button) -> void:
	button.add_theme_color_override("font_color", BUTTON_TEXT_COLOR)
	button.add_theme_color_override("font_focus_color", BUTTON_TEXT_COLOR)
	button.add_theme_color_override("font_hover_color", BUTTON_TEXT_COLOR)
	button.add_theme_color_override("font_hover_pressed_color", BUTTON_TEXT_COLOR)
	button.add_theme_color_override("font_pressed_color", BUTTON_TEXT_COLOR)
	button.add_theme_color_override("font_disabled_color", Color(0.50, 0.56, 0.63))

func _collect_preview_bounds(root: Node) -> Rect2:
	var rects: Array[Rect2] = []
	_collect_preview_bounds_recursive(root, Transform2D.IDENTITY, rects)
	if rects.is_empty():
		return Rect2()

	var merged := rects[0]
	for index in range(1, rects.size()):
		merged = merged.merge(rects[index])
	return merged

func _collect_preview_bounds_recursive(node: Node, parent_transform: Transform2D, rects: Array[Rect2]) -> void:
	var local_transform := parent_transform
	if node is Node2D:
		local_transform = parent_transform * (node as Node2D).transform

	if node is GPUParticles2D:
		var particles := node as GPUParticles2D
		rects.append(_transform_rect(particles.visibility_rect, local_transform))
	elif node is Sprite2D:
		var sprite := node as Sprite2D
		if sprite.texture != null:
			rects.append(_transform_rect(sprite.get_rect(), local_transform))

	for child in node.get_children():
		_collect_preview_bounds_recursive(child, local_transform, rects)

func _transform_rect(rect: Rect2, transform: Transform2D) -> Rect2:
	var top_left := transform * rect.position
	var top_right := transform * Vector2(rect.position.x + rect.size.x, rect.position.y)
	var bottom_left := transform * Vector2(rect.position.x, rect.position.y + rect.size.y)
	var bottom_right := transform * (rect.position + rect.size)

	var min_x := minf(minf(top_left.x, top_right.x), minf(bottom_left.x, bottom_right.x))
	var min_y := minf(minf(top_left.y, top_right.y), minf(bottom_left.y, bottom_right.y))
	var max_x := maxf(maxf(top_left.x, top_right.x), maxf(bottom_left.x, bottom_right.x))
	var max_y := maxf(maxf(top_left.y, top_right.y), maxf(bottom_left.y, bottom_right.y))
	return Rect2(Vector2(min_x, min_y), Vector2(max_x - min_x, max_y - min_y))

func _make_surface_style(bg_color: Color, border_color: Color, radius: int = 18) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = bg_color
	style.border_color = border_color
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.corner_radius_top_left = radius
	style.corner_radius_top_right = radius
	style.corner_radius_bottom_right = radius
	style.corner_radius_bottom_left = radius
	style.content_margin_left = 16
	style.content_margin_top = 16
	style.content_margin_right = 16
	style.content_margin_bottom = 16
	return style

func _make_card_style(is_selected: bool) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.97, 0.982, 0.992)
	style.border_color = Color(0.27, 0.55, 0.88) if is_selected else Color(0.84, 0.88, 0.93)
	style.border_width_left = 2 if is_selected else 1
	style.border_width_top = 2 if is_selected else 1
	style.border_width_right = 2 if is_selected else 1
	style.border_width_bottom = 2 if is_selected else 1
	style.corner_radius_top_left = 14
	style.corner_radius_top_right = 14
	style.corner_radius_bottom_right = 14
	style.corner_radius_bottom_left = 14
	style.content_margin_left = 10
	style.content_margin_top = 10
	style.content_margin_right = 10
	style.content_margin_bottom = 10
	return style
