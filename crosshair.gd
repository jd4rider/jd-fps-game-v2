extends Control

@onready var crosshair: Sprite2D = $Crosshair_png


# Called when the node enters the scene tree for the first time.
#func _ready() -> void:
#	get_tree().get_root().size_changed.connect(find_crosshair_pos)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

#func find_crosshair_pos ():
#	var screen_size = get_viewport_rect().size
	
#	var middle = screen_size/2
	
	#sprite_2d.transform = Transform2D(middle.x, middle.y)
#	crosshair.position = middle
