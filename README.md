# AutoHotKey
The two files are to help debug. 

* Detect basic assigned-variables
* Detect basic assigned-arrays

Both requires the function `SendClip()` and `removeDuplicates()` from the "Random Functions" script. 

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

The documentation for iniRead() should be in the code itself. 
