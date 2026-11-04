extends SceneTree

func _initialize() -> void:
	var scene = load("res://main.tscn")
	assert(scene != null)
	var game = scene.instantiate()
	root.add_child(game)
	await process_frame
	game.size = Vector2(960, 640)
	assert(game.screen == "title")
	game.open_tutorial()
	assert(game.screen == "tutorial")
	game.begin_game()
	assert(game.screen == "game")
	assert(game.model.index == 0)
	for point in [game.stone_position(0), Vector2(260, 360)]:
		var touch = InputEventScreenTouch.new()
		touch.position = point
		touch.pressed = true
		game._input(touch)
		touch.pressed = false
		game._input(touch)
	assert(game.model.placements[0] == 1)
	game.undo_move()
	game.select_stone(0)
	game.move_selected(1)
	assert(game.model.placements[0] == 1)
	game.undo_move()
	assert(game.model.placements[0] == -1)
	var drag_start = InputEventScreenTouch.new()
	drag_start.position = game.stone_position(0)
	drag_start.pressed = true
	game._input(drag_start)
	var drag = InputEventScreenDrag.new()
	drag.position = Vector2(845, 375)
	game._input(drag)
	drag_start.position = drag.position
	drag_start.pressed = false
	game._input(drag_start)
	assert(game.model.placements[0] == 0)
	game.restart_room()
	assert(game.model.placements.count(-1) == 4)
	var route = game.model.solve(0)[0]
	for i in range(route.size()):
		game.model.place(i, route[i])
	game.check_room()
	assert(game.screen == "result" and game.model.status == "won")
	assert(game.unlocked >= 1)
	var save = JSON.parse_string(FileAccess.get_file_as_string("user://reserve_balance_save.json"))
	assert(save is Dictionary and int(save.unlocked) >= 1)
	game.next_room()
	assert(game.model.index == 1)
	assert(game.screen == "game")
	assert(game.virtual_point(Vector2(0, 0)) is Vector2)
	game.size = Vector2(390, 844)
	assert(game.portrait() and is_equal_approx(game.frame_scale(), 1.0))
	game.screen = "title"
	game.pointer_event(Vector2(100, 300), true)
	game.pointer_event(Vector2(100, 300), false)
	assert(game.screen == "tutorial")
	game.pointer_event(Vector2(100, 690), true)
	game.pointer_event(Vector2(100, 690), false)
	assert(game.screen == "game")
	game.pointer_event(game.stone_position(0), true)
	game.pointer_event(game.stone_position(0), false)
	game.pointer_event(Vector2(90, 420), true)
	game.pointer_event(Vector2(90, 420), false)
	assert(game.model.placements[0] == 1)
	game.pointer_event(game.stone_position(1), true)
	game.pointer_event(game.stone_position(1), false)
	game.pointer_event(game.stone_position(0), true)
	game.pointer_event(game.stone_position(0), false)
	assert(game.model.placements[1] == 1)
	game.sound.stop()
	game.sound.stream = null
	game.queue_free()
	await process_frame
	await create_timer(0.2).timeout
	print("PASS: scene title/tutorial/input/undo/restart/win/save/progression")
	quit()
