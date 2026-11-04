extends SceneTree

const Model = preload("res://model.gd")

func _initialize() -> void:
	var m = Model.new()
	var levels = m.levels
	assert(levels.size() == 18, "18 authored rooms")
	var previous = -1
	var stages = {}
	for i in range(levels.size()):
		var p = levels[i]
		stages[p.stage] = true
		assert(p.stones.size() >= 4 and p.stones.size() <= 7)
		assert(p.stones.has(p.reserve))
		if i > 0:
			assert(p.stones.has(previous), "carried reserve enters next room")
		var routes = m.solve(i)
		assert(routes.size() > 0, "room %d solvable" % (i + 1))
		for route in routes:
			assert(route.count(0) == 1)
			assert(route[p.stones.find(p.reserve)] == 0)
			assert(route.count(1) == p.left_slots)
			assert(route.count(2) == p.stones.size() - p.left_slots - 1)
		previous = p.reserve
	assert(stages.size() == 5)
	m.start(0)
	assert(not m.submit())
	assert(m.status == "playing")
	assert(not m.place(-1, 1))
	assert(not m.place(0, 9))
	var route = m.solve(0)[0]
	for j in range(route.size()):
		assert(m.place(j, route[j]))
	assert(m.balance() == 0)
	assert(m.submit())
	assert(m.status == "won")
	assert(m.advance())
	assert(m.index == 1 and m.status == "playing")
	m.start(0)
	assert(m.place(0, 1))
	assert(m.undo())
	assert(m.placements[0] == -1)
	assert(not m.undo())
	m.start(0)
	var wrong = m.solve(0)[0].duplicate()
	var reserved = wrong.find(0)
	wrong[reserved] = 1
	for j in range(wrong.size()):
		m.place(j, wrong[j])
	assert(not m.submit())
	assert(m.status == "lost")
	m.restart()
	assert(m.status == "playing" and m.placements.count(-1) == m.placements.size())
	m.start(0)
	for room in range(18):
		assert(m.index == room, "sequential campaign room")
		var path = m.solve(room)[0]
		for j in range(path.size()):
			assert(m.place(j, path[j]))
		assert(m.submit(), "campaign room %d" % (room + 1))
		if room < 17:
			assert(m.advance())
	assert(m.index == 17 and m.status == "won")
	m.start(17)
	var last = m.solve(17)[0]
	for j in range(last.size()):
		m.place(j, last[j])
	assert(m.submit())
	assert(not m.advance())
	print("PASS: 18 authored solvable rooms, reserve continuity, five stages, submit/lose/undo/restart/finale")
	quit()
