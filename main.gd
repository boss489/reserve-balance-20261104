extends Control

const Model = preload("res://model.gd")
const FONT = preload("res://assets/GowunDodum-Regular.ttf")
const W := 960.0
const H := 640.0
const MW := 390.0
const MH := 844.0
const INK := Color("243644")
const TEAL := Color("2d706e")
const GOLD := Color("c18c55")
const CREAM := Color("f3ead8")
const PAPER := Color("e3d7bf")
const RED := Color("aa574e")
const COLORS := [Color("92b1aa"), Color("d5aa6c"), Color("bd826b"), Color("8c9ca9"), Color("a2a578"), Color("bea59a"), Color("84a6a0")]

var model = Model.new()
var screen := "title"
var unlocked := 0
var selected := -1
var dragging := -1
var press_origin := Vector2.ZERO
var pointer := Vector2.ZERO
var elapsed := 0.0
var needle := 0.0
var message := ""
var motes: Array = []
var sound: AudioStreamPlayer

func _ready() -> void:
	load_progress()
	sound = AudioStreamPlayer.new()
	add_child(sound)
	queue_redraw()

func _process(delta: float) -> void:
	elapsed += delta
	var target := clampf(float(model.balance()) * 0.025, -0.32, 0.32) if screen == "game" or screen == "result" else sin(elapsed * 0.8) * 0.04
	needle = lerpf(needle, target, minf(1.0, delta * 6.0))
	for mote in motes:
		mote["life"] -= delta
		mote["pos"] += mote["vel"] * delta
	motes = motes.filter(func(m): return m.life > 0.0)
	queue_redraw()

func frame_scale() -> float:
	return minf(size.x / (MW if portrait() else W), size.y / (MH if portrait() else H))

func portrait() -> bool:
	return size.x / maxf(size.y, 1.0) < 0.8

func virtual_point(point: Vector2) -> Vector2:
	var s = maxf(frame_scale(), 0.001)
	return (point - (size - Vector2(MW, MH) * s if portrait() else size - Vector2(W, H) * s) * 0.5) / s

func rect(x: float, y: float, w: float, h: float, color: Color) -> void:
	draw_rect(Rect2(x, y, w, h), color)

func line(a: Vector2, b: Vector2, color: Color, width: float = 2.0) -> void:
	draw_line(a, b, color, width, true)

func text(value: String, x: float, y: float, points: int = 20, color: Color = INK, align: HorizontalAlignment = HORIZONTAL_ALIGNMENT_LEFT, width: float = -1.0) -> void:
	draw_string(FONT, Vector2(x, y), value, align, width, points, color)

func label_center(value: String, x: float, y: float, points: int = 20, color: Color = INK) -> void:
	text(value, x - 220, y, points, color, HORIZONTAL_ALIGNMENT_CENTER, 440)

func button(area: Rect2, caption: String, active: bool = true, accent: bool = false) -> void:
	var bg: Color = TEAL if accent else CREAM
	if not active: bg = Color("d6d0c3")
	draw_rect(area, bg)
	draw_rect(area, GOLD if active else Color("b7afa2"), false, 2.0)
	text(caption, area.position.x, area.position.y + area.size.y * 0.67, 18, Color.WHITE if accent else INK, HORIZONTAL_ALIGNMENT_CENTER, area.size.x)

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), INK)
	var s = frame_scale()
	if s <= 0: return
	if portrait():
		draw_set_transform((size - Vector2(MW, MH) * s) * 0.5, 0.0, Vector2(s, s))
		draw_mobile()
		draw_set_transform(Vector2.ZERO)
		return
	draw_set_transform((size - Vector2(W, H) * s) * 0.5, 0.0, Vector2(s, s))
	rect(0, 0, W, H, CREAM)
	# Hand-ruled paper and blueprint border; all illustration is drawn in Godot.
	for j in range(0, 640, 24):
		line(Vector2(0, j + 2), Vector2(960, j + 2), Color("e9dfce"), 1)
	rect(12, 12, 936, 616, Color("f5eddf"))
	draw_rect(Rect2(20, 20, 920, 600), GOLD, false, 2)
	for cx in [34, 926]:
		for cy in [34, 606]:
			draw_circle(Vector2(cx, cy), 3, GOLD)
	if screen == "title": draw_title()
	elif screen == "tutorial": draw_tutorial()
	else: draw_game()
	if screen == "result": draw_result()
	for mote in motes:
		var tint: Color = GOLD
		tint.a = clampf(mote.life, 0, 1)
		draw_circle(mote.pos, 2.5 * mote.life, tint)
	draw_set_transform(Vector2.ZERO)

