extends Node
## Versioned save/load. Schema migrations run before data is applied.

const SAVE_PATH := "user://savegame.json"
const CURRENT_SCHEMA_VERSION := 1

signal save_completed
signal load_completed(data: Dictionary)


func save_game(extra: Dictionary = {}) -> Error:
	var payload := _build_payload(extra)
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_error("SaveManager: failed to open save file.")
		return ERR_CANT_CREATE
	file.store_string(JSON.stringify(payload, "\t"))
	save_completed.emit()
	return OK


func load_game() -> Dictionary:
	if not FileAccess.file_exists(SAVE_PATH):
		return _default_data()

	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		push_error("SaveManager: failed to read save file.")
		return _default_data()

	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		push_warning("SaveManager: corrupt save; using defaults.")
		return _default_data()

	var migrated := _migrate(parsed)
	load_completed.emit(migrated)
	return migrated


func _build_payload(extra: Dictionary) -> Dictionary:
	var data := _default_data()
	data.merge(extra, true)
	data["schema_version"] = CURRENT_SCHEMA_VERSION
	data["saved_at"] = Time.get_datetime_string_from_system(true)
	return data


func _default_data() -> Dictionary:
	return {
		"schema_version": CURRENT_SCHEMA_VERSION,
		"total_runs": 0,
		"best_score": 0,
		"settings": {
			"master_volume": 1.0,
			"sfx_volume": 1.0,
			"music_volume": 0.8,
			"fullscreen": false,
		},
	}


func _migrate(data: Dictionary) -> Dictionary:
	var version: int = int(data.get("schema_version", 0))
	var result := data.duplicate(true)

	while version < CURRENT_SCHEMA_VERSION:
		match version:
			0:
				result = _migrate_v0_to_v1(result)
				version = 1
			_:
				push_error("SaveManager: unknown schema version %d" % version)
				return _default_data()

	result["schema_version"] = CURRENT_SCHEMA_VERSION
	return result


func _migrate_v0_to_v1(data: Dictionary) -> Dictionary:
	if not data.has("settings"):
		data["settings"] = _default_data()["settings"]
	if not data.has("total_runs"):
		data["total_runs"] = 0
	if not data.has("best_score"):
		data["best_score"] = 0
	return data
