extends Node


var default = {
    "volume": 75
   }

var settings = {}

func _ready():
    load_settings()


func save_settings():
    var file = File.new()
    file.open("user://game_settings.json", File.WRITE)
    file.store_var(settings)
    file.close()



func load_settings():
    var file = File.new()
    if file.file_exists("user://game_settings.json"):
        file.open("user://game_settings.json", File.READ)
        settings = file.get_var()
        file.close()
        for key in default.keys():
            if not key in settings.keys():
                settings[key] = default[key].duplicate()
    else:
        settings = default.duplicate()
