extends Node
## Lightweight crash/error logging for production builds.
## Wire Sentry SDK later by POSTing to SENTRY_DSN in CI secrets.

const CRASH_DIR := "user://crashes/"
const MAX_LOCAL_CRASHES := 10

var build_version: String = "unknown"
var sentry_dsn: String = ""


func _ready() -> void:
	build_version = _read_version()
	get_tree().auto_accept_quit = false
	if not DirAccess.dir_exists_absolute(CRASH_DIR):
		DirAccess.make_dir_recursive_absolute(CRASH_DIR)


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		get_tree().quit()


func capture_error(message: String, context: Dictionary = {}) -> void:
	var entry := {
		"timestamp": Time.get_datetime_string_from_system(true),
		"version": build_version,
		"message": message,
		"context": context,
	}
	_write_crash_file(entry)
	push_error("[CrashReporter] %s" % message)


func capture_exception(source: String, details: Dictionary = {}) -> void:
	capture_error("Exception in %s" % source, details)


func _read_version() -> String:
	if FileAccess.file_exists("res://version.txt"):
		return FileAccess.get_file_as_string("res://version.txt").strip_edges()
	return "0.0.0-dev"


func _write_crash_file(entry: Dictionary) -> void:
	var files := _list_crash_files()
	while files.size() >= MAX_LOCAL_CRASHES:
		DirAccess.remove_absolute(files[0])
		files = _list_crash_files()

	var path := CRASH_DIR + "crash_%d.json" % Time.get_unix_time_from_system()
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(entry, "\t"))


func _list_crash_files() -> PackedStringArray:
	var result: PackedStringArray = []
	var dir := DirAccess.open(CRASH_DIR)
	if dir == null:
		return result
	dir.list_dir_begin()
	var name := dir.get_next()
	while name != "":
		if not dir.current_is_dir() and name.ends_with(".json"):
			result.append(CRASH_DIR + name)
		name = dir.get_next()
	dir.list_dir_end()
	result.sort()
	return result
