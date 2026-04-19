extends Area2D

class_name Bullet

var speed = 250
var direction

# define a direcao do tiro com base na rotacao atual
func _ready() -> void:
	## definir a direção baseado no angulo em que o mouse estava na hora do clique
	direction = Vector2.RIGHT.rotated(rotation)
	
func _physics_process(delta: float) -> void:
	## move o elemento na direção e velocidade definida, respeitando o intervalo de FPS
	var velocity = direction * speed * delta
	position += velocity
	
# quando o timer chegar ao fim ira destruir
# remove o tiro da cena quando o tempo de vida acaba
func _on_timer_destroyer_timeout() -> void:
	#print("Removeu o tiro: " + name)
	queue_free()
