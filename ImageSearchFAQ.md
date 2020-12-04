## Some ImageSearch FAQ
The format for the `imagesearch` command goes as follow:
```
ImageSearch, OutputVarX, OutputVarY, X1, Y1, X2, Y2, [IconN] [*Variation] [TransN] [wn] [hn] ImageFile
```
Note: X1, Y1, X2, Y2 are relative to current active window, unless you set it to search using screen coordinates. 
```
; set pixel to screen mode 
CoordMode, Pixel, Screen

Imagesearch...
```
If you're going to do some clicking based on the coordinates found in OutPutVarX and OutPutVarY, you may have to set your mouse coordmode to screen also
```
CoordMode, Mouse, Screen
```

Every one of the `[]` options are optional. You can read more about their usage in the documentation: 
https://www.autohotkey.com/docs/commands/ImageSearch.htm

1. If the image is found, the upper-left coordinate of where the image was found is stored in the variables that you specified for `outPutX` and `outPutY`. 

2. How do I know if the image was found?
> AHK throws an `ErrorLevel` upon executing the `imagesearch` script. For you to check to see if the image was found, you'll have to check what the value of the `ErrorLevel` is. For imagesearch, the possible values for the `ErrorLevel` is `0`, `1`, and `2`. 
 
3. What does it mean if the ErrorLevel is 0, 1, or 2? 
	With Imagesearch, if the ErrorLevel is...
> 0: The image was found. 
>
> 1: The image could not be found in the specified region. 
>
> 2: Some other error occurred that prevented imagesearch from running properly. 
>
> In other words, your code would look something like this: 
```
ImageSearch...
If (ErrorLevel = 0)	; if your image was found: 
{
	; do this
}
else if (ErrorLevel = 1) ; If your image wasn't found
{
	; do that
}
else if (ErrorLevel = 2) 
{
	MsgBox An error occurred. 
}
```
4. I ran everything correctly. My region coordinates are correct, my filepath is correct. I directly took a screenshot of the image and used that image, but `imagesearch` isn't finding it at all! What's going on? 
> Likely, when you saved your image, your image was slightly compressed or something, resulting in a "not exact pixel-for-pixel" match. You may have to add in a variation to your imagesearch, using `*Number ImageFile`, where `Number` is a number ranging from `0` to `255`. `0 = exact pixel-for-pixel match`, and `255 = match anything`. Go ahead and put a variation of, say, `100` in your imagesearch and see if it could be found. The format would look like this: 
```
ImageSearch, OutX, OutY, X1, Y1, X2, Y2, *100 ImageFile
```
> If you want to find out the *exact* variation, you can use some sort of variation of this following code to search for it (note, the only option tested here is *variation*).
```
; https://github.com/nuj123/AutoHotKey/blob/master/Img/AHK%20Image%20%2B%20Variation%20Search%20Tool

ImgFile := "C:\Path\To\Image\Here\Picture.png"

While (A_Index < 256)
{
	; imagesearch through one variation at a time. From 0 to 255. 
	Imagesearch, outX, outY, 0, 0, A_ScreenWidth, A_ScreenHeight, *%A_Index% %ImgFile%
	If (errorLevel = 0)
	{
		if (A_Index = 255)
		{
			MsgBox Image could not be found on the screen. 
			return
		}

		VarString := "Image located at (" . OutX . ", " . OutY . ") with variation of (" . A_Index . ")"
		ToolTip, % VarString
		break
	}
	else If (ErrorLevel = 1)
		ToolTip, Current Variation = %A_Index%
	Else if (ErrorLevel = 2)
		MsgBox, An error prevented imagesearch from running properly. 
}
return
```

5. I have multiple images I'm searching for, and only want to run my scripts according to what image was found. How do I do that? 
> You can use what I call the 'shotgun' approach. Just throw them all together, and if one of them is found, it'll execute that script. 
```
Imagesearch.... image1.png
If (ErrorLevel = 0) {
	; do things here
}

ImageSearch... Image2.png
If (ErrorLevel = 0) {
	; do things here
}

ImageSearch... Image3.png
If (ErrorLevel = 0) {
	; do things here
}

; etc 
```

6. I want to look for my image continuously. What can I do? 
> You can use a `Loop` to run your imagesearch continuously. 
```
Loop {
	Imagesearch...
	If (ErrorLevel = 0) {
		; do things here
		break	; <-- only if you want to stop the loop after the image is found 
	}
}
```
> ALternatively, you can use `SetTimer` to loop things. 
```
SetTimer, FindPicture, 100	; runs the code under the label "FindPicture" every "100 milliseconds". 
return 

FindPicture:
	ImageSearch... 
	If (ErrorLevel = 0) {
	; do things here
	SetTimer, FindPicture, Off	; <--- only if you want to stop the loop after the image is found
	}
return 
