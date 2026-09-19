extends Node

enum GameState {
	START,
	PLAYING,
	FAIL,
	WIN
}

var current_state: GameState = GameState.START

var stars_collected: int = 0
var total_stars: int = 5
var elapsed_time: float = 0.0

@onready var player: CharacterBody2D = get_node_or_null("../Player")
@onready var audio_manager: Node = get_node_or_null("../AudioManager")

# UI Nodes
@onready var start_screen: Control = get_node_or_null("../UI/StartScreen")
@onready var hud: Control = get_node_or_null("../UI/HUD")
@onready var fail_screen: Control = get_node_or_null("../UI/FailScreen")
@onready var win_screen: Control = get_node_or_null("../UI/WinScreen")

@onready var hud_stars_label: Label = get_node_or_null("../UI/HUD/TopBar/StarsLabel")
@onready var win_stats_label: Label = get_node_or_null("../UI/WinScreen/Center/VBox/StatsLabel")

func _ready() -> void:
	# Connect buttons automatically
	call_deferred("_setup_connections")
	set_state(GameState.START)

func _setup_connections() -> void:
	var play_btn = get_tree().root.find_child("PlayButton", true, false)
	if play_btn and not play_btn.pressed.is_connected(start_game):
		play_btn.pressed.connect(start_game)

	var retry_btn = get_tree().root.find_child("RetryButton", true, false)
	if retry_btn and not retry_btn.pressed.is_connected(restart_game):
		retry_btn.pressed.connect(restart_game)

	var replay_btn = get_tree().root.find_child("ReplayButton", true, false)
	if replay_btn and not replay_btn.pressed.is_connected(restart_game):
		replay_btn.pressed.connect(restart_game)

	var collectibles = get_tree().get_nodes_in_group("collectibles")
	if collectibles.size() > 0:
		total_stars = collectibles.size()
	update_hud()

func _process(delta: float) -> void:
	if current_state == GameState.PLAYING:
		elapsed_time += delta
		if Input.is_key_pressed(KEY_R):
			restart_game()

	# Keyboard shortcuts for menu navigation
	if current_state == GameState.START:
		if Input.is_action_just_pressed("jump") or Input.is_key_pressed(KEY_ENTER):
			start_game()
	elif current_state == GameState.FAIL:
		if Input.is_action_just_pressed("jump") or Input.is_key_pressed(KEY_ENTER) or Input.is_key_pressed(KEY_R):
			restart_game()
	elif current_state == GameState.WIN:
		if Input.is_action_just_pressed("jump") or Input.is_key_pressed(KEY_ENTER) or Input.is_key_pressed(KEY_R):
			restart_game()

func set_state(new_state: GameState) -> void:
	current_state = new_state
	
	if start_screen:
		start_screen.visible = (new_state == GameState.START)
	if hud:
		hud.visible = (new_state == GameState.PLAYING)
	if fail_screen:
		fail_screen.visible = (new_state == GameState.FAIL)
	if win_screen:
		win_screen.visible = (new_state == GameState.WIN)
		
	if player:
		if new_state == GameState.PLAYING:
			player.set_physics_process(true)
			if "is_active" in player:
				player.is_active = true
		else:
			player.set_physics_process(false)
			if "is_active" in player:
				player.is_active = false
			player.velocity = Vector2.ZERO

func start_game() -> void:
	if audio_manager and audio_manager.has_method("play_click"):
		audio_manager.play_click()
	elapsed_time = 0.0
	set_state(GameState.PLAYING)

func add_star(amount: int = 1) -> void:
	stars_collected += amount
	update_hud()

func update_hud() -> void:
	if hud_stars_label:
		hud_stars_label.text = "⭐ %d / %d" % [stars_collected, total_stars]

func player_failed() -> void:
	if current_state != GameState.PLAYING:
		return
	if audio_manager and audio_manager.has_method("play_fail"):
		audio_manager.play_fail()
	set_state(GameState.FAIL)

func player_won() -> void:
	if current_state != GameState.PLAYING:
		return
	if win_stats_label:
		var mins = int(elapsed_time) / 60
		var secs = int(elapsed_time) % 60
		var millis = int((elapsed_time - int(elapsed_time)) * 100)
		win_stats_label.text = "Stars: %d / %d\nTime: %02d:%02d.%02d" % [stars_collected, total_stars, mins, secs, millis]
	set_state(GameState.WIN)

func restart_game() -> void:
	if audio_manager and audio_manager.has_method("play_click"):
		audio_manager.play_click()
	get_tree().reload_current_scene()
