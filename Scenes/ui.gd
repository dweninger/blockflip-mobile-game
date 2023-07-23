extends CanvasLayer

class_name UI

@onready var points_screen = $PointsScreen
@onready var points_label = $PointsScreen/Pointslabel
@onready var title_label = $MainMenu/TitleLabel
@onready var score_label = $MainMenu/ScoreLabel
@onready var main_menu = $MainMenu
@onready var skin_screen = $SkinScreen
@onready var skin_grid = $SkinScreen/MarginContainer/GridContainer

signal start_game
signal change_skin(skin_source)

var selected_skin = null
var cur_points = 0
# Google Play Billing API Vars
var payment
var item_token

const SKIN_TEXTURES = [
	"res://Assets/Sprites/block.png",
	"res://Assets/Sprites/blockgreenskin.png",
	"res://Assets/Sprites/blockredskin.png",
	"res://Assets/Sprites/blockchocolateswirlskin.png",
	"res://Assets/Sprites/blockhazardskin.png",
	"res://Assets/Sprites/blockleafskin.png",
	"res://Assets/Sprites/blockmarbelskin.png",
	"res://Assets/Sprites/blockpastelskin.png",
	"res://Assets/Sprites/blockwoodskin.png",
	# Add more skin textures as needed
]

var skin_data = {
	"res://Assets/Sprites/block.png": {
		"locked": false,
		"price": 0
	},
	"res://Assets/Sprites/blockgreenskin.png": {
		"locked": false,
		"price": 0
	},
	"res://Assets/Sprites/blockredskin.png": {
		"locked": false,
		"price": 0
	},
	"res://Assets/Sprites/blockchocolateswirlskin.png": {
		"locked": true,
		"price": 0
	},
	"res://Assets/Sprites/blockhazardskin.png": {
		"locked": true,
		"price": 0.50
	},
	"res://Assets/Sprites/blockleafskin.png": {
		"locked": true,
		"price": 0.50
	},
	"res://Assets/Sprites/blockmarbelskin.png": {
		"locked": true,
		"price": 0.50
	},
	"res://Assets/Sprites/blockpastelskin.png": {
		"locked": true,
		"price": 0.50
	},
	"res://Assets/Sprites/blockwoodskin.png": {
		"locked": true,
		"price": 0.50
	},
}

func _ready():
	points_label.text = "%d" % 0
	score_label.text = "LAST SCORE: {cur_points}\nHIGH SCORE: {highest_record}".format({
		"cur_points": SaveLoad.last_score,
		"highest_record": SaveLoad.highest_record
	})
	
	if Engine.has_singleton("GodotGooglePlayBilling"):
		payment = Engine.get_singleton("GodotGooglePlayBilling")
		# These are all signals supported by the API
		# You can drop some of these based on your needs
		#payment.billing_resume.connect(_on_billing_resume) # No params
		payment.connected.connect(_on_connected) # No params
		#payment.disconnected.connect(_on_disconnected) # No params
		#payment.connect_error.connect(_on_connect_error) # Response ID (int), Debug message (string)
		#payment.price_change_acknowledged.connect(_on_price_acknowledged) # Response ID (int)
		payment.purchases_updated.connect(_on_purchases_updated) # Purchases (Dictionary[])
		#payment.purchase_error.connect(_on_purchase_error) # Response ID (int), Debug message (string)
		#payment.product_details_query_completed.connect(_on_product_details_query_completed) # Products (Dictionary[])
		#payment.product_details_query_error.connect(_on_product_details_query_error) # Response ID (int), Debug message (string), Queried SKUs (string[])
		payment.purchase_acknowledged.connect(_on_purchase_acknowledged) # Purchase token (string)
		#payment.purchase_acknowledgement_error.connect(_on_purchase_acknowledgement_error) # Response ID (int), Debug message (string), Purchase token (string)
		payment.purchase_consumed.connect(_on_purchase_consumed) # Purchase token (string)
		#payment.purchase_consumption_error.connect(_on_purchase_consumption_error) # Response ID (int), Debug message (string), Purchase token (string)
		#payment.query_purchases_response.connect(_on_query_purchases_response) # Purchases (Dictionary[])

		payment.startConnection()
	else:
		print("Android IAP support is not enabled. Make sure you have enabled 'Custom Build' and the GodotGooglePlayBilling plugin in your Android export settings! IAP will not work.")
	
	# Create skin buttons
	for i in range(SKIN_TEXTURES.size()):
		var button = Button.new()
		button.name = "Skin" + str(i + 1)  # Set a unique name for the button (optional)
		var texture_path = SKIN_TEXTURES[i]
		var texture = load(SKIN_TEXTURES[i])
		button.icon = texture
		var callable = Callable(self, "_on_skin_button_pressed").bind(SKIN_TEXTURES[i])
		button.connect("pressed", callable)
		skin_grid.add_child(button)
		var skin_info = skin_data[texture_path]
		
		# Check if the skin is locked
		if skin_info["locked"]:
			var panel = Panel.new()
			panel.custom_minimum_size.x = 64
			panel.custom_minimum_size.y = 64
			panel.mouse_filter = Control.MOUSE_FILTER_PASS
			#panel.color = Color(0.5, 0.5, 0.5, 0.5)
			button.add_child(panel)
			# Add the price text to the button label
			var label = Label.new()
			label.text = "Locked\n$%.2f" % skin_info["price"]
			label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			label.add_theme_font_size_override("font_size", 12)
			label.position.x = (button.get_minimum_size().x - label.get_minimum_size().x) / 2
			label.position.y = (button.get_minimum_size().y - label.get_minimum_size().y) / 2
			label.mouse_filter = Control.MOUSE_FILTER_PASS
			panel.add_child(label)
	
func update_points(points: int):
	points_label.text = "%d" % points
	cur_points = points
	
func update_high_score():
	score_label.text = "LAST SCORE: {cur_points}\nHIGH SCORE: {highest_record}".format({
		"cur_points": SaveLoad.last_score,
		"highest_record": SaveLoad.highest_record
	})

# Show/hide menues
func on_game_over():
	points_label.hide()

# Go to main menu
func _on_back_button_pressed():
	skin_screen.hide()
	main_menu.show()
	selected_skin = null

# start game	
func _on_start_button_pressed():
	main_menu.hide()
	points_screen.show()
	start_game.emit()

# Go to skins menu
func _on_skins_button_pressed():
	main_menu.hide()
	skin_screen.show()

# Select skin
func _on_skin_button_pressed(skin_source):
	selected_skin = skin_source

# Select skin
func _on_select_button_pressed():
	if selected_skin != null:
		if !skin_data[selected_skin]["locked"]:
			change_skin.emit(selected_skin)
			
	if selected_skin == null || !skin_data[selected_skin]["locked"]:
		skin_screen.hide()
		main_menu.show()

func _on_purchase_button_pressed():
	var response = payment.purchase[selected_skin]
	print("purchase has been attempted. result: " + response.status)
	if response.status != OK:
		print("error purchasing item")
	
# Google Play Purchase API functions
func _on_connected():
	payment.querySkuDetails([selected_skin], "inapp")
	
func _on_purchases_updated(items):
	for item in items:
		if !item.is_acknowledged:
			print("acknowledge Purchases: " + item.purchase_token)
			payment.acknowledgePurchase(item.purchase_token)
	if items.size() > 0:
		item_token = items[items.size() - 1].purchase_token

func _on_purchase_acknowledged(token):
	print("purchase was acknowledged! " + token)
	
func _on_purchase_consumed(token):
	print("item was consumed " + token)
