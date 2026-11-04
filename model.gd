extends RefCounted

var levels: Array = []
var index := 0
var placements: Array[int] = [] # -1 tray, 0 reserve, 1 left, 2 right
var history: Array = []
var status := "playing"
var moves := 0

func _init() -> void:
	var parsed = JSON.parse_string(FileAccess.get_file_as_string("res://levels.json"))
	if parsed is Array:
		levels = parsed
	start(0)

func start(room: int) -> void:
	index = clampi(room, 0, levels.size() - 1)
	placements.clear()
	for _stone in levels[index].stones:
		placements.append(-1)
	history.clear()
	moves = 0
	status = "playing"

func restart() -> void:
	start(index)

func place(stone: int, zone: int) -> bool:
	if status != "playing" or stone < 0 or stone >= placements.size() or zone < -1 or zone > 2:
		return false
	if placements[stone] == zone:
		return false
	history.append(placements.duplicate())
	placements[stone] = zone
	moves += 1
	return true

func undo() -> bool:
	if status != "playing" or history.is_empty():
		return false
	placements = history.pop_back()
	moves += 1
	return true

func mass(zone: int) -> int:
	var total := 0
	for i in range(placements.size()):
		if placements[i] == zone:
			total += int(levels[index].stones[i])
	return total

func balance() -> int:
	return mass(1) - mass(2)

func verdict() -> String:
	if placements.has(-1):
		return "incomplete"
	var p = levels[index]
	if placements.count(0) != 1 or placements[p.stones.find(p.reserve)] != 0:
		return "reserve"
	if placements.count(1) != int(p.left_slots) or placements.count(2) < 1:
		return "slots"
	if balance() != 0:
		return "tilt"
	return "balanced"

func submit() -> bool:
	if status != "playing":
		return false
	if verdict() == "incomplete":
		return false
	status = "won" if verdict() == "balanced" else "lost"
	return status == "won"

func advance() -> bool:
	if status != "won" or index + 1 >= levels.size():
		return false
	start(index + 1)
	return true

func solve(room: int) -> Array:
	var p = levels[room]
	var routes: Array = []
	var count = int(pow(3, p.stones.size()))
	for number in range(count):
		var state: Array[int] = []
		var n = number
		var left := 0
		var right := 0
		for value in p.stones:
			var zone = n % 3
			n = n / 3
			state.append(zone)
			if zone == 1:
				left += int(value)
			elif zone == 2:
				right += int(value)
		if state.count(0) == 1 and state[p.stones.find(p.reserve)] == 0 and state.count(1) == int(p.left_slots) and state.count(2) >= 1 and left == right:
			routes.append(state)
	return routes
