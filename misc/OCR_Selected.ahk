/*
   This script uses two libraries: 
   
   1) Explorer_GetSelected() to retrieve the path of the file you selected in your folder/explorer. Taken from:

   https://autohotkey.com/board/topic/60985-get-paths-of-selected-items-in-an-explorer-window/

   2) OCR() with UWP API, taken from:
   
   https://www.autohotkey.com/boards/viewtopic.php?t=72674

*/
#SingleInstance, Force 

; Turn ON Text-To-Speech?  
; 1 = Yes, 0 = No 
Text_To_Speech := 1

; ---------------------
; ---- GUI options ----
; ---------------------

; GUI_COLOR := 0x000000
GUI_COLOR := 0x282923
GUI_TEXT_BOX_COLOR :=  0x282923

GUI_FONT_SIZE := 15
GUI_FONT_COLOR := 0xDCDB74 

; width and height of the GUI edit box. 
; A width and height is needed. 
w := 500
h := 500

; X and Y location where you want the GUI to pop out from. To set as default (center of screen), just put in two quotes (""). 
; x := ""
; y := "" 

x := "" 
y := "" 

; ---------------------
; -- END OF OPTIONS ---
; ---------------------

if !(x = "")
   x := "x" x

if !(y = "") 
   y := "y" y 

Gui, Color, % GUI_COLOR, % GUI_TEXT_BOX_COLOR
Gui, Font, % "s" GUI_FONT_SIZE " c" GUI_FONT_COLOR
Gui, Add, Edit, vTheOCR w%w% h%h% vScroll, 
return 

!#r:: 
    filePath := Explorer_getSelected()

    ; if no file selected 
    if !FilePath 
    {
        MsgBOx, Sorry. Either no files were selected or AHK was unable to retrieve the path 

        return
    }
    txt := ocr(filepath)
    Gui, Show, %x% %y%
    GuiControl, Text, TheOCR, % txt 

    sleep, 100
    if (Text_to_Speech)
      speak(txt)
return 

; press Control + ESC to close script
^esc::ExitApp

GuiClose:
   Gui, Hide 
   speak()
return 

speak(text := "")
{
    static voice := ComObjCreate("SAPI.SpVoice")
    if (text = "")
      ; turns off text 
      voice.Speak("",0x1|0x2)
    else 
      ; reads text, async. 
      voice.Speak(text,0x1)
}

; ============================================================
; Get the path of a selected item in explorer 
; taken from: 
; 
; https://autohotkey.com/board/topic/60985-get-paths-of-selected-items-in-an-explorer-window/
; ============================================================
/*
   Library for getting info from a specific explorer window (if window handle not specified, the currently active
   window will be used).  Requires AHK_L or similar.  Works with the desktop.  Does not currently work with save
   dialogs and such.
   
   
   Explorer_GetSelected(hwnd="")   - paths of target window's selected items
   Explorer_GetAll(hwnd="")        - paths of all items in the target window's folder
   Explorer_GetPath(hwnd="")       - path of target window's folder
   
   example:
      F1::
         path := Explorer_GetPath()
         all := Explorer_GetAll()
         sel := Explorer_GetSelected()
         MsgBox % path
         MsgBox % all
         MsgBox % sel
      return
   
   Joshua A. Kinnison
   2011-04-27, 16:12
*/

