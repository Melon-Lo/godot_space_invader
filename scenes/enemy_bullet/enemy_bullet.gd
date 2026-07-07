extends Area2D

@export var speed: float = 150.0

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

var is_exploding: bool = false


func _ready() -> void:
	sprite_2d.hide()
	animated_sprite_2d.show()


func start(pos: Vector2) -> void:
	position = pos
	is_exploding = false
	sprite_2d.hide()
	animated_sprite_2d.show()


func _process(delta: float) -> void:
	if is_exploding:
		return
	position.y += speed * delta


# 移出畫面
func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()


# 處理碰撞
func _on_area_entered(area: Area2D) -> void:
	if area.name == "Player":
		area.shield -= 1
		explode()


# 爆炸
func explode() -> void:
	is_exploding = true
	set_deferred("monitoring", false)
	set_deferred("monitorable", false)
	animated_sprite_2d.hide()
	sprite_2d.show()
	animation_player.play("explode")
	await animation_player.animation_finished
	queue_free()
