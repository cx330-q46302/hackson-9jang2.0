extends Area2D
var speed = 600

func _ready() -> void:
	$AnimatedSprite2D.play("attack")


func _on_area_entered(area: Area2D) -> void:
	# 檢查撞到的東西有沒有「受傷」這個指令
	if area.has_method("take_damage"):
		area.take_damage(120) # 造成 20 點傷害
		explode() # 呼叫爆炸或消失

func explode():
	# 打到東西後要消失，不然會穿透
	queue_free() 


func _on_animated_sprite_2d_animation_finished() -> void:
	explode()