Explorer_GetPath(hwnd="")
{
   if !(window := Explorer_GetWindow(hwnd))
      return ErrorLevel := "ERROR"
   if (window="desktop")
      return A_Desktop
   path := window.LocationURL
   path := RegExReplace(path, "ftp://.*@","ftp://")
   StringReplace, path, path, file:///
   StringReplace, path, path, /, \, All 
   
   ; thanks to polyethene
   Loop
      If RegExMatch(path, "i)(?<=%)[\da-f]{1,2}", hex)
         StringReplace, path, path, `%%hex%, % Chr("0x" . hex), All
      Else Break
   return path
}
Explorer_GetAll(hwnd="")
{
   return Explorer_Get(hwnd)
}
Explorer_GetSelected(hwnd="")
{
   return Explorer_Get(hwnd,true)
}

Explorer_GetWindow(hwnd="")
{
   ; thanks to jethrow for some pointers here
    WinGet, process, processName, % "ahk_id" hwnd := hwnd? hwnd:WinExist("A")
    WinGetClass class, ahk_id %hwnd%
   
   if (process!="explorer.exe")
      return
   if (class ~= "(Cabinet|Explore)WClass")
   {
      for window in ComObjCreate("Shell.Application").Windows
         if (window.hwnd==hwnd)
            return window
   }
   else if (class ~= "Progman|WorkerW") 
      return "desktop" ; desktop found
}
Explorer_Get(hwnd="",selection=false)
{
   if !(window := Explorer_GetWindow(hwnd))
      return ErrorLevel := "ERROR"
   if (window="desktop")
   {
      ControlGet, hwWindow, HWND,, SysListView321, ahk_class Progman
      if !hwWindow ; #D mode
         ControlGet, hwWindow, HWND,, SysListView321, A
      ControlGet, files, List, % ( selection ? "Selected":"") "Col1",,ahk_id %hwWindow%
      base := SubStr(A_Desktop,0,1)=="\" ? SubStr(A_Desktop,1,-1) : A_Desktop
      Loop, Parse, files, `n, `r
      {
         path := base "\" A_LoopField
         IfExist %path% ; ignore special icons like Computer (at least for now)
            ret .= path "`n"
      }
   }
   else
   {
      if selection
         collection := window.document.SelectedItems
      else
         collection := window.document.Folder.Items
      for item in collection
         ret .= item.path "`n"
   }
   return Trim(ret,"`n")
}

; ============================================================
; OCR with UWP API 
; taken from: 
; https://www.autohotkey.com/boards/viewtopic.php?t=72674
; ============================================================

