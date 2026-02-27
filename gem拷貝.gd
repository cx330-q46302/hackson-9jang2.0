extends Area2D

var experience_value = 10 # 這一顆給多少經驗
var speed = 0             # 初始速度為 0，等被吸引再動
var target = null         # 飛向的目標（玩家）

func _process(delta):
	if target:
		# 如果有目標，就往目標飛
		var direction = (target.global_position - global_position).normalized()
		speed += 20 # 加速度感，越飛越快
		global_position += direction * speed * delta



func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		# 如果玩家有加經驗的功能
		if body.has_method("add_experience"):
			body.add_experience(experience_value)
		# 播放一個音效或消失
		queue_free()
