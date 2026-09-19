extends CharacterBody2D

const SPEED = 550.0
const JUMP_VELOCITY = -850.0
const FALL_LIMIT_Y = 750.0

var is_active: bool = false
var _start_position: Vector2
var _was_on_floor: bool = false

@onready var sprite: Sprite2D = get_node_or_null("Sprite2D")
@onready var audio_manager: Node = get_tree().root.find_child("AudioManager", true, false)
@onready var game_manager: Node = get_tree().root.find_child("GameManager", true, false)

func _ready() -> void:
	add_to_group("player")
	_start_position = global_position

func _physics_process(delta: float) -> void:
	if not is_active:
		return

	# Fall death detection
	if global_position.y > FALL_LIMIT_Y:
		is_active = false
		if game_manager and game_manager.has_method("player_failed"):
			game_manager.player_failed()
		return

	# Apply gravity
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Jump handling
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		if audio_manager and audio_manager.has_method("play_jump"):
			audio_manager.play_jump()
		# Slight squash on jump
		if sprite:
			var tw = create_tween()
			tw.tween_property(sprite, "scale", Vector2(0.5, 1.2), 0.08)
			tw.tween_property(sprite, "scale", Vector2(0.615, 0.997), 0.12)

	# Movement handling
	var direction := Input.get_axis("left", "right")
	if direction != 0.0:
		velocity.x = direction * SPEED
		if sprite:
			sprite.flip_h = (direction < 0)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED * 1.5)

	# Landing squash
	var just_landed = is_on_floor() and not _was_on_floor
	if just_landed and sprite:
		var tw = create_tween()
		tw.tween_property(sprite, "scale", Vector2(0.75, 0.8), 0.06)
		tw.tween_property(sprite, "scale", Vector2(0.615, 0.997), 0.1)

	_was_on_floor = is_on_floor()
	move_and_slide()

func respawn() -> void:
	global_position = _start_position
	velocity = Vector2.ZERO
	is_active = true
	if sprite:
		sprite.scale = Vector2(0.615, 0.997)
		sprite.flip_h = false
