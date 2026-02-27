extends CharacterBody2D # 繼承角色物理節點，具備處理碰撞與移動的能力

# 使用 @export 讓數值可以在右側屬性面板 (Inspector) 直接修改
@export var speed: float = 40.0 
# 用 @onready 確保遊戲開始時，程式能找到血條
@onready var health_bar = $HealthBar 
# 使用 @onready 確保遊戲執行且節點準備好後，才抓取子節點
@onready var animated_sprite = $AnimatedSprite2D 
@onready var bigmove_scene = preload("res://player_bigmove.tscn")
var screen_size # Size of the game window.
var hp = 50  # 初始血量
var max_hp = 100 # 最大血量

# 當此節點進入場景樹時執行的初始化函數 (目前沒用到可保持 pass)
func _ready() -> void:
	pass
	health_bar.max_value = max_hp
	health_bar.value = hp
	
func heal(amount):
	hp += amount
	if hp > max_hp:
		hp = max_hp
		# 重點：讓血條的「數值」等於玩家的「HP」
	health_bar.value = hp
	print("吃到漢堡！，目前：", hp)

func take_damage(amount):
	hp -= amount
	print("被怪物攻擊！目前", hp)

# 每一幀 (Frame) 都會執行一次的函數，delta 是兩幀之間的時間間隔
func _input(event):
	if event.is_action_pressed("attack_b"): # 預設是空白鍵或 Enter
			shoot()

func shoot():
	# 1. 產生一個大招
	var bigmove = bigmove_scene.instantiate()
	# 2. 把火球放到遊戲世界裡 (通常放在根節點或是主場景)
	get_tree().current_scene.add_child(bigmove)
	# 3. 把火球的位置設在玩家這
	bigmove.position = self.position


func _process(_delta: float) -> void:
	# 1. 抓取輸入方向：從 Input Map 讀取四個方向，回傳一個標準化的向量 (長度為 0~1)
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	# 2. 處理移動與動畫播放
	if direction.length() > 0:
		# 設定移動速度：方向向量 * 速度值
		velocity = direction * speed
		
		# 播放走路動畫：符合手冊 SOP 的小寫命名規範 "walk"
		animated_sprite.play("walk") 
		
		# 根據左右移動的 X 數值來翻轉角色貼圖
		if direction.x < 0:
			animated_sprite.flip_h = true  # X 為負數代表往左，翻轉圖片
		elif direction.x > 0:
			animated_sprite.flip_h = false # X 為正數代表往右，不翻轉
			
	else:
		# 3. 處理減速與停止：當沒有按鍵輸入時，將速度平滑地降至 0
		# move_toward(當前值, 目標值, 變化量)
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.y = move_toward(velocity.y, 0, speed)
		
		# 切換為待機動畫：符合手冊 SOP 的小寫命名規範 "idle"
		animated_sprite.play("idle")
	
	# 4. 執行移動：這是 CharacterBody2D 最核心的公式，會根據 velocity 進行移動並自動處理碰撞
	move_and_slide()



func _on_magnet_area_area_entered(area: Area2D) -> void:
	if area.name == "Gem" or area.has_method("collect"):
		# 告訴鑽石：你的目標是我！
		area.target = self 