ocr(file, lang := "FirstFromAvailableLanguages")
{
   static OcrEngineStatics, OcrEngine, MaxDimension, LanguageFactory, Language, CurrentLanguage, BitmapDecoderStatics, GlobalizationPreferencesStatics
   if (OcrEngineStatics = "")
   {
      CreateClass("Windows.Globalization.Language", ILanguageFactory := "{9B0252AC-0C27-44F8-B792-9793FB66C63E}", LanguageFactory)
      CreateClass("Windows.Graphics.Imaging.BitmapDecoder", IBitmapDecoderStatics := "{438CCB26-BCEF-4E95-BAD6-23A822E58D01}", BitmapDecoderStatics)
      CreateClass("Windows.Media.Ocr.OcrEngine", IOcrEngineStatics := "{5BFFA85A-3384-3540-9940-699120D428A8}", OcrEngineStatics)
      DllCall(NumGet(NumGet(OcrEngineStatics+0)+6*A_PtrSize), "ptr", OcrEngineStatics, "uint*", MaxDimension)   ; MaxImageDimension
   }
   if (file = "ShowAvailableLanguages")
   {
      if (GlobalizationPreferencesStatics = "")
         CreateClass("Windows.System.UserProfile.GlobalizationPreferences", IGlobalizationPreferencesStatics := "{01BF4326-ED37-4E96-B0E9-C1340D1EA158}", GlobalizationPreferencesStatics)
      DllCall(NumGet(NumGet(GlobalizationPreferencesStatics+0)+9*A_PtrSize), "ptr", GlobalizationPreferencesStatics, "ptr*", LanguageList)   ; get_Languages
      DllCall(NumGet(NumGet(LanguageList+0)+7*A_PtrSize), "ptr", LanguageList, "int*", count)   ; count
      loop % count
      {
         DllCall(NumGet(NumGet(LanguageList+0)+6*A_PtrSize), "ptr", LanguageList, "int", A_Index-1, "ptr*", hString)   ; get_Item
         DllCall(NumGet(NumGet(LanguageFactory+0)+6*A_PtrSize), "ptr", LanguageFactory, "ptr", hString, "ptr*", LanguageTest)   ; CreateLanguage
         DllCall(NumGet(NumGet(OcrEngineStatics+0)+8*A_PtrSize), "ptr", OcrEngineStatics, "ptr", LanguageTest, "int*", bool)   ; IsLanguageSupported
         if (bool = 1)
         {
            DllCall(NumGet(NumGet(LanguageTest+0)+6*A_PtrSize), "ptr", LanguageTest, "ptr*", hText)
            buffer := DllCall("Combase.dll\WindowsGetStringRawBuffer", "ptr", hText, "uint*", length, "ptr")
            text .= StrGet(buffer, "UTF-16") "`n"
         }
         ObjRelease(LanguageTest)
      }
      ObjRelease(LanguageList)
      return text
   }
   if (lang != CurrentLanguage) or (lang = "FirstFromAvailableLanguages")
   {
      if (OcrEngine != "")
      {
         ObjRelease(OcrEngine)
         if (CurrentLanguage != "FirstFromAvailableLanguages")
            ObjRelease(Language)
      }
      if (lang = "FirstFromAvailableLanguages")
         DllCall(NumGet(NumGet(OcrEngineStatics+0)+10*A_PtrSize), "ptr", OcrEngineStatics, "ptr*", OcrEngine)   ; TryCreateFromUserProfileLanguages
      else
      {
         CreateHString(lang, hString)
         DllCall(NumGet(NumGet(LanguageFactory+0)+6*A_PtrSize), "ptr", LanguageFactory, "ptr", hString, "ptr*", Language)   ; CreateLanguage
         DeleteHString(hString)
         DllCall(NumGet(NumGet(OcrEngineStatics+0)+9*A_PtrSize), "ptr", OcrEngineStatics, ptr, Language, "ptr*", OcrEngine)   ; TryCreateFromLanguage
      }
      if (OcrEngine = 0)
      {
         msgbox Can not use language "%lang%" for OCR, please install language pack.
         return 
      }
      CurrentLanguage := lang
   }
   if (SubStr(file, 2, 1) != ":")
      file := A_ScriptDir "\" file
   if !FileExist(file) or InStr(FileExist(file), "D")
   {
      msgbox File "%file%" does not exist
      return
   }
   VarSetCapacity(GUID, 16)
   DllCall("ole32\CLSIDFromString", "wstr", IID_RandomAccessStream := "{905A0FE1-BC53-11DF-8C49-001E4FC686DA}", "ptr", &GUID)
   DllCall("ShCore\CreateRandomAccessStreamOnFile", "wstr", file, "uint", Read := 0, "ptr", &GUID, "ptr*", IRandomAccessStream)
   DllCall(NumGet(NumGet(BitmapDecoderStatics+0)+14*A_PtrSize), "ptr", BitmapDecoderStatics, "ptr", IRandomAccessStream, "ptr*", BitmapDecoder)   ; CreateAsync
   WaitForAsync(BitmapDecoder)
   BitmapFrame := ComObjQuery(BitmapDecoder, IBitmapFrame := "{72A49A1C-8081-438D-91BC-94ECFC8185C6}")
   DllCall(NumGet(NumGet(BitmapFrame+0)+12*A_PtrSize), "ptr", BitmapFrame, "uint*", width)   ; get_PixelWidth
   DllCall(NumGet(NumGet(BitmapFrame+0)+13*A_PtrSize), "ptr", BitmapFrame, "uint*", height)   ; get_PixelHeight
   if (width > MaxDimension) or (height > MaxDimension)
   {
      msgbox Image is to big - %width%x%height%.`nIt should be maximum - %MaxDimension% pixels
      return
   }
   BitmapFrameWithSoftwareBitmap := ComObjQuery(BitmapDecoder, IBitmapFrameWithSoftwareBitmap := "{FE287C9A-420C-4963-87AD-691436E08383}")
   DllCall(NumGet(NumGet(BitmapFrameWithSoftwareBitmap+0)+6*A_PtrSize), "ptr", BitmapFrameWithSoftwareBitmap, "ptr*", SoftwareBitmap)   ; GetSoftwareBitmapAsync
   WaitForAsync(SoftwareBitmap)
   DllCall(NumGet(NumGet(OcrEngine+0)+6*A_PtrSize), "ptr", OcrEngine, ptr, SoftwareBitmap, "ptr*", OcrResult)   ; RecognizeAsync
   WaitForAsync(OcrResult)
   DllCall(NumGet(NumGet(OcrResult+0)+6*A_PtrSize), "ptr", OcrResult, "ptr*", LinesList)   ; get_Lines
   DllCall(NumGet(NumGet(LinesList+0)+7*A_PtrSize), "ptr", LinesList, "int*", count)   ; count
   loop % count
   {
      DllCall(NumGet(NumGet(LinesList+0)+6*A_PtrSize), "ptr", LinesList, "int", A_Index-1, "ptr*", OcrLine)
      DllCall(NumGet(NumGet(OcrLine+0)+7*A_PtrSize), "ptr", OcrLine, "ptr*", hText) 
      buffer := DllCall("Combase.dll\WindowsGetStringRawBuffer", "ptr", hText, "uint*", length, "ptr")
      text .= StrGet(buffer, "UTF-16") "`n"
      ObjRelease(OcrLine)
   }
   Close := ComObjQuery(IRandomAccessStream, IClosable := "{30D5A829-7FA4-4026-83BB-D75BAE4EA99E}")
   DllCall(NumGet(NumGet(Close+0)+6*A_PtrSize), "ptr", Close)   ; Close
   ObjRelease(Close)
   Close := ComObjQuery(SoftwareBitmap, IClosable := "{30D5A829-7FA4-4026-83BB-D75BAE4EA99E}")
   DllCall(NumGet(NumGet(Close+0)+6*A_PtrSize), "ptr", Close)   ; Close
   ObjRelease(Close)
   ObjRelease(IRandomAccessStream)
   ObjRelease(BitmapDecoder)
   ObjRelease(BitmapFrame)
   ObjRelease(BitmapFrameWithSoftwareBitmap)
   ObjRelease(SoftwareBitmap)
   ObjRelease(OcrResult)
   ObjRelease(LinesList)
   return text
}



