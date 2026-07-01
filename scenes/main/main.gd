extends Node2D

var enemy_scene = preload("res://scenes/enemy/enemy.tscn")
var score = 0

# 生成所有敵人
func spawn_all_enemies() -> void:
	for x in range(9):
		for y in range(3):
			var enemy_scene_instance = enemy_scene.instantiate()
			var pos = Vector2(x * (16 + 8) + 24, 16 * 4 + y * 16)
			add_child(enemy_scene_instance)
			enemy_scene_instance.start(pos)
			enemy_scene_instance.died.connect(_on_enemy_died)

# 敵人死亡
func _on_enemy_died(value) -> void:
	score += value

func _ready() -> void:
	spawn_all_enemies()
