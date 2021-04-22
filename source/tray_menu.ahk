﻿
if(A_ScriptName=="tray_menu.ahk") {
	ExitApp
}

; with this label, you can include this file on top of the file
Goto, SUB_TRAY_MENU_FILE_END_LABEL


#Include %A_ScriptDir%\source\sux_core.ahk
#Include %A_ScriptDir%\source\action.ahk

class TrayMenu
{
	static ICON_DIR := "app_data/"
	static icon_default := TrayMenu.ICON_DIR "sux_default.ico"
	static icon_disable := TrayMenu.ICON_DIR "sux_disable.ico"

	init() {
		this.update_tray_menu()
		this.SetAutorun("config")
	}

	SetAutorun(act="toggle")
	{
		cfg := SuxCore.GetConfig("autorun", 0)
		autorun := (act="config")? cfg :act
		autorun := (act="toggle")? !cfg :autorun
		Regedit.Autorun(autorun, SuxCore.ProgramName, SuxCore.Launcher_Name)
		SuxCore.SetConfig("autorun", autorun)
		if(autorun)
		{
			Menu, Tray, Check, % lang("Start With Windows")
		}
		Else
		{
			Menu, Tray, UnCheck, % lang("Start With Windows")
		}
	}

	; Tray Menu
	update_tray_menu()
	{
		version_str := lang("About") " v" SuxCore.version
		autorun := SuxCore.GetConfig("autorun", 0)
		remote_ver_str := SuxCore.get_remote_config("ver")
		if (remote_ver_str != "ERROR" && get_version_sum(remote_ver_str) > get_version_sum(SuxCore.version)) {
			check_update_menu_name := lang("A New Version! ") "v" remote_ver_str
		}
		else {
			check_update_menu_name := lang("Check Update")
		}
		lang := SuxCore.GetConfig("lang", SuxCore.Default_lang)
		Menu, Tray, Tip, % SuxCore.ProgramName
		xMenu.New("TrayLanguage"
			,[["English", "SuxCore.SetLang", {check: lang=="en"}]
			, ["中文", "SuxCore.SetLang", {check: lang=="cn"}]])
		TrayMenuList := []
		TrayMenuList := EnhancedArray.merge(TrayMenuList
			,[[version_str, "TrayMenu.AboutSux"]
			,[lang("Help"), SuxCore.help_addr]
			,[lang("Donate"), SuxCore.donate_page]
			,[check_update_menu_name, "CheckUpdate"]
			,[]
			,[lang("Start With Windows"), "TrayMenu.SetAutorun", {check: autorun}]
			,["Language",, {"sub": "TrayLanguage"}]
			,[]
			,[lang("Open sux Folder"), A_WorkingDir]
			,[lang("Edit Config File"), "SuxCore.Edit_conf_yaml"]
			,[]
			,[lang("Disable"), "SuxCore.SetDisable", {check: A_IsPaused&&A_IsSuspended}]
			,[lang("Restart sux"), "ReloadSux"]
			,[lang("Exit"), "SuxCore.ExitSux"] ])
		this.SetMenu(TrayMenuList)
		Menu, Tray, Default, % lang("Disable")
		Menu, Tray, Click, 1
		this.Update_Icon()
	}

	static _switch_tray_standard_menu := 0
	Standard_Tray_Menu(act="toggle")
	{
		SuxCore._switch_tray_standard_menu := (act="toggle")? !SuxCore._switch_tray_standard_menu :act
		this.update_tray_menu()
	}