func draw_title() -> void:
	text("ARCHIVE  /  01", 58, 75, 16, TEAL)
	text("양팔 저울", 58, 158, 64, INK)
	text("R E S E R V E   B A L A N C E", 60, 196, 17, TEAL)
	line(Vector2(60, 216), Vector2(540, 216), GOLD, 3)
	text("두 접시를 수평으로. 한 개의 돌은 다음 방으로.", 60, 255, 22)
	text("18개의 방  /  5개의 장  /  당신이 남긴 무게의 이야기", 60, 287, 16, TEAL)
	button(Rect2(60, 332, 212, 55), "처음부터" , true, true)
	button(Rect2(284, 332, 212, 55), "이어서 · %02d방" % (unlocked + 1))
	button(Rect2(60, 398, 436, 48), "조작과 규칙 살펴보기")
	text("방 선택  ·  완료한 방만 다시 열 수 있습니다", 60, 491, 16, TEAL)
	for i in range(18):
		var x = 60 + (i % 9) * 47
		var y = 508 + int(i / 9) * 46
		var available = i <= unlocked
		rect(x, y, 40, 38, TEAL if i == unlocked else PAPER if available else Color("e5e1d8"))
		text("%02d" % (i + 1), x, y + 26, 15, Color.WHITE if i == unlocked else INK if available else Color("aaa69e"), HORIZONTAL_ALIGNMENT_CENTER, 40)
	# Decorative exploded scale, an original vector illustration.
	line(Vector2(715, 125), Vector2(715, 482), INK, 9)
	line(Vector2(660, 483), Vector2(770, 483), GOLD, 12)
	var tilt = sin(elapsed * 0.8) * 0.055
	var left = Vector2(555, 295 + tilt * 160)
	var right = Vector2(875, 295 - tilt * 160)
	line(left, right, INK, 8)
	draw_circle(Vector2(715, 295), 17, GOLD)
	for p in [left, right]:
		line(p, p + Vector2(0, 77), GOLD, 2)
		line(p + Vector2(-52, 83), p + Vector2(52, 83), INK, 5)
		draw_arc(p + Vector2(0, 73), 51, 0, PI, 24, GOLD, 3)
	draw_circle(left + Vector2(0, 57), 20, COLORS[0])
	draw_circle(right + Vector2(0, 55), 13, COLORS[1])
	draw_circle(right + Vector2(30, 56), 13, COLORS[2])
	text("남겨둔 하나가 다음 문을 엽니다", 610, 543, 16, TEAL)

func draw_tutorial() -> void:
	text("사용 설명서", 58, 91, 42)
	text("01 / 규칙", 62, 142, 21, TEAL)
	text("돌을 왼쪽 · 오른쪽 접시에 나누어 올려 같은 무게로 맞추세요.", 62, 178, 21)
	text("다음 방이 요구하는 숫자의 돌은 보관함에 정확히 하나 남깁니다.", 62, 212, 21)
	text("모든 돌을 접시 또는 보관함에 배치해야 판정할 수 있습니다.", 62, 246, 21)
	line(Vector2(62, 270), Vector2(898, 270), GOLD, 2)
	text("02 / 조작", 62, 318, 21, TEAL)
	text("클릭/터치로 돌 선택 → 접시/보관함 클릭. 드래그해서 놓아도 됩니다.", 62, 352, 20)
	text("키보드: 1–7 돌 선택 · ←/L 왼쪽 · →/D 오른쪽 · S 보관", 62, 388, 19)
	text("Tab 다음 돌 · Z 되돌리기 · Enter 판정 · R 다시 시작 · Esc 메뉴", 62, 422, 19)
	text("수평만 맞춰도 끝이 아닙니다. 다음 방의 예비 돌을 지키세요.", 62, 469, 19, RED)
	button(Rect2(62, 517, 265, 57), "저울실로 들어가기", true, true)
	button(Rect2(342, 517, 190, 57), "표지로 돌아가기")

