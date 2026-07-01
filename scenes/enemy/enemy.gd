extends Area2D

signal died

var start_pos = Vector2.ZERO
var speed = 0

@onready var screen_size = get_viewport_rect().size
@onready var move_timer: Timer = $MoveTimer
@onready var shoot_timer: Timer = $ShootTimer
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _process(delta: float) -> void:
	position.y += speed * delta
	if position.y > screen_size.y + 32:
		start(start_pos)

# 初始化敵人
func start(pos: Vector2) -> void:
	reset_enemy(pos)
	spawn_enemy()
	reset_move_timer()
	reset_shoot_timer()

# 重置敵人
func reset_enemy(pos: Vector2) -> void:
	speed = 0 # 將移動速度初始化為 0，避免在播放入場動畫時移動
	position = Vector2(pos.x, pos.y) # # 將敵人的初始位置設定為傳入的 pos 座標
	start_pos = pos # 將目標位置記錄在 start_pos 變數中

# 重置移動計時器
func reset_move_timer() -> void:
	move_timer.wait_time = randf_range(5, 20) # 隨機設定移動計時器的等待時間（5 ~ 20 秒）
	move_timer.start() # 啟動移動計時器

# 重置射擊計時器
func reset_shoot_timer() -> void:
	shoot_timer.wait_time = randf_range(4, 20) # 隨機設定射擊計時器的等待時間（4 ~ 20 秒）
	shoot_timer.start() # 啟動射擊計時器

# 生成敵人
func spawn_enemy() -> void:
	# 隨機等待 0.25 到 0.55 秒，讓多個敵人生成時有錯開的出場效果
	await get_tree().create_timer(randf_range(0.25, 0.55)).timeout
	# 建立一個 Tween 動畫，並設定過渡曲線為 TRANS_BACK（帶有回彈動態效果）
	var tween = create_tween().set_trans(Tween.TRANS_BACK)
	# 在 1.4 秒內，將敵人的 Y 軸位置平滑過渡到目標位置 start_pos.y
	tween.tween_property(self, "position:y", start_pos.y, 1.4)
	await tween.finished # 等待出場 Tween 動畫播放完畢

# 爆炸
func explode() -> void:
	speed = 0
	animation_player.play("explode")
	died.emit(5)
	await animation_player.animation_finished
	queue_free()

# 射擊
func shoot() -> void:
	pass

# 射擊計時器計時到期
func _on_shoot_timer_timeout() -> void:
	speed = randf_range(75, 100)

# 移動計時器計時到期
func _on_move_timer_timeout() -> void:
	shoot()
	shoot_timer.wait_time = randf_range(4, 20)
	shoot_timer.start()
