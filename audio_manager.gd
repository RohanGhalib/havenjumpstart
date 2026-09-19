extends Node

var jump_stream: AudioStream = preload("res://sounds/jump.wav")
var fail_stream: AudioStream = preload("res://sounds/fail.wav")
var win_stream: AudioStream = preload("res://sounds/win.wav")
var collect_stream: AudioStream = preload("res://sounds/collect.wav")
var click_stream: AudioStream = preload("res://sounds/click.wav")

var _players: Array[AudioStreamPlayer] = []

func _ready() -> void:
	for i in range(6):
		var p = AudioStreamPlayer.new()
		add_child(p)
		_players.append(p)

func play_sfx(stream: AudioStream, pitch_scale: float = 1.0) -> void:
	if stream == null:
		return
	for p in _players:
		if not p.playing:
			p.stream = stream
			p.pitch_scale = pitch_scale
			p.play()
			return
	if _players.size() > 0:
		_players[0].stream = stream
		_players[0].pitch_scale = pitch_scale
		_players[0].play()

func play_jump() -> void:
	play_sfx(jump_stream, randf_range(0.96, 1.04))

func play_fail() -> void:
	play_sfx(fail_stream)

func play_win() -> void:
	play_sfx(win_stream)

func play_collect() -> void:
	play_sfx(collect_stream, randf_range(0.98, 1.05))

func play_click() -> void:
	play_sfx(click_stream)
