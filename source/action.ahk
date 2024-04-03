﻿#Include %A_ScriptDir%\source\common_const.ahk
#Include %A_ScriptDir%\source\util.ahk
#Include %A_ScriptDir%\source\js_eval.ahk
#Include %A_ScriptDir%\source\quick_entry.ahk
#Include %A_ScriptDir%\source\snip_plus.ahk
#Include %A_ScriptDir%\source\tray_menu.ahk




ShowSuxMenu() {
	QuickEntry.ShowQuickEntryMenu()
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

StartSuxAhkWithWin() {
	msg_str := "Would you like to start sux with windows? Yes(Enable) or No(Disable)"
	MsgBox, 3,, %msg_str%
	IfMsgBox Cancel
		return

	Name_no_ext := "sux"
	Name := "sux.ahk"
	Dir = %A_ScriptDir%
	sux_ahk_file_path =  %A_ScriptFullPath%

	IfExist, %A_Startup%\%Name_no_ext%.lnk
	{
		IfMsgBox No
		{
			FileDelete, %A_Startup%\%Name_no_ext%.lnk
			MsgBox, %Name% removed from the Startup folder.
		}
		else {
			MsgBox, %Name% already added to Startup folder for auto-launch with Windows.
		}
	}
	Else
	{
		IfMsgBox Yes
		{
			FileCreateShortcut, "%sux_ahk_file_path%"
				, %A_Startup%\%Name_no_ext%.lnk
				, %Dir%   ; Line wrapped using line continuation
			MsgBox, %Name% added to Startup folder for auto-launch with Windows.
		}
	}
}




MoveWindowToLeftSide() {
	send, #{Left}
}

MoveWindowToRightSide() {
	send, #{Right}
}

OpenFileExplorer() {
	run explorer.exe
}

OpenActionCenter() {
	send, #a
}

CloseCurrentWindow() {
	send, !{F4}
}

GoTop() {
	send, ^{Home}
}

GoBottom() {
	send, ^{End}
}

GoBack() {
	send, !{Left}
}

GoForward() {
	send, !{Right}
}

LockPc() {
	send, #l
}

OpenTaskView() {
	send, #{Tab}
}

VolumeMute() {
	Send {volume_mute}
}

VolumeUp() {
	Send {volume_up}
}

VolumeDown() {
	Send {volume_down}
}

GotoNextDesktop() {
	send, ^#{Right}
}

GotoPreDesktop() {
	send, ^#{Left}
}

RefreshTab() {
	send, {F5}
}

ReopenLastTab() {
	SendPlay, ^+t
}

GotoPreApp() {
	send !{Tab}
}

JumpToPrevTab() {
	if (!IsMouseActiveWindowAtSameMonitor()) {
		ActivateWindowsUnderCursor()
	}
	Send {LControl Down}{LShift Down}
	Send, {Tab}
	Sleep, 111
	Send {LControl Up}{LShift Up}
}

JumpToNextTab() {
	if (!IsMouseActiveWindowAtSameMonitor()) {
		ActivateWindowsUnderCursor()
	}
	Send {LControl Down}
	Send, {Tab}
	Sleep, 111
	Send {LControl Up}
}

SwitchCapsState() {
	; SetCapsLockState % !GetKeyState("CapsLock", "T")  ; Toggles CapsLock to its opposite state.
    GetKeyState, CapsLockState, CapsLock, T                              ;|
    if CapsLockState = D                                                 ;|
        SetCapsLockState, AlwaysOff                                      ;|
    else
    {
        SetCapsLockState, AlwaysOn
    }
}


SwitchInputMethodAndDeleteLeft() {
	global MULTI_HIT_DECORATOR
	global keyboard_double_click_timeout
	cur_key := StrReplace(A_ThisHotkey, MULTI_HIT_DECORATOR)
	; cur_key := StrReplace(A_ThisHotkey, "~")
	if (A_PriorHotkey <> A_ThisHotkey or A_TimeSincePriorHotkey > keyboard_double_click_timeout)
	; if (A_PriorHotkey != "~Alt" or A_TimeSincePriorHotkey > keyboard_double_click_timeout)
	{
		; Too much time between presses, so this isn't a double-press.
		Send, ^{Space}
		; tt(A_PriorKey)  ; LAlt
		; tt(A_ThisHotkey)  ; ~alt
		; tt(A_PriorHotkey)  ; ~alt
		KeyWait, % cur_key ; Wait for the key to be released.
		; KeyWait, % A_ThisHotkey ; Wait for the key to be released.
		; KeyWait, %A_PriorHotkey%  ; Wait for the key to be released.
		; KeyWait, Alt  ; Wait for the key to be released.
		; tt(A_PriorKey)
		return
	}
	; Send, ^{Space}
	Send, ^+{Left}
	; Sleep, 66
	Send, {Del}
	return
}


MaxMinWindow() {
	; ActivateWindowsUnderCursor()
	; ; OutputVar is made blank if no matching window exists; otherwise, it is set to one of the following numbers:
	; ; -1: The window is minimized (WinRestore can unminimize it).
	; ; 1: The window is maximized (WinRestore can unmaximize it).
	; ; 0: The window is neither minimized nor maximized.
	WinGet,S,MinMax,A
	if S=0
		WinMaximize, A
	else if S=1
		WinMinimize, A
	; else if S=-1
	;     WinRestore, A
}

MaxWindow() {
	; ActivateWindowsUnderCursor()
	; WinGet,S,MinMax,A
	WinMaximize, A
}

MinWindow() {
	; ActivateWindowsUnderCursor()
	; WinGet,S,MinMax,A
	WinMinimize, A
}

ReloadSux() {
	tt("reloading sux ...")
	
	if (WinExist("ahk_class " . "AutoHotkeyGUI")) {
		; m("Warning!! There are some ScreenShotAndSuspend Windows Opening! Do u wanna still Reload?")
		MsgBox, 0x44, % SuxCore.ProgramName, % lang("Warning!! There are some ScreenShotAndSuspend Windows Opening! Do u wanna still Reload?")
		IfMsgBox Yes
		{
			Reload
		}
	} else {
		Reload
	}
}


SelectCurrentWordAndCopy() {
	Send, ^{Left}
	Sleep, 66
	Send, ^+{Right}
	Sleep, 66
	Send, ^c
}

SelectCurrentLineAndCopy() {
	Send, {Home}
	Sleep, 66
	Send, +{End}
	Sleep, 66
	Send, ^c
}

InsertLineBelow() {
	Send, {End}
	Sleep, 66
	Send, {Enter}
	Sleep, 66
	Loop 8
	{
		Send, {WheelLeft}
	}
}

InsertLineAbove() {
	Send, {Home}
	Sleep, 66
	Send, {Enter}
	Sleep, 66
	Send, {Up}
	Sleep, 66
	Loop 8
	{
		Send, {WheelLeft}
	}
}

DeleteCurrentLine() {
	SelectCurrentLineAndCopy()
	Sleep, 66
	Send, {BackSpace}
}

; SmartSelectWithSymbol() {
; 	symbol_map := {"'": "'", """": """", "(": ")", "[": "]", "{": "}", "<": ">"}
; 	max_step := 888
; 	cur_step := 0
; 	left_symbol := ""
; 	break_loop := 0

; 	walk_more_flag := 0

; 	Loop
; 	{
; 		cur_step += 1
; 		if (cur_step > max_step) {
; 			return
; 		}
; 		Send, +^{Left}
; 		; Sleep, 66
; 		st := GetCurSelectedText()

; 		for k, v in symbol_map {
; 			if (Instr(st, k)) {
; 				left_symbol := k
; 				Send, {Left}

; 				Send, +{Right}
; 				cur_step -= 1
; 				if (GetCurSelectedText() != k) {
; 					walk_more_flag := 1
; 					Send, ^{Right}
; 				}
; 				while (cur_step > 0) {
; 					Send, +^{Right}
; 					cur_step -= 1
; 				}
; 				break_loop := 1
; 				break
; 			}
; 		}
; 		if (break_loop)
; 			break
; 	}

; 	right_symbol := symbol_map[left_symbol]
; 	Loop
; 	{
; 		cur_step += 1
; 		if (cur_step > max_step) {
; 			return
; 		}
; 		Send, +^{Right}
; 		; Sleep, 66
; 		st := GetCurSelectedText()
; 		if (Instr(st, right_symbol,,2)) {
; 			if (walk_more_flag)
; 				Send, +^{Left}
; 			break
; 		}
; 	}
; }

IndentCurrentLine() {
	Send, {Home}
	Sleep, 66
	Send, {Tab}
}


SaveSelectedFilePathToClipboard() {
    ClipboardChangeCmdMgr.disable_all_clip_change_func()
    ; Clipboard := ""
    SendInput, ^{insert}
    ClipWait, 0.1
    if(!ErrorLevel) {
		path := Clipboard
		; Clipboard := ""
   		ClipboardChangeCmdMgr.enable_all_clip_change_func()
		Clipboard := path
	}
}

SimulateClickDown() {
	fake_lb_down = 1
	Click Down
	Hotkey, RButton, SUB_TEMP_RBUTTON
	Hotkey, RButton, On
}


MoveCurrentWindowToMouseMonitor() {
	MoveWindowToMouseMonitor()
}

ToggleNetEaseMusicAndSetSound30() {
	SoundSet, 30
	Send, ^+!3
}

SendWait3Min() {
	PasteContent("发了哈, 3分钟左右阿拉丁会有流程喔, 如果我等下忙其他的去了没注意到阿拉丁有流程了, 你也可以阿拉丁找到对应流程点一波的呢, 辛苦啦~")
}

SendReviewApplyMsg() {
	PasteContent("求review一下这个哈")
}

SendAskTeseDataMerge() {
	PasteContent("好的呀, 包括特色服吗? 有server data要 merge 吗?")
}

ReplaceTextCommaComma() {
	send, {Home}
	Sleep, 66
	send, +{End}
	cst := GetCurSelectedText()

	if (!cst) {
		tt(lang("Please Select text and try again") . ".")
		return
	}
	ReplaceText(",," cst)
}

ReplaceTextSlashSlash() {
	send, {Home}
	Sleep, 66
	send, +{End}
	cst := GetCurSelectedText()

	if (!cst) {
		tt(lang("Please Select text and try again") . ".")
		return
	}
	ReplaceText("//" cst)
}

ScreenShot() {
	if (SuxCore.GetSuxCfg("third_screenshot_app", 0) == 2) { ;; trigger pixpin shortcut
		Send, ^!q
	}
	else if (SuxCore.GetSuxCfg("third_screenshot_app", 0) == 1){
		SnipPlus.TryWechatScreenShot()
	}
	else {
		SnipPlus.AreaScreenShot()
	}
}

ScreenShotAndSuspend() {
	if (SuxCore.GetSuxCfg("third_screenshot_app", 0) == 2) { ;; trigger pixpin shortcut
		Send, ^!q
	}
	else if (SuxCore.GetSuxCfg("third_screenshot_app", 0) == 1){
		SnipPlus.AreaScreenShotAndSuspend(0, 1)
	}
	else {
		SnipPlus.AreaScreenShotAndSuspend()
	}
}

SwapWinCtrlShiftAlt() {
	if (InStr(A_ThisHotkey, "#")) {
		cur_key := StrReplace(A_ThisHotkey, "#", "^")
		SendInput, % cur_key
		Send {LWin up}  ;; 不晓得为何, 如果不加这一句就会导致win键没抬起来
	}
	
	TrayMenu.SetSwapWinCtrlShiftAlt()
	TrayMenu.update_tray_menu()
	tt(lang("Swap Win/Ctrl Shift/Alt (beta)") . ", SuxCore.CurrentSwapWinCtrlShiftAltSwitch == " . SuxCore.CurrentSwapWinCtrlShiftAltSwitch)
}

SelectCurrentWord() {
	send, +{Left}
	Sleep, 66
	st := GetCurSelectedText(111)
	first_char := SubStr(st, 1, 1)
	if (!RegExMatch(first_char, "[0-9a-zA-Z]") && !RegExMatch(first_char, "[^\x00-\xff]") && first_char != "_") {
		send, {Right}
	}
	else {
		send, {Right} ; 没有这一句的话, 如果初始光标在当前word的第二个字符后面的时候会有问题
		send, ^{Left}
	}
	sleep, 66
	send, ^+{Right}
}

SwitchWindowAlwaysOnTop() {
	; MouseGetPos, MouseX, MouseY, MouseWin
    WinGet, ExStyle, ExStyle, A
    if (ExStyle & 0x8) { ; 0x8 is WS_EX_TOPMOST. 
        WinSet AlwaysOnTop,Off, A  ;; 不置顶
        WinSet, Transparent, 255, A  ;; 不透明
        WinSet, ExStyle, -0x20, A  ;; 不穿透
        tt(lang("Set the current window to not always on top"))
    } else {
        ; CancelSetWindowOnTop
        WinSet AlwaysOnTop,On, A  ;; 置顶
        WinSet, Transparent, 222, A  ;; 半透明
        WinSet, ExStyle, +0x20, A  ;; 穿透
        tt(lang("Set the current window to always on top"))
    }
}

;; 在 hotkey.capslock_disable_exe_list 里的软件内部会屏蔽单独敲击capslock键,
;; 避免如果capslock配成esc, 然后在微信里直接不小心按到了然后就关闭微信界面了的这种情况
CheckDisableCapslockList() {
	if (SuxCore.GetSuxCfg("hotkey.buildin.capslock", 0) == 0) {
		return 0
	}
	for _index, exe_name in SuxCore.GetSuxCfg("hotkey.capslock_disable_exe_list", []) {
		if (WinActive("ahk_exe" exe_name)) {
			return 1
		}
	}
	return 0
}



CheckEnableMiddleMouseButtonInIdea() {
	return SuxCore.GetSuxCfg("enable_middle_mouse_button_in_idea", 0) && WinActive("ahk_exe idea64.exe")
}


SUB_TEMP_RBUTTON:
	ClickUpIfLbDown()
	MouseClick, Right
	Return


#If SuxCore.CurrentSwapWinCtrlShiftAltSwitch == 1

	LCtrl::LWin
	LWin::LCtrl

	LShift::LAlt
	LAlt::LShift
	return


#If CheckDisableCapslockList()
	; #If WinActive("ahk_exe MyPopo.exe") or WinActive("ahk_exe WeChat.exe")
	; #IfWinActive ahk_exe MyPopo.exe
	; #IfWinActive ahk_exe WeChat.exe

	CapsLock::
	return


#If CheckEnableMiddleMouseButtonInIdea()
; #IfWinActive ahk_exe idea64.exe

	MButton::
	; MouseGetPos, StartVarX, StartVarY
	; loop
	; {
	; 	sleep, 66
	; 	MouseGetPos, CheckVarX, CheckVarY
	; 	If ((StartVarX != CheckVarX) or (StartVarY != CheckVarY)) {
	; 		; tt("Y U MOVE MY MOUSE!?")
	; 		Click, Down Middle
	; 		sleep, 222
	; 		Click, Up Middle
	; 		return
	; 	}
	; 	else {
	; 		break
	; 	}
	; }
	Click, 2
	Send, !+s
	return