extends CanvasLayer

@onready var panel: PanelContainer = $PanelContainer
@onready var name_label: Label = $PanelContainer/VBoxContainer/NameLabel
@onready var dialogue_label: Label = $PanelContainer/VBoxContainer/DialogueLevel
@onready var continue_button: Button = $PanelContainer/VBoxContainer/ContinueButton

# Usamos Array genérico para evitar errores de conversión de tipo desde los nodos
var current_dialogues: Array = []
var dialogue_index: int = 0
var is_open: bool = false

func _ready() -> void:
	panel.hide()
	continue_button.pressed.connect(next_dialogue)
	
	# Espera a que la escena se cargue para conectar con las áreas de los NPCs
	call_deferred("_connect_npc_signals")

func _connect_npc_signals() -> void:
	# Busca a todos los nodos dentro del grupo "npc"
	var npcs = get_tree().get_nodes_in_group("npc")
	for npc in npcs:
		# Busca el área de interacción dentro del NPC
		var interactive_area = npc.get_node_or_null("InteractiveArea")
		if interactive_area and interactive_area is Area2D:
			if not interactive_area.body_entered.is_connected(_on_npc_area_body_entered.bind(npc)):
				interactive_area.body_entered.connect(_on_npc_area_body_entered.bind(npc))

# Detecta cuando la colisión del jugador entra al área del NPC
func _on_npc_area_body_entered(body: Node2D, npc_node: Node2D) -> void:
	if body.is_in_group("player") and body is CharacterBody2D:
		if not is_open:
			# Nombre predeterminado del NPC o el que tenga configurado
			var c_name: String = npc_node.character_name if "character_name" in npc_node else "Robbin Hood"
			
			# Usa los diálogos del NPC si existen; si no, toma el texto preconfigurado en DialogueLevel
			var dialogues: Array = []
			if "dialogues" in npc_node and not npc_node.dialogues.is_empty():
				dialogues = npc_node.dialogues
			else:
				var default_text = dialogue_label.text if dialogue_label.text != "" else "Welcome Player! :D"
				dialogues = [default_text]
			
			show_dialogue(c_name, dialogues)

func show_dialogue(character_name: String, dialogues: Array) -> void:
	if dialogues.is_empty():
		return
	
	current_dialogues = dialogues
	dialogue_index = 0
	is_open = true
	
	name_label.text = character_name
	dialogue_label.text = str(current_dialogues[dialogue_index])
	panel.show()

func next_dialogue() -> void:
	dialogue_index += 1
	if dialogue_index >= current_dialogues.size():
		close_dialogue()
		return
	dialogue_label.text = str(current_dialogues[dialogue_index])

func close_dialogue() -> void:
	panel.hide()
	is_open = false