func draw_game() -> void:
	var p = model.levels[model.index]
	rect(35, 35, 890, 72, INK)
	text("%02d  /  %s" % [model.index + 1, p.note], 54, 66, 18, Color("dfc194"))
	text(p.title, 54, 94, 27, Color.WHITE)
	text("다음 방의 돌  %d" % int(p.reserve), 598, 67, 19, Color.WHITE)
	text("놓을 돌  %d개" % (p.stones.size() - 1), 598, 93, 16, Color("dfc194"))
	button(Rect2(805, 46, 102, 47), "메뉴")
	for i in range(18):
		rect(40 + i * 35, 121, 28, 5, GOLD if i < model.index else TEAL if i == model.index else PAPER)
	# Engraved balance machine, hanging pans and analog needle.
	line(Vector2(480, 207), Vector2(480, 457), INK, 11)
	line(Vector2(425, 457), Vector2(535, 457), GOLD, 10)
	draw_circle(Vector2(480, 240), 46, PAPER)
	draw_arc(Vector2(480, 240), 44, PI, TAU, 48, GOLD, 4)
	for tick in range(-3, 4):
		var a = -PI / 2 + tick * 0.17
		line(Vector2(480, 240) + Vector2(cos(a), sin(a)) * 29, Vector2(480, 240) + Vector2(cos(a), sin(a)) * 39, INK, 2)
	line(Vector2(480, 240), Vector2(480 + sin(needle) * 34, 240 - cos(needle) * 34), RED, 3)
	draw_circle(Vector2(480, 240), 5, GOLD)
	var diff = model.balance()
	text("차이  %s" % ("0  ·  수평" if diff == 0 else "%+d" % diff), 420, 294, 19, TEAL if diff == 0 else RED, HORIZONTAL_ALIGNMENT_CENTER, 120)
	var left_h = 0.0 - needle * 90
	var right_h = 0.0 + needle * 90
	line(Vector2(273, 319 + left_h), Vector2(687, 319 + right_h), INK, 8)
	draw_circle(Vector2(480, 319), 12, GOLD)
	for zone in [1, 2]:
		var cx = 310.0 if zone == 1 else 650.0
		var h = left_h if zone == 1 else right_h
		line(Vector2(cx, 319 + h), Vector2(cx, 393 + h), GOLD, 2)
		line(Vector2(cx - 105, 402 + h), Vector2(cx + 105, 402 + h), INK, 6)
		draw_arc(Vector2(cx, 382 + h), 105, 0, PI, 25, GOLD, 2)
		text("왼쪽  %s" % model.mass(1) if zone == 1 else "오른쪽  %s" % model.mass(2), cx - 95, 447, 20, INK, HORIZONTAL_ALIGNMENT_CENTER, 190)
		text("%d칸" % (p.left_slots if zone == 1 else p.stones.size() - p.left_slots - 1), cx - 70, 468, 15, TEAL, HORIZONTAL_ALIGNMENT_CENTER, 140)
	# Reserve is a tactile cabinet, visibly distinct from both pans.
	rect(773, 326, 151, 164, Color("d4c4aa"))
	draw_rect(Rect2(779, 332, 139, 152), INK, false, 2)
	text("예비 보관함", 784, 355, 18, TEAL, HORIZONTAL_ALIGNMENT_CENTER, 130)
	text("필수  %d" % int(p.reserve), 784, 382, 18, INK, HORIZONTAL_ALIGNMENT_CENTER, 130)
	line(Vector2(796, 446), Vector2(900, 446), GOLD, 3)
	# Stone rack, with all pieces visible after placement.
	rect(36, 506, 708, 98, PAPER)
	text("돌 선반  /  %d개의 돌" % p.stones.size(), 48, 531, 15, TEAL)
	for i in range(p.stones.size()):
		draw_stone(i, stone_position(i), i == selected)
	button(Rect2(759, 513, 155, 42), "되돌리기  Z", not model.history.is_empty())
	button(Rect2(759, 562, 155, 43), "문 열기  Enter", true, true)
	if message != "":
		text(message, 42, 493, 17, RED)

