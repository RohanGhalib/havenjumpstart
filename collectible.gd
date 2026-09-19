extends Area2D

@export var value: int = 1

var _start_y: float = 0.0
var _timer: float = 0.0
var _collected: bool = false

func _ready() -> void:
	_start_y = position.y
	_timer = randf() * 6.28 # Random phase
	body_entered.connect(_on_body_entered)

func _process(delta: float) -> void:
	if _collected:
		return
	_timer += delta * 3.5
	position.y = _start_y + sin(_timer) * 5.0
	rotation = sin(_timer * 0.5) * 0.1

func _on_body_entered(body: Node2D) -> void:
	if _collected:
		return
	if body.is_in_group("player") or body.name == "Player":
		_collected = true
		var gm = get_tree().root.find_child("GameManager", true, false)
		if gm and gm.has_method("add_star"):
			gm.add_star(value)
		
		var audio = get_tree().root.find_child("AudioManager", true, false)
		if audio and audio.has_method("play_collect"):
			audio.play_collect()

		# Smooth collect animation
		var tween = create_tween()
		tween.set_parallel(true)
		tween.tween_property(self, "scale", scale * 1.5, 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tween.tween_property(self, "modulate:a", 0.0, 0.2)
		tween.chain().tween_callback(queue_free)
