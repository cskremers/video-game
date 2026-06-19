extends Node
## Session and run state. Tracks high-level game flow between menu, lobby, and run.

enum SessionPhase { MENU, LOBBY, IN_GAME, RESULTS }

signal phase_changed(new_phase: SessionPhase)
signal run_started(seed_value: int)
signal run_ended(success: bool)

var phase: SessionPhase = SessionPhase.MENU
var run_seed: int = 0
var is_paused: bool = false
var max_players: int = 8


func set_phase(new_phase: SessionPhase) -> void:
	if phase == new_phase:
		return
	phase = new_phase
	phase_changed.emit(new_phase)


func start_run(seed_value: int = -1) -> void:
	run_seed = seed_value if seed_value >= 0 else randi()
	set_phase(SessionPhase.IN_GAME)
	run_started.emit(run_seed)


func end_run(success: bool) -> void:
	set_phase(SessionPhase.RESULTS)
	run_ended.emit(success)


func return_to_menu() -> void:
	is_paused = false
	set_phase(SessionPhase.MENU)
	SceneRouter.go_to_main_menu()