func stone_position(i: int) -> Vector2:
	if portrait():
		var zone_mobile: int = model.placements[i]
		if zone_mobile == -1:
			return Vector2(43 + i * 50, 682)
		if zone_mobile == 0:
			return Vector2(195, 574)
		var group_mobile: Array = []
		for j in range(model.placements.size()):
			if model.placements[j] == zone_mobile: group_mobile.append(j)
		var spacing := minf(46.0, 126.0 / maxf(1.0, group_mobile.size() - 1.0))
		return Vector2((95 if zone_mobile == 1 else 295) + (group_mobile.find(i) - (group_mobile.size() - 1) * 0.5) * spacing, 445)
	var zone = model.placements[i]
	if zone == -1:
		var tray = []
		for j in range(model.placements.size()):
			if model.placements[j] == -1: tray.append(j)
		return Vector2(91 + tray.find(i) * 91, 564)
	if zone == 0:
		return Vector2(849, 413)
	var group = []
	for j in range(model.placements.size()):
		if model.placements[j] == zone: group.append(j)
	var cx = 310 if zone == 1 else 650
	return Vector2(cx + (group.find(i) - (group.size() - 1) * 0.5) * 65, 389 + (-needle if zone == 1 else needle) * 90)

func draw_stone(i: int, at: Vector2, chosen: bool) -> void:
	var p = model.levels[model.index]
	var color: Color = COLORS[i % COLORS.size()]
	if i == dragging: at = pointer
	if chosen:
		draw_circle(at, 34, GOLD)
		draw_circle(at, 31, CREAM)
	var outline = PackedVector2Array([at + Vector2(-28, -7), at + Vector2(-19, -24), at + Vector2(9, -29), at + Vector2(28, -12), at + Vector2(30, 13), at + Vector2(13, 27), at + Vector2(-18, 23), at + Vector2(-30, 9)])
	draw_colored_polygon(outline, INK)
	var inner = PackedVector2Array()
	for pt in outline: inner.append(at + (pt - at) * 0.85)
	draw_colored_polygon(inner, color)
	line(at + Vector2(-13, -14), at + Vector2(3, -19), Color(1, 1, 1, 0.45), 3)
	text("%d" % int(p.stones[i]), at.x - 31, at.y + 8, 24, INK, HORIZONTAL_ALIGNMENT_CENTER, 62)
	if i == selected and i != dragging:
		draw_circle(at + Vector2(0, -39), 4, GOLD)

func draw_result() -> void:
	rect(0, 0, W, H, Color(0.10, 0.17, 0.21, 0.72))
	rect(215, 153, 530, 343, CREAM)
	draw_rect(Rect2(225, 163, 510, 323), GOLD, false, 3)
	var won = model.status == "won"
	label_center("수평을 찾았습니다" if won else "문이 열리지 않습니다", 480, 224, 35, TEAL if won else RED)
	var reason = model.verdict()
	var detail = "예비 돌 %d을 다음 방으로 옮깁니다." % int(model.levels[model.index].reserve) if won else (
		"보관함에 다음 방의 돌을 하나 남겨주세요." if reason == "reserve" else
		"접시의 돌 개수 조건을 확인하세요." if reason == "slots" else
		"바늘이 기울었습니다. 양쪽 무게를 맞추세요.")
	label_center(detail, 480, 278, 20)
	label_center("%02d / 18 방  ·  %d번 움직임" % [model.index + 1, model.moves], 480, 312, 17, TEAL)
	button(Rect2(259, 363, 207, 55), "다시 도전")
	button(Rect2(482, 363, 220, 55), "다음 방" if won and model.index < 17 else "모든 방 완료" if won else "표지로", true, won)
	if won and model.index == 17:
		label_center("모든 방에 무게의 균형을 되찾았습니다.", 480, 455, 18, TEAL)

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		key_action(event.keycode)
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		pointer_event(virtual_point(event.position), event.pressed)
	elif event is InputEventScreenTouch:
		pointer_event(virtual_point(event.position), event.pressed)
	elif event is InputEventMouseMotion and dragging >= 0:
		pointer = virtual_point(event.position)
	elif event is InputEventScreenDrag and dragging >= 0:
		pointer = virtual_point(event.position)

