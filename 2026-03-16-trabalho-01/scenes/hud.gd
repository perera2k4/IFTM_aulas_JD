extends CanvasLayer

@onready var label_fruits: Label = $MarginContainer/HBoxContainer/VBoxContainer/HBoxContainer/Label
@onready var label_deaths: Label = $MarginContainer/HBoxContainer/VBoxContainer/HBoxContainer2/Label2
@onready var label_warning: Label = $MarginContainer/warningContainer/Label

func _ready() -> void:
	# Inicializa as variáveis globais
	label_fruits.text = str(GlobalIterates.total_fruits)
	label_deaths.text = str(GlobalIterates.total_deaths)
	
	# Verifica se o checkpoint foi capturado ao trocar de cena
	if GlobalIterates.has_checkpoint:
		update_checkpoint_status()

func eat_fruit():
	# Soma +1 ao coletar uma fruta
	GlobalIterates.total_fruits += 1
	label_fruits.text = str(GlobalIterates.total_fruits)
	
func death_count():
	# Soma +1 quando recebe dano
	GlobalIterates.total_deaths += 1
	label_deaths.text = str(GlobalIterates.total_deaths)

# Altera o texto central do hud
func update_checkpoint_status():
	label_warning.text = "Checkpoint capturado"