	AboutSux()
	{
		Gui, sux_About: New
		Gui sux_About:+Resize +AlwaysOnTop +MinSize400 -MaximizeBox -MinimizeBox
		Gui, Font, s12
		s := "sux v" SuxCore.version
		Gui, Add, Text,, % s
		s := "<a href=""" SuxCore.Project_Home_Page """>" lang("Home Page") "</a>"
		Gui, Add, Link,, % s
		s := "<a href=""" SuxCore.Project_Issue_page """>" lang("Feedback") "</a>"
		Gui, Add, Link,, % s
		Gui, Add, Text
		GuiControl, Focus, Close
		Gui, Show,, About sux
	}

	Update_Icon()
	{
		setsuspend := A_IsSuspended
		setpause := A_IsPaused
		if !setpause && !setsuspend {
			this.SetIcon(this.icon_default)
		}
		Else if !setpause && setsuspend {
			this.SetIcon(this.icon_disable)
		}
		Else if setpause && !setsuspend {
			this.SetIcon(this.icon_disable)
		}
		Else if setpause && setsuspend {
			this.SetIcon(this.icon_disable)
		}
	}

	; Tray.SetIcon
	SetIcon(path)
	{
		if(FileExist(path)) {
			Menu, Tray, Icon, %path%,,1
		}
	}

	; Tray.SetMenu
	SetMenu(menuList)
	{
		Menu, Tray, DeleteAll
		Menu, Tray, NoStandard
		xMenu.add("Tray", menuList)
	}
}



; //////////////////////////////////////////////////////////////////////////
; //////////////////////////////////////////////////////////////////////////
; //////////////////////////////////////////////////////////////////////////
/*
e.g.
xMenu.Add("Menu1", [["item1","func1"],["item2","func2"],[]
				,["submenu",["subitem_1","func3"]
				,["subitem_2",, {sub: "SubMenu", "disable"}]]])
xMenu.Show("Menu1")
*/
class xMenu
{
	static MenuList := {}

	Show(Menu_Name, X := "", Y := "")
	{
		if (X == "" || Y == "")
			Menu, %Menu_Name%, Show
		Else
			Menu, %Menu_Name%, Show, % X, % Y
	}

	New(Menu_Name, Menu_Config)
	{
		this.Clear(Menu_Name)
		this.Add(Menu_Name, Menu_Config)
	}

	Clear(Menu_Name)
	{
		Try
		{
			Menu, %Menu_Name%, DeleteAll
		}
	}

	Add(Menu_Name, Menu_Config)
	{
		ParsedCfg := this._Config_Parse(Menu_Name, Menu_Config)
		Loop, % ParsedCfg.MaxIndex()
		{
			cfg_entry := ParsedCfg[A_Index]
			if (cfg_entry[4].HasKey("sub"))
			{
				sub_name := cfg_entry[4]["sub"]
				Menu, % cfg_entry[1], Add, % cfg_entry[2], :%sub_name%
			}
			Else
			{
				Menu, % cfg_entry[1], Add, % cfg_entry[2], Sub_xMenu_Open
				this.MenuList[cfg_entry[1] "_" cfg_entry[2]] := cfg_entry[3]
			}
			For Key, Value in cfg_entry[4]
			{
				if Value = 0
					Continue
				StringLower, Key, Key
				if(Key == "check")
					Menu, % cfg_entry[1], Check, % cfg_entry[2]
				if(Key == "uncheck")
					Menu, % cfg_entry[1], UnCheck, % cfg_entry[2]
				if(Key == "togglecheck")
					Menu, % cfg_entry[1], ToggleCheck, % cfg_entry[2]
				if(Key == "enable")
					Menu, % cfg_entry[1], Enable, % cfg_entry[2]
				if(Key == "disable")
					Menu, % cfg_entry[1], Disable, % cfg_entry[2]
				if(Key == "toggleenable")
					Menu, % cfg_entry[1], ToggleEnable, % cfg_entry[2]
			}
		}
	}

	_Config_Parse(PName, Config)
	{
		ParsedCfg := {}
		Loop, % Config.MaxIndex()
		{
			cfg_entry := Config[A_Index]
			If IsObject(cfg_entry[2])
			{
				ParsedCfg_Sub := this._Config_Parse(cfg_entry[1], cfg_entry[2])
				Loop, % ParsedCfg_Sub.MaxIndex()
				{
					sub_entry := ParsedCfg_Sub[A_Index]
					ParsedCfg.Insert([sub_entry[1],sub_entry[2],sub_entry[3],sub_entry[4]])
				}
				ParsedCfg.Insert([PName,cfg_entry[1],,{"sub":cfg_entry[1]}])
			}
			Else
			{
				if cfg_entry.MaxIndex() == 3
					cfg_ctrl := cfg_entry[3]
				Else
					cfg_ctrl := {}
				ParsedCfg.Insert([PName,cfg_entry[1],cfg_entry[2],cfg_ctrl])
			}
		}
		Return % ParsedCfg
	}
}

Sub_xMenu_Open:
Run(xMenu.MenuList[A_ThisMenu "_" A_ThisMenuItem])
Return


; //////////////////////////////////////////////////////////////////////////
SUB_TRAY_MENU_FILE_END_LABEL:
	temp_tm := "blabla"