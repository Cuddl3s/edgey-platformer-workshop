extends ParallaxBackground

@export var scroll_speed = 15
@export var bg_texture: Array[CompressedTexture2D]

@onready var sprite = $ParallaxLayer/Sprite2D

func _ready():
	sprite.texture = bg_texture.pick_random()

func _process(delta):
	sprite.region_rect.position += delta * Vector2(scroll_speed, scroll_speed)
	if sprite.region_rect.position >= Vector2(64,64):
		sprite.region_rect.position = Vector2.ZERO
