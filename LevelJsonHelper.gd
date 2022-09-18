extends Node

func Save(levelName, levelData):
    var file = File.new()
    file.open("user://level_" + levelName + ".json", File.WRITE)
    file.store_line(to_json(levelData))
    file.close()

func Load(levelName):
	var filePath = "user://level_" + levelName + ".json"
	var file = File.new()
	if file.file_exists(filePath):
		file.open(filePath, File.READ)
		var data = parse_json(file.get_as_text())
		file.close()
		return data
	else:
		push_error("Load Error: file did not exist - filePath = " + filePath)
		return null