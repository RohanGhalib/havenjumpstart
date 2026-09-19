extends Area2D

var _reached: bool = false
var _timer: float = 0.0
@onready var sprite: Node2D = get_node_or_null("Sprite2D")

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _process(delta: float) -> void:
	_timer += delta * 2.0
	if sprite:
		sprite.scale = Vector2(1.0 + sin(_timer) * 0.08, 1.0 + cos(_timer) * 0.08)

func _on_body_entered(body: Node2D) -> void:
	if _reached:
		return
	if body.is_in_group("player") or body.name == "Player":
		_reached = true
		
		var audio = get_tree().root.find_child("AudioManager", true, false)
		if audio and audio.has_method("play_win"):
			audio.play_win()
			
		var gm = get_tree().root.find_child("GameManager", true, false)
		if gm and gm.has_method("player_won"):
			gm.player_won()
