extends TileMap

const MaxDigits = 4

var CharToCellIndex = {
	ord('0') : 0,
	ord('1') : 1,
	ord('2') : 2,
	ord('3') : 3,
	ord('4') : 4,
	ord('5') : 5,
	ord('6') : 6,
	ord('7') : 7,
	ord('8') : 8,
	ord('9') : 9,
}

# super hard coded nonsense by me (dom)
func SetTimerText(text):
	var asciiText = text.to_ascii()
	var textSize = asciiText.size()

	# we are filling in 4 digits for our time
	assert(textSize == (MaxDigits + 1)) #plus one for the ':' in the time 
	
	var char0 = asciiText[0]
	var cellIndex0 = CharToCellIndex[char0]
	set_cell(0, 0, cellIndex0)
	
	var char1 = asciiText[1]
	var cellIndex1 = CharToCellIndex[char1]
	set_cell(1, 0, cellIndex1)
	
	# skip index 2 as it's the ':'
	var char2 = asciiText[2]
	assert(char2 == ord(':'))
	
	var char3 = asciiText[3]
	var cellIndex3 = CharToCellIndex[char3]
	set_cell(2, 0, cellIndex3)
	
	var char4 = asciiText[4]
	var cellIndex4 = CharToCellIndex[char4]
	set_cell(3, 0, cellIndex4)
