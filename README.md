# AutoHotKey

## Current Directory Tree:

Folder: **IDE** (for scripts I use in tandem while making scripts)

	- Detect Arrays
	- Detect Variables
	- SciTe-Companion

Folder: **Img** (image related searchs)

	- AHK Image + Variation Search Tool
	- Pixel Hunt

Folder: **Misc**

	- AutoIndent (To help autoIndent other people's script.)
	- IniRead() (another ini to object reader)
	- Typing in Accents (an attempt to emulate Mac). Idk, i'm not a mac person. 
	- Global functions (functions that I use almost universally in most of my scripts). 
	
-----------
### Detect variables/arrays 
The two files are to help debugging. 

* Detect basic assigned-variables
* Detect basic assigned-arrays

Both are located in the `IDE` folder, and requires the function `SendClip()` and `removeDuplicates()` from the `"Global Functions"` script, located in the `Misc` folder. 

"Detect basic assigned-variables" is triggered when the user types in `/var`. After that, it highlights and copies from where the caret is to the beginning (Ctrl+Shift+Home) + (Ctrl+C). After that, it parses and looks for all `:=` assignments and attempts to find all non-object assignments. After it finds them, it'll autocreate a nice little messagebox right where the user typed in `/var`. The message box should be in the format of

    MsgBox % "Variables:`n"
     . "- filetype : " filetype "`n"
     . "- files : " files "`n"
     . "- clipBak : " clipBak "`n"
    
"Detect basic assigned-arrays" work on the same principle. Type in `/array` and it'll {Ctrl}+{Shift}+{Home} {Ctrl}+{C}. Then it'll parse through some regex and *hopefully* find the common assignments for arrays. It'll give an output of messagebox code again, like above: 

    ;~ Arrays:
    strhash := "" 
    For k, v in hash
	    strhash .= k ":	"	v

    MsgBox % "Array: hash`n"
	    .	"`n " strhash

    strnewArr := "" 
    For k, v in newArr
	    strnewArr .= k ":	"	v

    MsgBox % "Array: newArr`n"
	    .	"`n " strnewArr

### The documentation for iniRead() should be in the code itself. 

### SciTe-Companion
It does a URL-download-to-file each time the user types in a command (while using SciTe4AutoHotKey). It then makes 2 attempts at max to pull up the corresponding webpage, takes out the html codes, and display a text-base version of the ahk-documentation pages. 

### AHK Image + Variation 
Open the script, a GUI interface should pop up. Select the image file you want to search, make sure the image is on screen, and press search. The GUI will minimize, and attempts to find the picture, showing user the variations it's going through. Once found, the accompanying code is copied to clipboard. 

### Pixel Hunt
An attempt to make a GUI-interface to do a pixel-search. 

* Step 1: Click the 1) button. Get color by rightclicking. 
* Step 2: Click the 2) button. Arrange your search area by rightclick+drag. 
* step 3: Select your options (move mouse/click/show). 
* Step 4: Choose your frequency. Once per second, once per millisecond (aka as soon as possible), etc 
* step 5: press start. 

### AutoIndent
An attempt to help codify/prettify a script. Select someone's script, copy it to clipboard, and press F1 when you're ready to paste the copied code. 
