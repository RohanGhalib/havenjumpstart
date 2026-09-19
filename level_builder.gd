extends TileMapLayer

func _ready() -> void:
	build_level()

func place_platform(start_x: int, end_x: int, y: int, depth: int = 1) -> void:
	for x in range(start_x, end_x + 1):
		# Top surface tile
		var atlas_coords = Vector2i(1, 0)
		if x == start_x:
			atlas_coords = Vector2i(0, 0)
		elif x == end_x:
			atlas_coords = Vector2i(2, 0)
		set_cell(Vector2i(x, y), 0, atlas_coords)

		# Underneath fill
		for d in range(1, depth + 1):
			var fill_coords = Vector2i(1, 1)
			if x == start_x:
				fill_coords = Vector2i(0, 1)
			elif x == end_x:
				fill_coords = Vector2i(2, 1)
			set_cell(Vector2i(x, y + d), 0, fill_coords)

func build_level() -> void:
	clear()

	# Zone 1: Starting Ledge (safe warm-up area)
	place_platform(-4, 12, 27, 4)
	place_platform(5, 8, 23, 1) # Starter mini-ledge

	# Zone 2: First Gap & Stepping Stone Island
	place_platform(16, 21, 27, 3)

	# Zone 3: Ascending Terrace Stairs
	place_platform(24, 28, 25, 3)
	place_platform(31, 35, 23, 3)
	place_platform(38, 42, 21, 3)

	# Zone 4: Floating Islands over Deep Chasms
	place_platform(46, 49, 19, 2)
	place_platform(53, 56, 17, 2)
	place_platform(60, 63, 19, 2)

	# Zone 5: High Pillars & Summit Leap
	place_platform(67, 69, 17, 8)
	place_platform(73, 75, 15, 10)
	place_platform(79, 81, 13, 12)

	# Zone 6: Summit Victory Plateau
	place_platform(85, 96, 12, 13)

	# Spawn collectibles and goal
	spawn_collectibles_and_goal()

func spawn_collectibles_and_goal() -> void:
	var col_scene = preload("res://collectible.tscn")
	var goal_scene = preload("res://goal.tscn")

	var star_positions = [
		Vector2(6.5 * 16, 21.0 * 16),    # Above starter step
		Vector2(18.5 * 16, 25.0 * 16),   # On first stepping stone
		Vector2(33.0 * 16, 21.0 * 16),   # On ascending terrace
		Vector2(54.5 * 16, 15.0 * 16),   # On high floating island
		Vector2(74.0 * 16, 13.0 * 16),   # On high pillar
	]

	for pos in star_positions:
		var c = col_scene.instantiate()
		c.position = pos
		add_child(c)

	# Place Goal at Summit
	var goal = goal_scene.instantiate()
	goal.position = Vector2(90.5 * 16, 10.5 * 16)
	add_child(goal)