func pointer_event(pos: Vector2, pressed: bool) -> void:
	if portrait():
		mobile_pointer(pos, pressed)
		return
	if pressed:
		press_origin = pos
		pointer = pos
		if screen == "game":
			dragging = stone_at(pos)
		return
	if screen == "title":
		if Rect2(60, 332, 212, 55).has_point(pos): open_tutorial()
		elif Rect2(284, 332, 212, 55).has_point(pos): begin_game(unlocked)
		elif Rect2(60, 398, 436, 48).has_point(pos): open_tutorial()
		elif Rect2(60, 508, 423, 84).has_point(pos):
			var col = clampi(int((pos.x - 60) / 47), 0, 8)
			var row = clampi(int((pos.y - 508) / 46), 0, 1)
			var room = row * 9 + col
			if room <= unlocked: begin_game(room)
	elif screen == "tutorial":
		if Rect2(62, 517, 265, 57).has_point(pos): begin_game()
		elif Rect2(342, 517, 190, 57).has_point(pos): screen = "title"
	elif screen == "result":
		if Rect2(259, 363, 207, 55).has_point(pos): restart_room()
		elif Rect2(482, 363, 220, 55).has_point(pos):
			if model.status == "won": next_room()
			else: screen = "title"
	elif screen == "game":
		if dragging >= 0:
			var origin = dragging
			dragging = -1
			selected = origin
			if pos.distance_to(press_origin) > 18:
				var zone = hit_zone(pos)
				if zone != -2: move_selected(zone)
			return
		if Rect2(805, 46, 102, 47).has_point(pos): screen = "title"
		elif Rect2(759, 513, 155, 42).has_point(pos): undo_move()
		elif Rect2(759, 562, 155, 43).has_point(pos): check_room()
		else:
			var zone = hit_zone(pos)
			if zone != -2: move_selected(zone)
	queue_redraw()

func stone_at(pos: Vector2) -> int:
	for i in range(model.placements.size() - 1, -1, -1):
		if pos.distance_to(stone_position(i)) < (25 if portrait() else 31): return i
	return -1

func hit_zone(pos: Vector2) -> int:
	if Rect2(170, 319, 270, 165).has_point(pos): return 1
	if Rect2(525, 319, 245, 165).has_point(pos): return 2
	if Rect2(773, 326, 151, 164).has_point(pos): return 0
	if Rect2(36, 506, 708, 98).has_point(pos): return -1
	return -2

func key_action(key: Key) -> void:
	if key == KEY_ESCAPE:
		screen = "title"
	elif screen == "title" and key == KEY_ENTER:
		open_tutorial()
	elif screen == "tutorial" and key == KEY_ENTER:
		begin_game()
	elif screen == "result" and key == KEY_ENTER:
		if model.status == "won": next_room()
		else: restart_room()
	elif screen == "game":
		if key >= KEY_1 and key <= KEY_7: select_stone(int(key - KEY_1))
		elif key == KEY_TAB: select_stone((selected + 1) % model.placements.size())
		elif key == KEY_LEFT or key == KEY_L: move_selected(1)
		elif key == KEY_RIGHT or key == KEY_D: move_selected(2)
		elif key == KEY_S or key == KEY_DOWN: move_selected(0)
		elif key == KEY_UP or key == KEY_BACKSPACE: move_selected(-1)
		elif key == KEY_Z: undo_move()
		elif key == KEY_ENTER or key == KEY_SPACE: check_room()
		elif key == KEY_H: open_tutorial()
		elif key == KEY_R: restart_room()
	queue_redraw()

func open_tutorial() -> void:
	screen = "tutorial"

func begin_game(room: int = 0) -> void:
	model.start(mini(room, unlocked))
	selected = -1
	message = ""
	screen = "game"
	play_tone(440.0, 0.12)

