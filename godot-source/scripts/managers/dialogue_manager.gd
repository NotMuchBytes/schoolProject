extends Node

signal dialogue_started(context_id: String)
signal line_changed(speaker: String, text: String, line_index: int, line_count: int)
signal line_metadata_changed(entry: Dictionary)
signal dialogue_finished(context_id: String)

var _entries: Array = []
var _line_index: int = -1
var _context_id: String = ""


func start_dialogue(context_id: String, entries: Array) -> bool:
	if entries.is_empty():
		return false
	_entries = VoiceCatalog.normalize_entries(context_id, entries)
	_line_index = 0
	_context_id = context_id
	# Keep ambient chatter and background mix reduced for the full conversation,
	# including the intentionally silent player subtitle turns.
	VoiceDirector.begin_dialogue_session(StringName(_context_id))
	dialogue_started.emit(_context_id)
	_emit_current_line()
	return true


func advance() -> void:
	if not is_active():
		return
	# The first press during recorded speech finishes the current voice line. A
	# second press advances, preventing accidental loss of the next subtitle.
	if VoiceDirector.stop_dialogue(true):
		return
	_line_index += 1
	if _line_index >= _entries.size():
		finish_dialogue()
	else:
		_emit_current_line()


func finish_dialogue() -> void:
	if _line_index < 0 or _entries.is_empty():
		return
	var completed_context := _context_id
	VoiceDirector.stop_dialogue(false)
	VoiceDirector.end_dialogue_session(StringName(completed_context))
	_entries.clear()
	_line_index = -1
	_context_id = ""
	dialogue_finished.emit(completed_context)


func cancel_dialogue() -> void:
	finish_dialogue()


func is_active() -> bool:
	return _line_index >= 0 and _line_index < _entries.size()


func get_context_id() -> String:
	return _context_id


func get_current_entry() -> Dictionary:
	if not is_active():
		return {}
	return (_entries[_line_index] as Dictionary).duplicate(true)


func get_current_line_id() -> String:
	return str(get_current_entry().get("line_id", ""))


func _emit_current_line() -> void:
	var entry: Dictionary = _entries[_line_index]
	VoiceDirector.play_dialogue_entry(entry)
	line_metadata_changed.emit(entry.duplicate(true))
	line_changed.emit(
		str(entry.get("speaker", "الراوي")),
		str(entry.get("text", "")),
		_line_index,
		_entries.size()
	)
