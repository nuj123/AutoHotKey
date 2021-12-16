#SingleInstance, Force
SetWorkingDir, % A_ScritDir

; download the list from your site. 
url := "https://raw.githubusercontent.com/Gewerd-Strauss/Create-GHS-Phrases/main/INI-Files/CreateGHSPhrases.ini"

TEXT_NAME := "test.txt"

UrlDownloadToFile, % url, % TEXT_NAME

f := FileOpen(TEXT_NAME, "R")
TEXT_FILE := f.read()
f.close()

CODE := {}

FileDelete, % TEXT_NAME

; parse text to store into array CODE
for line, text in StrSplit(text_file, "`n", "`r")
{
	; ignores section with the "+"
	if InStr(text, "+")
		continue 

	; ignores section heading that starts with "[" and ends with "]"
	if (text ~= "^\[.*?\]$")
		continue 

	; splits left/right side of the `=` sign 
	TEMP := strSplit(text, "=")

	; get last three characters. 
	CHAR_LAST_THREE := SubStr(Temp.2, -2, 3)

	; if last three is  "..."
	if (CHAR_LAST_THREE = "...")
	{
		; removes the "..."
		CODE[TEMP.1] := SubStr(TEMP.2, 1, -3)
	}
	else 
	{
		CODE[TEMP.1] := TEMP.2
	}
}

dashes := "-----------------`n"
vERROR_HEADER := "ERROR LOG (REMOVE AFTERWARDS)`n" . dashes 

return 

F1::
	clipboard := "" 
	send, ^c 
	Clipwait, 2 

	Sleep, -1 
	Sleep, 50

	;~ =====================================
	;~ vars 
	;~ =====================================
		var := Clipboard 

		; the string to write to clipboard 
		string := ""

		; the initial letter of our CHEM Code 
		vLETTER := "" 

		; our Array for error logging 
		oERROR_LOG := []
		
		; current count of how many errors that were detected. 
		vERROR_COUNT := 0

	;~ =====================================
	;~ line parsing  
	;~ =====================================

	for vLINE, vInput in StrSplit(var, "`n", "`r")
	{
		temp_string := trim(vINput) ": "

		;~ =====================================
		;~ Individual code parsing  
		;~ =====================================

		; splits it up by the "+"
		for k, var_INPUT in strsplit(trim(vInput), "+")
		{
				;~ =====================================
				;~ Extract ALPHA + NUMBER of the CODE 
				;~ Based on the very first code in the line
				;~ =====================================

				; stores the first set of alpha retrieved in the first number 
				If (A_Index = 1)
				{
					RegExMatch(var_INPUT, "[a-zA-Z]+", vLETTER)
					; ever number in this line is going to be assumed to be using this letter too. 
				}

				; stores the number 
				RegExMatch(var_INPUT, "\d+", vNUMBER)

			; check our database if we have the code via .haskey() 
			if (CODE.hasKey(vLetter . vNumber))
			{
				; if we have the code, append it 
				temp_string .= CODE[vLetter . vNumber]
			}
			
			Else 	; if we don't have the code  
			{
				temp_string .= "[" vLetter . vNumber "]"

			; Push any detected error into the error array.

				; INPUT = exact code in line 
				; Interperted = Assumed letter + number code. 
				oERROR_LOG.push({"Input":vINPUT, "Interpreted":vLetter . vNumber, "Line":vLINE})
			}

			; if we're not at the end of our "+" parsing, add a space. 
			if !(A_Index = strsplit(vInput, "+").count())
				temp_string .= " " 
		}

		; if errors exists, add a tab before the line 
		if (oERROR_LOG.count() > vERROR_COUNT)
		{
			string .= A_Tab . temp_string "`n"
			vERROR_COUNT := oERROR_LOG.count()
		}
		else 
			string .= temp_string "`n"
	}
	
	;~ =====================================
	;~ Error Logging 
	;~ =====================================

	; do error log 
	if (oError_LOG.COUNT() > 0)
	{
		; building Error Log: 
		string .= "`n`n`n"
		string .= vERROR_HEADER
		for index, line in oError_log
		{
			string .= "Error " index ": Key '" line.interpreted "' could not be found on file. Please search line " line.line " and insert manually. Specific phrase missing: " line.input "`n" 
		}

		string .= dashes
	}

	MsgBox, % string 
	; print(string)
	return 

*Esc::ExitApp 
F8::Reload 