func select_stone(i: int) -> void:
	if i >= 0 and i < model.placements.size(): selected = i

func move_selected(zone: int) -> void:
	if selected >= 0 and model.place(selected, zone):
		message = ""
		play_tone(310.0 + model.levels[model.index].stones[selected] * 12.0, 0.09)
		burst(stone_position(selected))

func undo_move() -> void:
	if model.undo():
		play_tone(260.0, 0.07)
		message = "마지막 움직임을 되돌렸습니다."

func restart_room() -> void:
	model.restart()
	selected = -1
	message = "다시 시작합니다."
	screen = "game"

func check_room() -> void:
	if model.verdict() == "incomplete":
		message = "모든 돌을 배치해 주세요. 선반에 돌이 남았습니다."
		play_tone(190.0, 0.15)
		return
	var won = model.submit()
	screen = "result"
	if won:
		unlocked = maxi(unlocked, mini(model.index + 1, 17))
		save_progress()
		for i in range(26): burst(Vector2(320 + (i * 43) % 370, 190 + (i * 29) % 190))
		play_tone(660.0, 0.25)
	else: play_tone(170.0, 0.24)

func next_room() -> void:
	if model.advance():
		selected = -1
		message = "예비 돌이 다음 방에 도착했습니다."
		screen = "game"
		play_tone(530.0, 0.18)
	else:
		screen = "title"

func burst(pos: Vector2) -> void:
	for i in range(4):
		var a = elapsed * 19 + i * TAU / 4
		motes.append({"pos": pos, "vel": Vector2(cos(a), sin(a)) * (35 + i * 13), "life": 0.55})

func play_tone(frequency: float, duration: float) -> void:
	if not is_instance_valid(sound): return
	var sample_rate = 22050
	var stream = AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = sample_rate
	stream.stereo = false
	var data = PackedByteArray()
	for i in range(int(sample_rate * duration)):
		var t = float(i) / sample_rate
		var envelope = (1.0 - t / duration) * minf(1.0, t * 100.0)
		var sample = int(sin(t * frequency * TAU) * envelope * 5800.0)
		data.append(sample & 255)
		data.append((sample >> 8) & 255)
	stream.data = data
	sound.stop()
	sound.stream = stream
	sound.play()

func load_progress() -> void:
	if FileAccess.file_exists("user://reserve_balance_save.json"):
		var saved = JSON.parse_string(FileAccess.get_file_as_string("user://reserve_balance_save.json"))
		if saved is Dictionary:
			unlocked = clampi(int(saved.get("unlocked", 0)), 0, 17)

func save_progress() -> void:
	var file = FileAccess.open("user://reserve_balance_save.json", FileAccess.WRITE)
	if file: file.store_string(JSON.stringify({"unlocked": unlocked, "version": 1}))

