extends Area2D

signal died
signal shield_changed

@onready var screen_size = get_viewport_rect().size
@onready var ship: Sprite2D = $Ship
@onready var boosters: AnimatedSprite2D = $Ship/Boosters
@onready var gun_cooldown_timer: Timer = $GunCooldownTimer

@export var speed: float = 150.0
@export var cooldown = 0.25
@export var bullet_scene: PackedScene
@export var max_shield = 10

var can_shoot: bool = true
var ship_size = Vector2(16, 16)
# 每當我們改變 shield 的值，會執行 set_shield()。
var shield = max_shield:
	set = set_shield


func _ready() -> void:
	start()


func _process(delta: float) -> void:
	var input = Input.get_vector("move_left", "move_right", "move_up", "move_down")

	if input.x > 0:
		ship.frame = 2
		boosters.animation = "right"
	elif input.x < 0:
		ship.frame = 0
		boosters.animation = "left"
	else:
		ship.frame = 1
		boosters.animation = "forward"

	position += input * speed * delta
	position = position.clamp((ship_size / 2), screen_size - (ship_size / 2))

	if Input.is_action_just_pressed("shoot"):
		shoot()


# 初始化
func start() -> void:
	show()
	shield = max_shield
	position = Vector2(screen_size.x / 2, screen_size.y - 64) # 初始位置
	gun_cooldown_timer.wait_time = cooldown


# 射擊
func shoot() -> void:
	if not can_shoot:
		return

	can_shoot = false
	gun_cooldown_timer.start()

	var bullet_scene_instance = bullet_scene.instantiate() # 生成子彈
	get_tree().get_root().add_child(bullet_scene_instance) # 加入場景
	bullet_scene_instance.start(position + Vector2(0, -8)) # 設定子彈位置（使用子彈自己的 func）


# 射擊冷卻計時器計時到期
func _on_gun_cooldown_timer_timeout() -> void:
	can_shoot = true


# 設定護盾值
func set_shield(value) -> void:
	shield = min(max_shield, value)
	shield_changed.emit(max_shield, shield)
	if shield <= 0:
		hide()
		died.emit()


# 處理碰撞
func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemies"):
		area.explode()
		shield -= max_shield / 2.0
