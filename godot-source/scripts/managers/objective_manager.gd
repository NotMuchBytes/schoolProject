extends Node

signal objective_changed(mission_title: String, objective_text: String)
signal objective_completed(objective_text: String)
signal objective_cleared

var mission_title: String = ""
var objective_text: String = ""


func set_objective(new_mission_title: String, new_objective_text: String) -> void:
	mission_title = new_mission_title
	objective_text = new_objective_text
	objective_changed.emit(mission_title, objective_text)


func complete_current() -> void:
	if objective_text.is_empty():
		return
	objective_completed.emit(objective_text)


func clear_objective() -> void:
	mission_title = ""
	objective_text = ""
	objective_cleared.emit()

