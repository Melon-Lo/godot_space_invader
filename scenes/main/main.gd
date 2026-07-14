extends Node2D

@onready var ui = $CanvasLayer/UI
@onready var start_button: TextureButton = $CanvasLayer/CenterContainer/StartButton
@onready var game_over: TextureRect = $CanvasLayer/CenterContainer/GameOver
@onready var win: Label = $CanvasLayer/CenterContainer/Win
@onready var screen_transition: ColorRect = $CanvasLayer/ScreenTransition
@onready var hint: Label = $CanvasLayer/Hint
@onready var mobile_controls = $CanvasLayer/MobileControls

@export var row_enemies_count = 9
@export var column_enemies_count = 3

enum MobileMode { AUTO, FORCE_ON, FORCE_OFF }
@export var mobile_controls_mode: MobileMode = MobileMode.AUTO

var enemy_scene = preload("res://scenes/enemy/enemy.tscn")
var sparkle_scene = preload("res://scenes/sparkle/sparkle.tscn")
var warning_scene = preload("res://scenes/ui/warning.tscn")
var score = 0
var total_enemies = 0
var energy = 0
var game_state = "menu"

var button_tween: Tween
var hint_tween: Tween


func _ready() -> void:
	game_state = "menu"
	start_button.pivot_offset = start_button.size / 2.0
	start_button.show()
	game_over.hide()
	win.hide()
	ui.hide()
	mobile_controls.hide()

	start_button.mouse_entered.connect(_on_start_button_mouse_entered)
	start_button.mouse_exited.connect(_on_start_button_mouse_exited)

	if _is_mobile():
		hint.hide()
	else:
		start_hint_blinking()


# 生成所有敵人
func spawn_all_enemies() -> void:
	for x in range(row_enemies_count):
		for y in range(column_enemies_count):
			var enemy_scene_instance = enemy_scene.instantiate()
			var pos = Vector2(x * (16 + 8) + 24, 16 * 4 + y * 16)
			add_child(enemy_scene_instance)
			enemy_scene_instance.start(pos)
			enemy_scene_instance.died.connect(_on_enemy_died)


# 敵人死亡
func _on_enemy_died(value) -> void:
	if game_state != "playing":
		return
	total_enemies -= 1
	score += value
	energy = min(energy + 5, 100)
	$CanvasLayer/UI.update_score(score)
	$CanvasLayer/UI.update_energy(energy)
	mobile_controls.update_energy(energy)

	if total_enemies <= 0:
		game_state = "won"
		get_tree().call_group("enemy_bullets", "queue_free")
		win.show()
		await get_tree().create_timer(3.0).timeout
		win.hide()
		start_button.show()

		if _is_mobile():
			hint.hide()
		else:
			hint.show()
			start_hint_blinking()

		game_state = "menu"


# 按下空白鍵或 Enter 鍵 / 放大招鍵
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("start_game") and start_button.visible:
		new_game()

	if event.is_action_pressed("use_ultimate"):
		if $Player.is_dying:
			return
		if energy >= 33:
			use_ultimate()
		else:
			show_warning("Energy is not enough!")


# 顯示警告提示訊息
func show_warning(text: String) -> void:
	var warning_instance = warning_scene.instantiate()
	$CanvasLayer.add_child(warning_instance)
	warning_instance.start(text)


# 點擊開始按鈕
func _on_start_button_pressed() -> void:
	new_game()


# 新遊戲
func new_game() -> void:
	game_state = "playing"
	# 隱藏開始按鈕以防止多次點擊或觸發
	start_button.hide()
	start_button.scale = Vector2(1.0, 1.0)
	stop_hint_blinking()

	# 開始淡出至全黑
	var tween = create_tween()
	tween.tween_property(screen_transition, "color", Color(0, 0, 0, 1), 0.4)
	await tween.finished

	# 清空畫面
	get_tree().call_group("enemies", "queue_free")
	get_tree().call_group("enemy_bullets", "queue_free")
	get_tree().call_group("bullets", "queue_free")

	ui.show()
	if _is_mobile():
		mobile_controls.show()
	score = 0
	energy = 0
	total_enemies = row_enemies_count * column_enemies_count
	$CanvasLayer/UI.update_score(score)
	$CanvasLayer/UI.update_energy(energy)
	mobile_controls.update_energy(energy)
	$Player.start()
	spawn_all_enemies()

	# 稍微停留一小會兒
	await get_tree().create_timer(0.2).timeout

	# 開始淡入至透明
	var tween_in = create_tween()
	tween_in.tween_property(screen_transition, "color", Color(0, 0, 0, 0), 0.4)
	await tween_in.finished


# 放大招
func use_ultimate() -> void:
	energy -= 33
	$CanvasLayer/UI.update_energy(energy)
	mobile_controls.update_energy(energy)

	var sparkle_instance = sparkle_scene.instantiate()
	# 從畫面最下方（螢幕高度）發射，X 軸對齊玩家位置
	var spawn_pos = Vector2($Player.position.x, get_viewport_rect().size.y)
	add_child(sparkle_instance)
	sparkle_instance.position = spawn_pos


# 玩家死亡（遊戲結束）
func _on_player_died() -> void:
	if game_state != "playing":
		return
	game_state = "lost"
	game_over.show()
	await get_tree().create_timer(2.0).timeout
	game_over.hide()
	start_button.show()

	if _is_mobile():
		hint.hide()
	else:
		hint.show()
		start_hint_blinking()

	game_state = "menu"


# 滑鼠移入開始按鈕
func _on_start_button_mouse_entered() -> void:
	if button_tween and button_tween.is_valid():
		button_tween.kill()
	button_tween = create_tween()
	button_tween.tween_property(
		start_button,
		"scale",
		Vector2(1.15, 1.15),
		0.15,
	).set_trans(Tween.TRANS_SINE)


# 滑鼠移出開始按鈕
func _on_start_button_mouse_exited() -> void:
	if button_tween and button_tween.is_valid():
		button_tween.kill()
	button_tween = create_tween()
	button_tween.tween_property(
		start_button,
		"scale",
		Vector2(1.0, 1.0),
		0.15,
	).set_trans(Tween.TRANS_SINE)


# 開始閃爍提示
func start_hint_blinking() -> void:
	hint.show()
	if hint_tween and hint_tween.is_valid():
		hint_tween.kill()

	hint.modulate.a = 1.0

	hint_tween = create_tween().set_loops()

	hint_tween.tween_property(
		hint,
		"modulate:a",
		0.2,
		0.6,
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	hint_tween.tween_property(
		hint,
		"modulate:a",
		1.0,
		0.6,
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


# 停止閃爍提示
func stop_hint_blinking() -> void:
	if hint_tween and hint_tween.is_valid():
		hint_tween.kill()
	hint.hide()


# 判斷是否顯示行動裝置控制項
func _is_mobile() -> bool:
	match mobile_controls_mode:
		MobileMode.FORCE_ON:
			return true
		MobileMode.FORCE_OFF:
			return false
		_:
			var is_native_mobile = OS.has_feature("mobile")
			var is_web_mobile = OS.has_feature("web_android") or OS.has_feature("web_ios")
			return is_native_mobile or is_web_mobile
