extends Node

const LOGICAL_RES = Vector2(160, 144)

var SCALE = 1

var GRIDSIZE = 16
var LOGICGRID_WIDTH = 8
var LOGICGRID_HEIGHT = 6

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
		
		var formatString = "%s:%s"
		resultString = formatString % [str(minComp).pad_zeros(2), str(secComp).pad_zeros(2)]
	
#	if hourComp > 0:
#		var formatString = "%d:%s:%s.%d"
#		resultString = formatString % [hourComp, str(minComp).pad_zeros(2), str(secComp).pad_zeros(2), msComp]
#	else:
#		var formatString = "%s:%s.%d"
#		resultString = formatString % [str(minComp).pad_zeros(2), str(secComp).pad_zeros(2), msComp]
		
	return resultString
