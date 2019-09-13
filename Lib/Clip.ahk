GetClipboardFormat(type=1)  ;Thanks nnnik
{
	Critical, On  
	DllCall("OpenClipboard", "int", "")
	while c := DllCall("EnumClipboardFormats","Int",c?c:0)
		x .= "," c
	DllCall("CloseClipboard")
	Critical, OFF    ; 在开始执行段使用该函数，使所有后续线程变为不可中断，脚本会卡死，所以需要关闭
	if type=1
		if Instr(x, ",1") and Instr(x, ",13")
		return 1
		else If Instr(x, ",15")
		return 2
		else
		return ""
		else
		return x
}

; returnnum = 0 不还原剪贴板，返回新剪贴板
; returnnum = 1 还原剪贴板(剪贴板内容不变)，清空 _isFile _ClipAll，返回复制的内容
; returnnum = 2/3/4.. 还原剪贴板，赋值 _isFile _ClipAll，返回复制的内容
GetSelText(returnnum:=1, ByRef _isFile:="", ByRef _ClipAll:="",waittime:=2)
{
	global monitor
	monitor := (returnnum = 0) ? 1 : 0
	Saved_ClipBoard := ClipboardAll    ; 备份剪贴板
	Clipboard=    ; 清空剪贴板
	Send, ^c
	sleep 200
	ClipWait, % waittime
	If(ErrorLevel) ; 如果粘贴板里面没有内容，则还原剪贴板
	{
		Clipboard:=Saved_ClipBoard
		sleep 100
		monitor := 1
	Return
	}
	If(returnnum=0)
	Return Clipboard
	else If(returnnum=1)
		_isFile := _ClipAll := ""
	else
	{
		_isFile:=DllCall("IsClipboardFormatAvailable","UInt",15) ; 是否是文件类型
		_ClipAll := ClipboardAll
	}
	ClipSel := Clipboard

	Clipboard := Saved_ClipBoard  ; 还原粘贴板
	sleep 200
	monitor := 1
	return ClipSel
}

;Read real text (=not filenames, when CF_HDROP is in clipboard) from clipboard
ReadClipboardText()
{
	; CF_TEXT = 1 ;CF_UNICODETEXT = 13
	If((!A_IsUnicode && DllCall("IsClipboardFormatAvailable", "Uint", 1)) || (A_IsUnicode && DllCall("IsClipboardFormatAvailable", "Uint", 13)))
	{
		DllCall("OpenClipboard", "Ptr", 0)	
		htext:=DllCall("GetClipboardData", "Uint", A_IsUnicode ? 13 : 1, "Ptr")
		ptext := DllCall("GlobalLock", "Ptr", htext)
		text := StrGet(pText, A_IsUnicode ? "UTF-16" : "cp0")
		DllCall("GlobalUnlock", "Ptr", htext)
		DllCall("CloseClipboard")
	}
	Return text
}

GetClipboardFormatName(nFormat)
{
    VarSetCapacity(sFormat, 255)
    DllCall("GetClipboardFormatName", "Uint", nFormat, "str", sFormat, "Uint", 256)
    Return  sFormat
}