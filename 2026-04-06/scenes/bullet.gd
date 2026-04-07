extends Area2D

var speed = 250
var direction

func _ready() -> void:
	## Definir a direção baseado no angulo em que o mouse estava na hora do clique
	direction = Vector2.RIGHT.rotated(rotation)
	
func _physics_process(delta: float) -> void:
	## Move o elemento na direção e velocidade definida, respeitando o intervalo de FPS
	var velocity = direction * speed * delta
	position += velocity
	
# Quando o timer chegar ao fim ira destruir
func _on_timer_destroyer_timeout() -> void:
	#print("Removeu o tiro: " + name)
	queue_free()
