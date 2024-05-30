extends Node
class_name GameConfig

static var level_config
static var level_config_path = "res://Config/LevelConfig.json"

static func load_config():
	level_config = GameUtils.get_json(level_config_path)
