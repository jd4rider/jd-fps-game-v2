extends Area3D

var speed : float = 30.0
var damage : int = 1

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	global_transform.origin += global_transform.basis.z * speed * delta
	
func destroy() -> void:
	queue_free()
	



func _on_timer_timeout() -> void:
	destroy() # Replace with function body.


func _on_body_entered(body) -> void:
	if body.has_method("take_damage"):
		body.take_damage(damage)
		destroy()

