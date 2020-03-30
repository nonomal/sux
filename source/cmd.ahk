﻿; ; Note: Save with encoding UTF-8 with BOM if possible.
; ; Notepad will save UTF-8 files with BOM automatically (even though it does not say so).
; ; Some editors however save without BOM, and then special characters look messed up in the AHK GUI.


trim_p := Trim(Pedersen)


if !trim_p
{
	WebSearch(Clipboard, "default")
}
else if SubStr(Pedersen, 1, 1) = A_Space
; else if SubStr(Pedersen, 0, 1) = A_Space
{
	WebSearch(Pedersen, "default")
}
else if SubStr(Pedersen, 0, 1) = A_Space
{
	;;; everything search(end with space) & default web search;;;
	gui_destroy()
	EverythingShortCut()
	WinWaitActive, ahk_exe Everything.exe, , 0.666
	if ErrorLevel{
		; MsgBox,,, please install Everything and set its shortcut in user_conf.ahk
		WebSearch(Pedersen, "default")
	}
	else{
		last_search_str := Pedersen
		; Sleep, 88
		; SendRaw, %trim_p%
		Sleep, 222
		; SendRaw, %last_search_str%
		Send, {Blind}{Text}%trim_p%
	}
}
else
{
	if trim_p = help ; Tooltip with list of commands
	{
		GuiControl,, trim_p, ; Clear the input box
		Gosub, gui_commandlibrary
	}
	else if trim_p = ev ; nox official site
	{
		;;; everything search(end with space) & default web search;;;
		gui_destroy()
		EverythingShortCut()
		WinWaitActive, ahk_exe Everything.exe, , 2.222
		if ErrorLevel
			MsgBox,,, please install Everything and set its shortcut in user_conf.ahk
	}
	else if trim_p = os ; nox official site
	{
		gui_destroy()
		run "https://github.com/no5ix/nox"
	}
	; else if trim_p = url ; Open an URL from the clipboard (naive - will try to run whatever is in the clipboard)
	; {
	; 	; msg_str := "This is your clipboard url content : `n`n" . ClipBoard . " `n`n Would you like to open it ?"
	; 	; MsgBox, 4,, %msg_str%
	; 	; IfMsgBox Yes
	; 	; {
	; 	; 	gui_destroy()
	; 	; 	run %ClipBoard%
	; 	; }
		
	; 	gui_search_title := "URL"
	; 	gui_search("http://REPLACEME", 1)
	; }
	else if trim_p = cmd ; open a command prompt window on the current explorer path 
	{
		gui_destroy()
		IfWinActive, ahk_exe explorer.exe
		{
			Send, !d
			SendInput, cmd`n  ; 等同于下面这两句
			; SendRaw, cmd
			; Send, {Enter}
		}
		else
		{
			run cmd.exe
		}
	}
	;-------------------------------------------------------------------------------
	;;; INTERACT WITH THIS AHK SCRIPT ;;;
	;-------------------------------------------------------------------------------
	else if trim_p = proj ; open this proj with vs code
	{
		gui_destroy()
		; run, %comspec% /c Code "%A_ScriptDir%,,hide
		; run, cmd /c Code "%A_ScriptDir%,,hide
		script_dir = %A_ScriptDir%
		if vscode_path {
			Run_AsUser(vscode_path, script_dir)  ;; call Microsoft VS Code\Code.exe
		}else {
			Run_AsUser("code", script_dir)  ;; call Microsoft VS Code\bin\code , has a ugly cmd window
		}
		MaximizeWindow(1111, "Code.exe")
	}
	else if trim_p = rd ; Reload this script
	{
		gui_destroy() ; removes the GUI even when the reload fails
		Reload
	}
	else if trim_p = dir ; Open the directory for this script
	{
		gui_destroy()
		Run, %A_ScriptDir%
	}
	; else if trim_p = conf ; Edit user_conf
	; {
	; 	gui_destroy()
	; 	; run, notepad.exe "%A_ScriptDir%\user_conf.ahk"
	; 	param = %A_ScriptDir%\conf\user_conf.ahk
	; 	Run_AsUser("notepad.exe", param)
	; }
	; else if trim_p = up ; update nox
	; {
	;     MsgBox, 4,, Would you like to update nox?
	;     IfMsgBox Yes
	;     {
	;     	gui_destroy()
	;         Gosub gui_spawn
	;         UpdateNox()
	;     }
	; }
	else if trim_p = game ; turn on/off game mode
	{
		msg_str := "Would you like to turn " . (game_mode ? "off" : "on") . " game mode?"
		MsgBox, 4,, %msg_str%
		IfMsgBox Yes
		{
			gui_destroy()
			game_mode := game_mode ? 0 : 1
			limit_mode := game_mode
			if game_mode {
				if enable_hot_corners
					SetTimer, LimitModeWhenFullScreen, Off
				MsgBox, Double Shift is disabled in game mode`, you can CapsLock+X to open nox input box.
			} else {
				if enable_hot_corners
					SetTimer, LimitModeWhenFullScreen, 88
			}
		}
	}
	else if trim_p = wau ; turn on/off disable win10 auto update
	{
		msg_str := "Would you like to turn " . (disable_win10_auto_update ? "off" : "on") . " disable win10 auto update?"
		MsgBox, 4,, %msg_str%
		IfMsgBox Yes
		{
			gui_destroy()
			disable_win10_auto_update := disable_win10_auto_update ? 0 : 1
		}
	}
	;-------------------------------------------------------------------------------
	;;; web search ;;;
	;-------------------------------------------------------------------------------
	; else if WebSearchUrlMap.HasKey(trim_p)
	; {
	; 	; for key, arr in WebSearchUrlMap ; Enumeration is the recommended approach in most cases.
	; 	; {
	; 	; 	; Using "Loop", indices must be consecutive numbers from 1 to the number
	; 	; 	; of elements in the array (or they must be calculated within the loop).
	; 	; 	; MsgBox % "Element number " . A_Index . " is " . Array[A_Index]
	; 	; 	; Using "for", both the index (or "key") and its associated value
	; 	; 	; are provided, and the index can be *any* value of your choosing.
	; 	; 	if trim_p = %key%
	; 	; 	{
	; 	; 		gui_search_title := arr[1]
	; 	; 		gui_search(arr[2])
	; 	; 		Break
	; 	; 	}
	; 	; }

	; 	gui_search_title := WebSearchUrlMap[trim_p][1]
	; 	gui_search(WebSearchUrlMap[trim_p][2])
	; }
	else
	{
		word_array := StrSplit(trim_p, A_Space, ,2)
		if WebSearchUrlMap.HasKey(word_array[1]){
			if !word_array[2]
				WebSearch(Clipboard, word_array[1])
			else
				WebSearch(word_array[2], word_array[1])
		}
		else
			WebSearch(Pedersen, "default")
	}
}
