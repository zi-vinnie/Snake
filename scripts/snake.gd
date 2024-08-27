extends Node2D

var direction = [Vector2i(0, -1)]
var parts = [Vector2i(0, -1), Vector2i(0, 0)]
var length = 2
const minDelay = 0.05
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for part in parts:
		$SnakeTiles.set_cell(part, 0, Vector2i(0, 0))
	
	spawnApple()

func spawnApple() -> void:
	var spawnAppleLocation = Vector2i(randi_range(-10, 9), randi_range(-10, 9))
	while $SnakeTiles.get_cell_atlas_coords(spawnAppleLocation) == Vector2i(0, 0):
		spawnAppleLocation = Vector2i(randi_range(-10, 9), randi_range(-10, 9))
			
	$SnakeTiles.set_cell(spawnAppleLocation, 0, Vector2i(2, 0))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	var newDirection : Vector2i
	if Input.is_action_just_pressed("right"):
		newDirection = Vector2i(1, 0)
	elif Input.is_action_just_pressed("left"):
		newDirection = Vector2i(-1, 0)
	elif Input.is_action_just_pressed("up"):
		newDirection = Vector2i(0, -1)
	elif Input.is_action_just_pressed("down"):
		newDirection = Vector2i(0, 1)
	if newDirection != Vector2i() and direction[-1] != newDirection and direction[-1] != newDirection*Vector2i(-1, -1):
		direction.push_back(newDirection)
		
func _on_update_timeout() -> void:
	if direction.size() > 1:
		direction.pop_front()
	
	#Check for snake ahead
	if $SnakeTiles.get_cell_atlas_coords(parts[0] + direction[0]) == Vector2i(0, 0):
		print("Snake Hit Itself")
		$Update.stop()
		return
	
	#Check for apple ahead
	if $SnakeTiles.get_cell_atlas_coords(parts[0] + direction[0]) == Vector2i(2, 0):
		print("Apple Collected")
		length += 1
		spawnApple()
		$Update.start($Update.wait_time*0.9 + 0.1*minDelay)
		print($Update.wait_time)

	#Move head forward
	parts.push_front(parts[0] + direction[0])

	#Check for wall collision
	if (parts[0].x < -10 or 9 < parts[0].x) or (parts[0].y < -10 or 9 < parts[0].y):
		print("Hit Wall")
		$Update.stop()
		return
	
	$SnakeTiles.set_cell(parts[0], 0, Vector2(0, 0))
	
	#Remove tail of snake
	if parts.size() > length:
		$SnakeTiles.set_cell(parts.pop_back(), 0, Vector2(0, 1))
