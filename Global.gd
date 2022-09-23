extends Node

const LOGICAL_RES = Vector2(160, 144)

enum State {
	TITLE,
	RESTARTING_FROM_DEATH,
	CHANGING_LEVEL,
	OVERWORLD,
	ENTERING_PUZZLE,
	PUZZLE,
	ENTERING_MANUAL,
	MANUAL,
	EXPLOSION,
	DEAD,
	PUZZLE_EDIT,
}
var state = State.TITLE

var SCALE = 1

var GRIDSIZE = 16
var LOGICGRID_WIDTH = 10
var LOGICGRID_HEIGHT = 8

var HIGHLIGHTGRID_WIDTH = 8
var HIGHLIGHTGRID_HEIGHT = 6

var InputActive = true

func USecToMSec(usec : float):
	return usec / 1000.0

func MSecToTimeString(msec : int, includeMsec):
	var workingTimeLeft = msec
	
	var msComp = workingTimeLeft % 1000
	workingTimeLeft = (workingTimeLeft - msComp) / 1000
	
	var secComp = workingTimeLeft % 60
	workingTimeLeft = (workingTimeLeft - secComp) / 60
	var minComp = workingTimeLeft % 60
	workingTimeLeft = (workingTimeLeft - minComp) / 60
	#var hourComp = workingTimeLeft
	#var hourComp = workingTimeLeft % 60
	
	var resultString
	if includeMsec:
		var formatString = "%s:%s.%s"
		resultString = formatString % [str(minComp).pad_zeros(2), str(secComp).pad_zeros(2), str(msComp).pad_zeros(3)]
	else:
		if msComp > 0: # if msExist then round up the seconds
			secComp += 1
			if secComp == 60:
				secComp = 0
				minComp += 1
		
		var formatString = "%s:%s"
		resultString = formatString % [str(minComp).pad_zeros(2), str(secComp).pad_zeros(2)]
	
#	if hourComp > 0:
#		var formatString = "%d:%s:%s.%d"
#		resultString = formatString % [hourComp, str(minComp).pad_zeros(2), str(secComp).pad_zeros(2), msComp]
#	else:
#		var formatString = "%s:%s.%d"
#		resultString = formatString % [str(minComp).pad_zeros(2), str(secComp).pad_zeros(2), msComp]
		
	return resultString