# Portrait is a separate Godot composition, not a scaled-down desktop canvas.
func draw_mobile() -> void:
	rect(0, 0, MW, MH, CREAM)
	for y in range(0, 844, 28):
		line(Vector2(0, y), Vector2(390, y), Color("e9dfce"), 1)
	draw_rect(Rect2(10, 10, 370, 824), GOLD, false, 2)
	if screen == "title":
		text("ARCHIVE  /  01", 28, 53, 17, TEAL)
		text("양팔 저울", 26, 126, 47)
		text("RESERVE BALANCE", 28, 158, 19, TEAL)
		line(Vector2(28, 180), Vector2(362, 180), GOLD, 3)
		text("두 접시를 수평으로 맞추세요.", 28, 220, 21)
		text("예비 돌 하나는 다음 방으로.", 28, 250, 20)
		button(Rect2(28, 283, 334, 56), "처음부터", true, true)
		button(Rect2(28, 349, 334, 56), "이어서 · %02d방" % (unlocked + 1))
		button(Rect2(28, 415, 334, 56), "조작과 규칙 살펴보기")
		text("방 선택  ·  완료한 방만 다시 열기", 28, 508, 18, TEAL)
		for i in range(18):
			var area := Rect2(28 + (i % 6) * 56, 526 + int(i / 6) * 62, 50, 50)
			rect(area.position.x, area.position.y, 50, 50, TEAL if i == unlocked else PAPER if i < unlocked else Color("e5e1d8"))
			text("%02d" % (i + 1), area.position.x, area.position.y + 33, 18, Color.WHITE if i == unlocked else INK if i < unlocked else Color("aaa69e"), HORIZONTAL_ALIGNMENT_CENTER, 50)
		text("18개의 방  /  5개의 장", 28, 752, 18, TEAL)
	elif screen == "tutorial":
		text("사용 설명서", 28, 78, 38)
		line(Vector2(28, 100), Vector2(362, 100), GOLD, 2)
		text("01 / 규칙", 28, 143, 22, TEAL)
		text("돌을 양쪽 접시에 나누어 올리고", 28, 182, 20)
		text("같은 무게로 맞추세요.", 28, 212, 20)
		text("다음 방이 요구하는 돌 하나만", 28, 253, 20)
		text("보관함에 남겨야 합니다.", 28, 283, 20)
		text("모든 돌을 배치한 뒤 판정하세요.", 28, 324, 19)
		line(Vector2(28, 350), Vector2(362, 350), GOLD, 2)
		text("02 / 조작", 28, 393, 22, TEAL)
		text("돌 터치 → 접시나 보관함 터치", 28, 433, 20)
		text("또는 돌을 끌어서 놓으세요.", 28, 463, 20)
		text("되돌리기 · 문 열기는 아래 버튼", 28, 504, 19)
		text("키보드: 1–7 선택, ← → S 배치", 28, 544, 18)
		text("Z 되돌리기 · Enter 판정", 28, 574, 18)
		text("수평과 예비 돌, 둘 다 중요합니다.", 28, 620, 19, RED)
		button(Rect2(28, 670, 334, 58), "저울실로 들어가기", true, true)
		button(Rect2(28, 742, 334, 58), "표지로 돌아가기")
	elif screen == "result":
		var won: bool = model.status == "won"
		text("%02d  /  18 방" % (model.index + 1), 28, 78, 20, TEAL)
		text("수평을 찾았습니다" if won else "문이 열리지 않습니다", 28, 166, 30, TEAL if won else RED)
		line(Vector2(28, 196), Vector2(362, 196), GOLD, 2)
		var reason: String = model.verdict()
		var details: Array = ["예비 돌을 다음 방으로 옮깁니다."] if won else ["보관함에 요구하는 돌을", "하나 남겨주세요."] if reason == "reserve" else ["접시의 돌 개수 조건을", "확인하세요."] if reason == "slots" else ["양쪽 접시의 무게를", "같게 맞추세요."]
		for i in range(details.size()): text(details[i], 28, 260 + i * 34, 21)
		text("%d번 움직임" % model.moves, 28, 377, 20, TEAL)
		button(Rect2(28, 490, 334, 60), "다시 도전")
		button(Rect2(28, 568, 334, 60), "다음 방" if won and model.index < 17 else "모든 방 완료" if won else "표지로", true, won)
		if won and model.index == 17: text("모든 방에 균형을 되찾았습니다.", 28, 688, 19, TEAL)
	else:
		draw_mobile_game()