CreateClass(string, interface, ByRef Class)
{
   CreateHString(string, hString)
   VarSetCapacity(GUID, 16)
   DllCall("ole32\CLSIDFromString", "wstr", interface, "ptr", &GUID)
   result := DllCall("Combase.dll\RoGetActivationFactory", "ptr", hString, "ptr", &GUID, "ptr*", Class)
   if (result != 0)
   {
      if (result = 0x80004002)
         msgbox No such interface supported
      else if (result = 0x80040154)
         msgbox Class not registered
      else
         msgbox error: %result%
      return
   }
   DeleteHString(hString)
}

CreateHString(string, ByRef hString)
{
    DllCall("Combase.dll\WindowsCreateString", "wstr", string, "uint", StrLen(string), "ptr*", hString)
}

DeleteHString(hString)
{
   DllCall("Combase.dll\WindowsDeleteString", "ptr", hString)
}

WaitForAsync(ByRef Object)
{
   AsyncInfo := ComObjQuery(Object, IAsyncInfo := "{00000036-0000-0000-C000-000000000046}")
   loop
   {
      DllCall(NumGet(NumGet(AsyncInfo+0)+7*A_PtrSize), "ptr", AsyncInfo, "uint*", status)   ; IAsyncInfo.Status
      if (status != 0)
      {
         if (status != 1)
         {
            DllCall(NumGet(NumGet(AsyncInfo+0)+8*A_PtrSize), "ptr", AsyncInfo, "uint*", ErrorCode)   ; IAsyncInfo.ErrorCode
            msgbox AsyncInfo status error: %ErrorCode%
            return
         }
         ObjRelease(AsyncInfo)
         break
      }
      sleep 10
   }
   DllCall(NumGet(NumGet(Object+0)+8*A_PtrSize), "ptr", Object, "ptr*", ObjectResult)   ; GetResults
   ObjRelease(Object)
   Object := ObjectResult
}
