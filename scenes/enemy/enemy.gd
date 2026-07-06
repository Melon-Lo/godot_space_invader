extends Area2D

signal died

var start_pos = Vector2.ZERO
var speed = 0
var bullet_scene = preload("res://scenes/enemy_bullet/enemy_bullet.tscn")
var is_dying: bool = false

# 同步左右移動的控制變數
static var last_frame: int = -1
static var time_passed: float = 0.0
var max_horizontal_offset = 20.0 # 左右移動的最大偏移量
var frequency = 2.0 # 左右擺動的頻率

@onready var screen_size = get_viewport_rect().size
@onready var move_timer: Timer = $MoveTimer
@onready var shoot_timer: Timer = $ShootTimer
@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _process(delta: float) -> void:
	position.y += speed * delta # 當 speed 大於 0 時，敵人的 Y 座標會持續增加（往下移動）

	# 確保在同一格（frame）中，全體敵人只會累加一次時間步長（解決交錯問題）
	var frame = Engine.get_process_frames()
	if frame != last_frame:
		last_frame = frame
		time_passed += delta

	# 使用正弦波（sin）配合累加的時間計算出完美同步的偏移量
	var offset_x = sin(time_passed * frequency) * max_horizontal_offset
	position.x = start_pos.x + offset_x

	if position.y > screen_size.y + 32:
		start(start_pos) # 如果超出螢幕下方，就重設回上方重新飛入


# 初始化敵人
func start(pos: Vector2) -> void:
	reset_enemy(pos)
	spawn_enemy()
	reset_move_timer()
	reset_shoot_timer()


# 重置敵人
func reset_enemy(pos: Vector2) -> void:
	speed = 0 # 將移動速度初始化為 0，避免在播放入場動畫時移動
	position = Vector2(pos.x, -50) # 將敵人的初始位置設定在螢幕上方外（例如 Y 座標為 -50）
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
	if is_dying:
		return
	is_dying = true

	# 延遲關閉碰撞偵測，避免爆炸期間再次被子彈擊中
	set_deferred("monitoring", false)
	set_deferred("monitorable", false)

	speed = 0
	animation_player.play("explode")
	await animation_player.animation_finished
	died.emit(5) # 發出死亡訊號，將參數（分數）傳回
	queue_free()


# 射擊
func shoot() -> void:
	var bullet_scene_instance = bullet_scene.instantiate()
	get_tree().root.add_child(bullet_scene_instance)
	bullet_scene_instance.start(position)


# 射擊計時器計時到期
func _on_shoot_timer_timeout() -> void:
	shoot()
	shoot_timer.wait_time = randf_range(4, 20)
	shoot_timer.start()


# 移動計時器計時到期
func _on_move_timer_timeout() -> void:
	speed = randf_range(75, 100) # 給予敵人一個向下的隨機速度，此時 _process 開始讓敵人往下移動
