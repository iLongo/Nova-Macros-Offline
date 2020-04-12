#NoEnv
#SingleInstance,Force
global WindowsKey, Edt1, Edt2
global buttonName = %0% 
global buttonPath := "C:\ProgramData\Nova Macros\" buttonName ".ahk"
WindowsKey := 0

Gui, +hwndHw
Gui, Color, , 4444444
Gui, Font, s14 cffff00 TAhoma
Gui,Add,Hotkey, W280 x-990 y6 vEdt1 gEdt1 hwndHedt1
Gui,Add,Edit, x10 y6 w280 vEdt2 hwndHedt2 Background00ffff, None
Gui, Font, s10 c000000 TAhoma
Gui Add, CheckBox, x16 y48 w190 h23 gWindowsKey vWindowsKey, Windows Key Pressed
Gui Font, Bold
Gui Add, Button, x200 y72 w95 h30 gCreate, APPLY
Gui,Show, w300 h108, Generate Macro

OnMessage(0x133, "Focus_Hk")
SetTimer, FcEdt, 250
return

Focus_Hk() {
    GuiControl, Focus, Edt1
}

FcEdt:
    if !WinActive("ahk_id " Hw)
        GuiControl, Focus, Edt2
return

Edt1:
    GuiControlGet, Ehk,, Edt1
    StringUpper, Ehk, Ehk , T
    Ehk:=StrReplace(Ehk, "`+", "Shift + "), Ehk:=StrReplace(Ehk, "`!", "Alt + "), Ehk:=StrReplace(Ehk, "`^", "Ctrl + ")
    if Ehk
        GuiControl,, Edt2, % Ehk
    else GuiControl,, Edt2, None
Return

WindowsKey:
    WindowsKey := !WindowsKey
return

Create:
    if FileExist(buttonPath)
	{
		OnMessage(0x44, "OnMsgBox")
		MsgBox 0x34, Overwrite?, This button already has a macro file`, do you want to overwrite it?`n`nPrevious function will be lost!
		OnMessage(0x44, "")

		IfMsgBox Yes, {
			Generar()
		}
	}
	else
	{
		Generar()
	}
return

Generar()
{
    Gui, Submit, NoHide
    Key := SubStr(Edt1, StrLen(Edt1), 1)
    if(Key = "+")
    {
        StringTrimRight, EdtNoPlusKey, Edt, 1
        plusKey := 1
    }
    else
    {
        plusKey := 0
    }
    if(!plusKey)
    {
        mas := InStr(Edt1,"+",0,0)
        acento := InStr(Edt1,"^",0,0)
        admiracion := InStr(Edt1,"!",0,0)
        if(mas > acento && mas > admiracion)
        {
            Modificadores := SubStr(Edt1, 1, mas)
        }
        else if(acento > mas && acento > admiracion)
        {
            Modificadores := SubStr(Edt1, 1, acento)
        }
        else if(admiracion > acento && admiracion > mas)
        {
            Modificadores := SubStr(Edt1, 1, admiracion)
        }
        if(mas = 0 && acento = 0 && admiracion = 0 && WindowsKey = 0)
        {
            hayModificadores := 0
        }else
        {
            hayModificadores := 1
        }
        StringReplace, Key, Edt1, %Modificadores%,,All
        Key = {%Key%}
    }
    else
    {
        mas := InStr(EdtNoPlusKey,"+",0,0)
        acento := InStr(EdtNoPlusKey,"^",0,0)
        admiracion := InStr(EdtNoPlusKey,"!",0,0)
        if(mas > acento && mas > admiracion)
        {
            Modificadores := SubStr(EdtNoPlusKey, 1, mas)
        }
        else if(acento > mas && acento > admiracion)
        {
            Modificadores := SubStr(EdtNoPlusKey, 1, acento)
        }
        else if(admiracion > acento && admiracion > mas)
        {
            Modificadores := SubStr(EdtNoPlusKey, 1, admiracion)
        }
        if(mas = 0 && acento = 0 && admiracion = 0 && WindowsKey = 0)
        {
            hayModificadores := 0
        }else
        {
            hayModificadores := 1
        }
        Key := "+"
    }
    
    strModificadoresDown := ""
    strModificadoresUp := ""
    if(Instr(Modificadores, "!"))
    {
        alt := 1
        strModificadoresDown := strModificadoresDown "{Alt Down}"
        strModificadoresUp := strModificadoresUp "{Alt Up}"
    }
    else
    {
        alt := 0
    }
    if(Instr(Modificadores, "^"))
    {
        control := 1
        strModificadoresDown := strModificadoresDown "{Control Down}"
        strModificadoresUp := strModificadoresUp "{Control Up}"
    }
    else
    {
        control := 0
    }
    if(Instr(Modificadores, "+"))
    {
        shift := 1
        strModificadoresDown := strModificadoresDown "{Shift Down}"
        strModificadoresUp := strModificadoresUp "{Shift Up}"
    }
    else
    {
        shift := 0
    }
    if(WindowsKey)
    {
        strModificadoresDown := strModificadoresDown "{LWin Down}"
        strModificadoresUp := strModificadoresUp "{LWin Up}"
    }
    if(!hayModificadores)
    {
		src =
		(Ltrim
            #NoEnv
            #SingleInstance, Force
            SetBatchLines, -1
            #NoTrayIcon
            Send, %Key%
        )
    }
    else
    {
        src =
		(Ltrim
            #NoEnv
            #SingleInstance, Force
            SetBatchLines, -1
            #NoTrayIcon
            Send, %strModificadoresDown%
            Sleep, 30
            Send, %Key%
            Sleep, 30
            Send, %strModificadoresUp%
            Sleep, 30
        )
    }
    FileDelete, % buttonPath
	FileAppend, %src%, % buttonPath
	ExitApp
}

GuiClose:
	ExitApp