func draw_mobile_game() -> void:
	var p = model.levels[model.index]
	rect(20, 25, 350, 125, INK)
	text("%02d / 18  ·  %s" % [model.index + 1, p.note], 30, 54, 17, Color("dfc194"))
	text(p.title, 30, 87, 25, Color.WHITE)
	text("예비 돌  %d   ·   왼쪽 %d칸" % [int(p.reserve), int(p.left_slots)], 30, 120, 18, Color.WHITE)
	button(Rect2(292, 155, 78, 48), "메뉴")
	text("돌 선택 → 접시나 보관함 터치", 20, 187, 17, TEAL)
	line(Vector2(65, 308), Vector2(325, 308), INK, 6)
	line(Vector2(195, 276), Vector2(195, 342), INK, 6)
	draw_circle(Vector2(195, 308), 10, GOLD)
	text("차이  %s" % ("0 · 수평" if model.balance() == 0 else "%+d" % model.balance()), 95, 269, 21, TEAL if model.balance() == 0 else RED, HORIZONTAL_ALIGNMENT_CENTER, 200)
	for zone in [1, 2]:
		var x = 20 if zone == 1 else 220
		rect(x, 355, 150, 155, PAPER)
		draw_rect(Rect2(x, 355, 150, 155), GOLD, false, 2)
		text("왼쪽 접시" if zone == 1 else "오른쪽 접시", x, 388, 19, TEAL, HORIZONTAL_ALIGNMENT_CENTER, 150)
		text("무게 %d" % model.mass(zone), x, 494, 18, INK, HORIZONTAL_ALIGNMENT_CENTER, 150)
	rect(20, 521, 350, 92, Color("d4c4aa"))
	draw_rect(Rect2(20, 521, 350, 92), GOLD, false, 2)
	text("예비 보관함  ·  필수 %d" % int(p.reserve), 29, 550, 19, TEAL)
	rect(20, 631, 350, 92, PAPER)
	text("돌 선반  /  %d개" % p.stones.size(), 28, 651, 16, TEAL)
	for i in range(p.stones.size()):
		var at = pointer if i == dragging else stone_position(i)
		draw_circle(at, 24 if i == selected else 22, GOLD if i == selected else INK)
		draw_circle(at, 20, COLORS[i % COLORS.size()])
		text("%d" % int(p.stones[i]), at.x - 21, at.y + 7, 20, INK, HORIZONTAL_ALIGNMENT_CENTER, 42)
	button(Rect2(20, 743, 165, 60), "되돌리기", not model.history.is_empty())
	button(Rect2(205, 743, 165, 60), "문 열기", true, true)
	if message != "":
		text(message.substr(0, 18), 20, 221, 16, RED)
		if message.length() > 18: text(message.substr(18), 20, 243, 16, RED)

func mobile_pointer(pos: Vector2, pressed: bool) -> void:
	if pressed:
		press_origin = pos
		pointer = pos
		if screen == "game":
			# A selected shelf stone takes precedence over stones already in a pan.
			dragging = -1 if selected >= 0 and model.placements[selected] == -1 and mobile_zone(pos) >= 0 else stone_at(pos)
		return
	if screen == "title":
		if Rect2(28, 283, 334, 56).has_point(pos): open_tutorial()
		elif Rect2(28, 349, 334, 56).has_point(pos): begin_game(unlocked)
		elif Rect2(28, 415, 334, 56).has_point(pos): open_tutorial()
		elif Rect2(28, 526, 334, 174).has_point(pos):
			var col := clampi(int((pos.x - 28) / 56), 0, 5)
			var row := clampi(int((pos.y - 526) / 62), 0, 2)
			var room := row * 6 + col
			if room <= unlocked: begin_game(room)
	elif screen == "tutorial":
		if Rect2(28, 670, 334, 58).has_point(pos): begin_game()
		elif Rect2(28, 742, 334, 58).has_point(pos): screen = "title"
	elif screen == "result":
		if Rect2(28, 490, 334, 60).has_point(pos): restart_room()
		elif Rect2(28, 568, 334, 60).has_point(pos):
			if model.status == "won": next_room()
			else: screen = "title"
	else:
		if dragging >= 0:
			var origin := dragging
			dragging = -1
			selected = origin
			if pos.distance_to(press_origin) > 18:
				var zone := mobile_zone(pos)
				if zone != -2: move_selected(zone)
			return
		if Rect2(292, 155, 78, 48).has_point(pos): screen = "title"
		elif Rect2(20, 743, 165, 60).has_point(pos): undo_move()
		elif Rect2(205, 743, 165, 60).has_point(pos): check_room()
		else:
			var zone := mobile_zone(pos)
			if zone != -2: move_selected(zone)
	queue_redraw()

func mobile_zone(pos: Vector2) -> int:
	if Rect2(20, 355, 150, 155).has_point(pos): return 1
	if Rect2(220, 355, 150, 155).has_point(pos): return 2
	if Rect2(20, 521, 350, 92).has_point(pos): return 0
	if Rect2(20, 631, 350, 92).has_point(pos): return -1
	return -2
