; AHK Version ..: 1.1.32.0 (Unicode 32-bit)
; OS Version ...: Windows 10 (Previous versions tested working on Win7)
;@Ahk2Exe-SetName Nova Macros Client Offline
;@Ahk2Exe-SetDescription Nova Macros for local TouchScreen
;@Ahk2Exe-SetVersion 2.7-offline
;@Ahk2Exe-SetCopyright Copyright (c) 2020`, elModo7
;@Ahk2Exe-SetOrigFilename Nova Macros Client Offline.exe
; INITIALIZE
; *******************************
#NoEnv
#Persistent
#SingleInstance Force
SetWorkingDir %A_ScriptDir%
DetectHiddenWindows, On
CoordMode,Mouse,Screen
#Include, <nm_msg>
global EsVisible = true
global EnCarpeta := MoverRatonAlPulsarBoton := MiniClient := SiempreVisible := enviarAltTabAlPulsarBoton := false
global Variable, Valor, ValorAnterior, ProgramasRegistrados, PaginasAsociadas, BotonesDuales, CarpetaBoton, PaginaCarpeta, RutaEditorScripts, ExtensionScripts, BotonActivo, BotonAPulsar, windowHandler
global VariableCambioImagen = 0
global RutaBoton1, RutaBoton2, RutaBoton3, RutaBoton4, RutaBoton5, RutaBoton6, RutaBoton7, RutaBoton8, RutaBoton9, RutaBoton10, RutaBoton11, RutaBoton12, RutaBoton13, RutaBoton14, RutaBoton15
global EstadosBotonesDuales := []
global feedbackEjecucion := []
global NumeroPagina := cargaProgresivaIconos := 0
global MsgBoxBtn1, MsgBoxBtn2, MsgBoxBtn3, MsgBoxBtn4
global Pantalla_Mitad_X := A_ScreenWidth / 2
global Pantalla_Mitad_Y := A_ScreenHeight / 2
global ClientVersion := "2.7 Offline"
FileCreateDir, conf

if(!FileExist("./conf/ProgramPages.txt"))
{
	FileAppend, obs64.exe|explorer.exe|chrome.exe`n, ./conf/ProgramPages.txt
	FileAppend, 0|3|1, ./conf/ProgramPages.txt
}

;~ Cargar Programas asociados a p�ginas
NumeroLoop := 1
Loop, read, ./conf/ProgramPages.txt
{
    StringSplit, LineArray, A_LoopReadLine, %A_Tab%
	if(NumeroLoop == "1")
	{
	    ProgramasRegistradosRead := LineArray1
	}
	else if(NumeroLoop == "2")
	{
		PaginasAsociadasRead := LineArray1
	}
	NumeroLoop++
}
StringSplit, ProgramasRegistrados, ProgramasRegistradosRead, |, ; Creo el array ProgramasRegistrados del string ProgramasRegistradosRead, separando elementos por coma, ProgramasRegistrados0 contiene el count de elementos, y ProgramasRegistrados1, ProgramasRegistrados2... son los campos del array
StringSplit, PaginasAsociadas, PaginasAsociadasRead, |,
global ProgramasRegistrados0

if(!FileExist("./conf/FolderButtons.txt"))
{
	FileAppend, 6|7`n, ./conf/FolderButtons.txt
	FileAppend, UtilesStream|SonidosOBS, ./conf/FolderButtons.txt
}

;~ Cargar Botones asociados a carpetas
NumeroLoop := 1
Loop, read, ./conf/FolderButtons.txt
{
    StringSplit, LineArray, A_LoopReadLine, %A_Tab%
	if(NumeroLoop == "1")
	{
	    BotonesCarpetasRead := LineArray1
	}
	else if(NumeroLoop == "2")
	{
		CarpetasBotonesRead := LineArray1
	}
	NumeroLoop++
}
StringSplit, BotonesCarpetas, BotonesCarpetasRead, |,
StringSplit, CarpetasBotones, CarpetasBotonesRead, |,
global BotonesCarpetas0

if(!FileExist("./conf/DualButtons.txt"))
{
	FileAppend, 4|5`n, ./conf/DualButtons.txt
	FileAppend, 4Enabled|5Enabled, ./conf/DualButtons.txt
}

;~ Cargar Botones Duales
NumeroLoop := 1
Loop, read, ./conf/DualButtons.txt
{
    StringSplit, LineArray, A_LoopReadLine, %A_Tab%
	if(NumeroLoop == "1")
	{
	    BotonesDualesRead := LineArray1
	}
	else if(NumeroLoop == "2")
	{
		AccionesDualesRead := LineArray1
	}
	NumeroLoop++
}
StringSplit, BotonesDuales, BotonesDualesRead, |,
StringSplit, AccionesDualesRead, AccionesDualesRead, |,
global BotonesDuales0

; Poner los botones duales a 0
i = 1
while(i <= BotonesDuales0)
{
	EstadosBotonesDuales.Push(0)
	i++
}

if(!FileExist("./conf/ExtensionScripts.txt"))
{
	; Extension Scripts
	InputBox, ExtensionScripts, Button Script EXT, Insert the extension of the Scripts triggered by the buttons`nExamples`: exe`, ahk`, py`.`.`., , 500, 145,,,,,ahk
	if ExtensionScripts =
		MsgBox, Couldn't retrieve the extension!
	else
	{
		FileDelete, ./conf/ExtensionScripts.txt
		FileAppend, %ExtensionScripts%`n, ./conf/ExtensionScripts.txt
	}
}
else
{
	if(ExtensionScripts = "")
	{
		FileReadLine,ExtensionScripts,./conf/ExtensionScripts.txt,1
	}
}

; TRAY MENU
; *******************************
Menu, tray, NoStandard
Menu, tray, add, Hide, ToggleHide
Menu, tray, add, Set Editor Path, CambiarRutaEditor
Menu, tray, add
Menu, tray, add, Exit, Exit

; CONTEXT MENU GENERICO
; *******************************
Menu ContextMenuGenerico, Add, Always on Top, SiempreVisible
Menu ContextMenuGenerico, UnCheck, Always on Top
Menu ContextMenuGenerico, Add, Center Mouse after Activation, MoverRatonAlPulsarBotonToggle
Menu ContextMenuGenerico, UnCheck, Center Mouse after Activation
Menu ContextMenuGenerico, Add, Send Alt+Tab after Activation, enviarAltTabAlPulsarBotonToggle
Menu ContextMenuGenerico, UnCheck, Send Alt+Tab after Activation
Menu ContextMenuGenerico, Add, Progressive Icon Loading, cargaProgresivaIconosToggle
Menu ContextMenuGenerico, UnCheck, Progressive Icon Loading
Menu ContextMenuGenerico, Add, Mini Client, CambiarDimensionesCliente
Menu ContextMenuGenerico, UnCheck, Mini Client

; CONTEXT MENU BOTONES
; *******************************
Menu scriptGenerator, Add, Run File, ScriptGenerator_RunFile
Menu scriptGenerator, Icon, Run File, shell32.dll, 25
Menu scriptGenerator, Add, Run Cmd, ScriptGenerator_RunCmd
Menu scriptGenerator, Icon, Run Cmd, imageres.dll, 263
Menu scriptGenerator, Add, Send Text, ScriptGenerator_SendText
Menu scriptGenerator, Icon, Send Text, shell32.dll, 71
Menu scriptGenerator, Add, Hotkey - Macro, ScriptGenerator_Hotkey
Menu scriptGenerator, Icon, Hotkey - Macro, imageres.dll, 174
Menu MultimediaFunctions, Add, Play / Pause, ScriptGenerator_Multimedia_PlayPause
Menu MultimediaFunctions, Icon, Play / Pause, imageres.dll, 62
Menu MultimediaFunctions, Add, Stop, ScriptGenerator_Multimedia_Stop
Menu MultimediaFunctions, Icon, Stop, imageres.dll, 62
Menu MultimediaFunctions, Add, Previous, ScriptGenerator_Multimedia_Previous
Menu MultimediaFunctions, Icon, Previous, imageres.dll, 62
Menu MultimediaFunctions, Add, Next, ScriptGenerator_Multimedia_Next
Menu MultimediaFunctions, Icon, Next, imageres.dll, 62
Menu MultimediaFunctions, Add, Volume +, ScriptGenerator_Multimedia_MoreVolume
Menu MultimediaFunctions, Icon, Volume +, imageres.dll, 62
Menu MultimediaFunctions, Add, Volume -, ScriptGenerator_Multimedia_LessVolume
Menu MultimediaFunctions, Icon, Volume -, imageres.dll, 62
Menu MultimediaFunctions, Add, Mute / Unmute, ScriptGenerator_Multimedia_Mute
Menu MultimediaFunctions, Icon, Mute / Unmute, imageres.dll, 62
Menu QuickActionsMenu, Add, Close Window, ScriptGenerator_QuickActions_CloseWindow
Menu QuickActionsMenu, Icon, Close Window, imageres.dll, 236
Menu QuickActionsMenu, Add, Maximize Window, ScriptGenerator_QuickActions_Maximize
Menu QuickActionsMenu, Icon, Maximize Window, imageres.dll, 287
Menu QuickActionsMenu, Add, Minimize Window, ScriptGenerator_QuickActions_Minimize
Menu QuickActionsMenu, Icon, Minimize Window, imageres.dll, 17
Menu QuickActionsMenu, Add, Show Desktop, ScriptGenerator_QuickActions_ShowDesktop
Menu QuickActionsMenu, Icon, Show Desktop, imageres.dll, 106
Menu QuickActionsMenu, Add, New Explorer Window, ScriptGenerator_QuickActions_NewExplorer
Menu QuickActionsMenu, Icon, New Explorer Window, imageres.dll, 5
Menu QuickActionsMenu, Add, New Folder, ScriptGenerator_QuickActions_NewFolder
Menu QuickActionsMenu, Icon, New Folder, shell32.dll, 280
Menu QuickActionsMenu, Add, Quick Rename File, ScriptGenerator_QuickActions_QuickRename
Menu QuickActionsMenu, Icon, Quick Rename File, shell32.dll, 134
Menu QuickActionsMenu, Add, Lock PC, ScriptGenerator_QuickActions_LockPC
Menu QuickActionsMenu, Icon, Lock PC, shell32.dll, 45
Menu QuickActionsMenu, Add, Shutdown PC, ScriptGenerator_QuickActions_Shutdown
Menu QuickActionsMenu, Icon, Shutdown PC, shell32.dll, 28
Menu QuickActionsMenu, Add, System Info, ScriptGenerator_QuickActions_SystemInfo
Menu QuickActionsMenu, Icon, System Info, shell32.dll, 24
Menu QuickActionsMenu, Add, System FULL Info, ScriptGenerator_QuickActions_FullSystemInfo
Menu QuickActionsMenu, Icon, System FULL Info, shell32.dll, 22
Menu QuickActionsMenu, Add, cmd.exe, ScriptGenerator_QuickActions_Cmd
Menu QuickActionsMenu, Icon, cmd.exe, imageres.dll, 263
Menu QuickActionsMenu, Add, PowerShell, ScriptGenerator_QuickActions_PowerShell
Menu QuickActionsMenu, Icon, PowerShell, imageres.dll, 312
Menu QuickActionsMenu, Add, Take Screenshot, ScriptGenerator_QuickActions_ScreenShot
Menu QuickActionsMenu, Icon, Take Screenshot, imageres.dll, 68
Menu QuickActionsMenu, Add, Snip img from screen, ScriptGenerator_QuickActions_SnipImage
Menu QuickActionsMenu, Icon, Snip img from screen, imageres.dll, 17
Menu QuickActionsMenu, Add, Windows Gaming Panel, ScriptGenerator_QuickActions_GamePanel
Menu QuickActionsMenu, Icon, Windows Gaming Panel, imageres.dll, 305
Menu WebBrowserCommands, Add, Next Tab, ScriptGenerator_WebBrowser_NextTab
Menu WebBrowserCommands, Icon, Next Tab, shell32.dll, 15
Menu WebBrowserCommands, Add, Previous Tab, ScriptGenerator_WebBrowser_PreviousTab
Menu WebBrowserCommands, Icon, Previous Tab, shell32.dll, 15
Menu WebBrowserCommands, Add, New Tab, ScriptGenerator_WebBrowser_NewTab
Menu WebBrowserCommands, Icon, New Tab, shell32.dll, 15
Menu WebBrowserCommands, Add, New Window, ScriptGenerator_WebBrowser_NewWindow
Menu WebBrowserCommands, Icon, New Window, shell32.dll, 15
Menu WebBrowserCommands, Add, Close Tab, ScriptGenerator_WebBrowser_CloseTab
Menu WebBrowserCommands, Icon, Close Tab, shell32.dll, 15
Menu WebBrowserCommands, Add, Restore Closed Tab, ScriptGenerator_WebBrowser_RestoreTab
Menu WebBrowserCommands, Icon, Restore Closed Tab, shell32.dll, 15
Menu WebBrowserCommands, Add, Chrome Private Window (NEW), ScriptGenerator_WebBrowser_ChromePrivWindow
Menu WebBrowserCommands, Icon, Chrome Private Window (NEW), shell32.dll, 15
Menu FunctionKeysMenu, Add, F13, ScriptGenerator_FunctionKeys_F13
Menu FunctionKeysMenu, Icon, F13, imageres.dll, 174
Menu FunctionKeysMenu, Add, F14, ScriptGenerator_FunctionKeys_F14
Menu FunctionKeysMenu, Icon, F14, imageres.dll, 174
Menu FunctionKeysMenu, Add, F15, ScriptGenerator_FunctionKeys_F15
Menu FunctionKeysMenu, Icon, F15, imageres.dll, 174
Menu FunctionKeysMenu, Add, F16, ScriptGenerator_FunctionKeys_F16
Menu FunctionKeysMenu, Icon, F16, imageres.dll, 174
Menu FunctionKeysMenu, Add, F17, ScriptGenerator_FunctionKeys_F17
Menu FunctionKeysMenu, Icon, F17, imageres.dll, 174
Menu FunctionKeysMenu, Add, F18, ScriptGenerator_FunctionKeys_F18
Menu FunctionKeysMenu, Icon, F18, imageres.dll, 174
Menu FunctionKeysMenu, Add, F19, ScriptGenerator_FunctionKeys_F19
Menu FunctionKeysMenu, Icon, F19, imageres.dll, 174
Menu FunctionKeysMenu, Add, F20, ScriptGenerator_FunctionKeys_F20
Menu FunctionKeysMenu, Icon, F20, imageres.dll, 174
Menu FunctionKeysMenu, Add, F21, ScriptGenerator_FunctionKeys_F21
Menu FunctionKeysMenu, Icon, F21, imageres.dll, 174
Menu FunctionKeysMenu, Add, F22, ScriptGenerator_FunctionKeys_F22
Menu FunctionKeysMenu, Icon, F22, imageres.dll, 174
Menu FunctionKeysMenu, Add, F23, ScriptGenerator_FunctionKeys_F23
Menu FunctionKeysMenu, Icon, F23, imageres.dll, 174
Menu FunctionKeysMenu, Add, F24, ScriptGenerator_FunctionKeys_F24
Menu FunctionKeysMenu, Icon, F24, imageres.dll, 174
Menu scriptGenerator, Add, Multimedia, :MultimediaFunctions
Menu scriptGenerator, Icon, Multimedia, imageres.dll, 19
Menu scriptGenerator, Add, Web Browser, :WebBrowserCommands
Menu scriptGenerator, Icon, Web Browser, shell32.dll, 221
Menu scriptGenerator, Add, Quick Actions, :QuickActionsMenu
Menu scriptGenerator, Icon, Quick Actions, imageres.dll, 293
Menu scriptGenerator, Add, Hidden Function Keys (F13-F24), :FunctionKeysMenu
Menu scriptGenerator, Icon, Hidden Function Keys (F13-F24), imageres.dll, 174

Menu ContextMenu, Add, Edit Script`tShift + Click, GuiEditarScript
Menu ContextMenu, Default, Edit Script`tShift + Click
Menu ContextMenu, Icon, Edit Script`tShift + Click, shell32.dll, 85
Menu ContextMenu, Add, Script Generator`tAlt + Right Click, :scriptGenerator
Menu ContextMenu, Icon, Script Generator`tAlt + Right Click, shell32.dll, 22
Menu ContextMenu, Add, Change/Del Image`tCtrl + Shift + Click, GuiCambiarImagenBoton
Menu ContextMenu, Icon, Change/Del Image`tCtrl + Shift + Click, shell32.dll, 142
Menu ContextMenu, Add, Button Name`tCtrl + Click, GuiInfoBoton
Menu ContextMenu, Icon, Button Name`tCtrl + Click, shell32.dll, 24
Menu ContextMenu, Add, Create Folder Button, CreateFolderButton
Menu ContextMenu, Icon, Create Folder Button, shell32.dll, 280
Menu ContextMenu, Add, Delete Folder Button, DeleteFolderButton
Menu ContextMenu, Icon, Delete Folder Button, shell32.dll, 235
Menu ContextMenu, Add, Delete Button Function, DeleteButtonFunction
Menu ContextMenu, Icon, Delete Button Function, shell32.dll, 132

; GUI
; *******************************
Gui, Color, 282828
Gui -Caption +LastFound +ToolWindow +HwndwindowHandler +E0x02000000 +E0x00080000 +AlwaysOnTop
; Fila1
Gui Add, Picture, +BackgroundTrans gBoton1 vBoton1, resources\img\1.png
Gui Add, Picture, +BackgroundTrans gBoton2 vBoton2, resources\img\2.png
Gui Add, Picture, +BackgroundTrans gBoton3 vBoton3, resources\img\3.png
Gui Add, Picture, +BackgroundTrans gBoton4 vBoton4, resources\img\4.png
Gui Add, Picture, +BackgroundTrans gBoton5 vBoton5, resources\img\5.png
; Fila2
Gui Add, Picture, +BackgroundTrans gBoton6 vBoton6, resources\img\6.png
Gui Add, Picture, +BackgroundTrans gBoton7 vBoton7, resources\img\7.png
Gui Add, Picture, +BackgroundTrans gBoton8 vBoton8, resources\img\8.png
Gui Add, Picture, +BackgroundTrans gBoton9 vBoton9, resources\img\9.png
Gui Add, Picture, +BackgroundTrans gBoton10 vBoton10, resources\img\10.png
; Fila3
Gui Add, Picture, +BackgroundTrans gBoton11 vBoton11, resources\img\11.png
Gui Add, Picture, +BackgroundTrans gBoton12 vBoton12, resources\img\12.png
Gui Add, Picture, +BackgroundTrans gBoton13 vBoton13, resources\img\13.png
Gui Add, Picture, +BackgroundTrans gBoton14 vBoton14, resources\img\14.png
Gui Add, Picture, +BackgroundTrans gBoton15 vBoton15, resources\img\15.png
; Fondos Activaciones Botones
Gui Add, Picture, vActivar1 Hidden x120 y40 w150 h150,resources\img\FondoActivacion.png
Gui Add, Picture, vActivar2 Hidden x280 y40 w150 h150,resources\img\FondoActivacion.png
Gui Add, Picture, vActivar3 Hidden x440 y40 w150 h150,resources\img\FondoActivacion.png
Gui Add, Picture, vActivar4 Hidden x600 y40 w150 h150,resources\img\FondoActivacion.png
Gui Add, Picture, vActivar5 Hidden x760 y40 w150 h150,resources\img\FondoActivacion.png
Gui Add, Picture, vActivar6 Hidden x120 y220 w150 h150,resources\img\FondoActivacion.png
Gui Add, Picture, vActivar7 Hidden x280 y220 w150 h150,resources\img\FondoActivacion.png
Gui Add, Picture, vActivar8 Hidden x440 y220 w150 h150,resources\img\FondoActivacion.png
Gui Add, Picture, vActivar9 Hidden x600 y220 w150 h150,resources\img\FondoActivacion.png
Gui Add, Picture, vActivar10 Hidden x760 y220 w150 h150,resources\img\FondoActivacion.png
Gui Add, Picture, vActivar11 Hidden x120 y400 w150 h150,resources\img\FondoActivacion.png
Gui Add, Picture, vActivar12 Hidden x280 y400 w150 h150,resources\img\FondoActivacion.png
Gui Add, Picture, vActivar13 Hidden x440 y400 w150 h150,resources\img\FondoActivacion.png
Gui Add, Picture, vActivar14 Hidden x600 y400 w150 h150,resources\img\FondoActivacion.png
Gui Add, Picture, vActivar15 Hidden x760 y400 w150 h150,resources\img\FondoActivacion.png
; Botones P�gina
Gui Add, Picture, +BackgroundTrans gRightPage vRightPage x910 y240 w130 h130, resources\img\RightPage.png
Gui Add, Picture, +BackgroundTrans gLeftPage vLeftPage x0 y240 w130 h130, resources\img\LeftPage.png
; Fondo y secciones mover
Gui Add, Picture, x0 y0 w1024 h600, resources\img\background.jpg
Gui, Add, Text, x0 y0 w1024 h50 cWhite Center GMoverVentana vMoverVentanaUp, ; Mover Ventana de arriba
Gui, Add, Text, x0 y570 w1024 h50 cWhite Center GMoverVentana vMoverVentanaDown, ; Mover Ventana de abajo
EstablecerPagina(0)
Gui Show, w1024 h600, Nova Macros Client
Return

; LABELS BOTONES Y FUNCIONES GENERALES
; *******************************
Show:
if WinExist("Nova Macros Client"){
	WinHide, Nova Macros Client
}
Return

ToggleHide:
if EsVisible
{
	WinHide, Nova Macros Client
	Menu, tray, Rename, Hide, Show
	EsVisible = 0
}
else
{
	WinShow, Nova Macros Client
	WinActivate, Nova Macros Client
	Menu, tray, Rename, Show, Hide
	EsVisible = 1
}
Return

GuiContextMenu:
	if GetKeyState("Alt")
		scriptGen := 1
	else
		scriptGen := 0
	if A_GuiControl In Boton1,Boton2,Boton3,Boton4,Boton5,Boton6,Boton7,Boton8,Boton9,Boton10,Boton11,Boton12,Boton13,Boton14,Boton15
	{
		StringReplace, BotonAPulsar, A_GuiControl, boton,
		if(EnCarpeta)
			BotonActivo := CarpetaBoton 15*PaginaCarpeta+BotonAPulsar
		else
			BotonActivo := 15*NumeroPagina+BotonAPulsar
		if (scriptGen)
		{
			KeyWait, Alt,
			Menu scriptGenerator, Show
		}
		else
		{
			Menu ContextMenu, Show
		}
	}
	else
		Menu ContextMenuGenerico, Show
return

GuiEditarScript:
	EditarScriptBoton(BotonActivo)
return

GuiCambiarImagenBoton:
	EstablecerImagenBoton(BotonActivo)
return

GuiInfoBoton:
	MsgBox,,Button ID, Clicked button Id is: %BotonActivo%
return

ScriptGenerator_RunFile:
	Run, "lib\script_generator\RunFile.ahk" %BotonActivo%
return

ScriptGenerator_RunCmd:
	Run, "lib\script_generator\RunCmd.ahk" %BotonActivo%
return

ScriptGenerator_SendText:
	Run, "lib\script_generator\SendTextBlock.ahk" %BotonActivo%
return

ScriptGenerator_Hotkey:
	Run, "lib\script_generator\HotkeyCreator.ahk" %BotonActivo%
return

ScriptGenerator_Multimedia_PlayPause:
	if(ComprobarExistenciaBoton())
		FileCopy, lib\script_generator\code_snippets\ScriptGenerator_Multimedia_PlayPause.ahk,%BotonActivo%.ahk,1
return

ScriptGenerator_Multimedia_Stop:
	if(ComprobarExistenciaBoton())
		FileCopy, lib\script_generator\code_snippets\ScriptGenerator_Multimedia_Stop.ahk,%BotonActivo%.ahk,1
return

ScriptGenerator_Multimedia_Next:
	if(ComprobarExistenciaBoton())
		FileCopy, lib\script_generator\code_snippets\ScriptGenerator_Multimedia_Next.ahk,%BotonActivo%.ahk,1
return

ScriptGenerator_Multimedia_Previous:
	if(ComprobarExistenciaBoton())
		FileCopy, lib\script_generator\code_snippets\ScriptGenerator_Multimedia_Previous.ahk,%BotonActivo%.ahk,1
return

ScriptGenerator_Multimedia_MoreVolume:
	if(ComprobarExistenciaBoton())
		FileCopy, lib\script_generator\code_snippets\ScriptGenerator_Multimedia_MoreVolume.ahk,%BotonActivo%.ahk,1
return

ScriptGenerator_Multimedia_LessVolume:
	if(ComprobarExistenciaBoton())
		FileCopy, lib\script_generator\code_snippets\ScriptGenerator_Multimedia_LessVolume.ahk,%BotonActivo%.ahk,1
return

ScriptGenerator_Multimedia_Mute:
	if(ComprobarExistenciaBoton())
		FileCopy, lib\script_generator\code_snippets\ScriptGenerator_Multimedia_Mute.ahk,%BotonActivo%.ahk,1
return

ScriptGenerator_FunctionKeys_F13:
	if(ComprobarExistenciaBoton())
		FileCopy, lib\script_generator\code_snippets\ScriptGenerator_FunctionKeys_F13.ahk,%BotonActivo%.ahk,1
return

ScriptGenerator_FunctionKeys_F14:
	if(ComprobarExistenciaBoton())
		FileCopy, lib\script_generator\code_snippets\ScriptGenerator_FunctionKeys_F14.ahk,%BotonActivo%.ahk,1
return

ScriptGenerator_FunctionKeys_F15:
	if(ComprobarExistenciaBoton())
		FileCopy, lib\script_generator\code_snippets\ScriptGenerator_FunctionKeys_F15.ahk,%BotonActivo%.ahk,1
return

ScriptGenerator_FunctionKeys_F16:
	if(ComprobarExistenciaBoton())
		FileCopy, lib\script_generator\code_snippets\ScriptGenerator_FunctionKeys_F16.ahk,%BotonActivo%.ahk,1
return

ScriptGenerator_FunctionKeys_F17:
	if(ComprobarExistenciaBoton())
		FileCopy, lib\script_generator\code_snippets\ScriptGenerator_FunctionKeys_F17.ahk,%BotonActivo%.ahk,1
return

ScriptGenerator_FunctionKeys_F18:
	if(ComprobarExistenciaBoton())
		FileCopy, lib\script_generator\code_snippets\ScriptGenerator_FunctionKeys_F18.ahk,%BotonActivo%.ahk,1
return

ScriptGenerator_FunctionKeys_F19:
	if(ComprobarExistenciaBoton())
		FileCopy, lib\script_generator\code_snippets\ScriptGenerator_FunctionKeys_F19.ahk,%BotonActivo%.ahk,1
return

ScriptGenerator_FunctionKeys_F20:
	if(ComprobarExistenciaBoton())
		FileCopy, lib\script_generator\code_snippets\ScriptGenerator_FunctionKeys_F20.ahk,%BotonActivo%.ahk,1
return

ScriptGenerator_FunctionKeys_F21:
	if(ComprobarExistenciaBoton())
		FileCopy, lib\script_generator\code_snippets\ScriptGenerator_FunctionKeys_F21.ahk,%BotonActivo%.ahk,1
return

ScriptGenerator_FunctionKeys_F22:
	if(ComprobarExistenciaBoton())
		FileCopy, lib\script_generator\code_snippets\ScriptGenerator_FunctionKeys_F22.ahk,%BotonActivo%.ahk,1
return

ScriptGenerator_FunctionKeys_F23:
	if(ComprobarExistenciaBoton())
		FileCopy, lib\script_generator\code_snippets\ScriptGenerator_FunctionKeys_F23.ahk,%BotonActivo%.ahk,1
return

ScriptGenerator_FunctionKeys_F24:
	if(ComprobarExistenciaBoton())
		FileCopy, lib\script_generator\code_snippets\ScriptGenerator_FunctionKeys_F24.ahk,%BotonActivo%.ahk,1
return

ScriptGenerator_WebBrowser_NextTab:
	if(ComprobarExistenciaBoton())
		FileCopy, lib\script_generator\code_snippets\ScriptGenerator_WebBrowser_NextTab.ahk,%BotonActivo%.ahk,1
return

ScriptGenerator_WebBrowser_PreviousTab:
	if(ComprobarExistenciaBoton())
		FileCopy, lib\script_generator\code_snippets\ScriptGenerator_WebBrowser_PreviousTab.ahk,%BotonActivo%.ahk,1
return

ScriptGenerator_WebBrowser_NewTab:
	if(ComprobarExistenciaBoton())
		FileCopy, lib\script_generator\code_snippets\ScriptGenerator_WebBrowser_NewTab.ahk,%BotonActivo%.ahk,1
return

ScriptGenerator_WebBrowser_NewWindow:
	if(ComprobarExistenciaBoton())
		FileCopy, lib\script_generator\code_snippets\ScriptGenerator_WebBrowser_NewWindow.ahk,%BotonActivo%.ahk,1
return

ScriptGenerator_WebBrowser_CloseTab:
	if(ComprobarExistenciaBoton())
		FileCopy, lib\script_generator\code_snippets\ScriptGenerator_WebBrowser_CloseTab.ahk,%BotonActivo%.ahk,1
return

ScriptGenerator_WebBrowser_RestoreTab:
	if(ComprobarExistenciaBoton())
		FileCopy, lib\script_generator\code_snippets\ScriptGenerator_WebBrowser_RestoreTab.ahk,%BotonActivo%.ahk,1
return

ScriptGenerator_WebBrowser_ChromePrivWindow:
	if(ComprobarExistenciaBoton())
		FileCopy, lib\script_generator\code_snippets\ScriptGenerator_WebBrowser_ChromePrivWindow.ahk,%BotonActivo%.ahk,1
return

ScriptGenerator_QuickActions_CloseWindow:
	if(ComprobarExistenciaBoton())
		FileCopy, lib\script_generator\code_snippets\ScriptGenerator_QuickActions_CloseWindow.ahk,%BotonActivo%.ahk,1
return

ScriptGenerator_QuickActions_Maximize:
	if(ComprobarExistenciaBoton())
		FileCopy, lib\script_generator\code_snippets\ScriptGenerator_QuickActions_Maximize.ahk,%BotonActivo%.ahk,1
return

ScriptGenerator_QuickActions_Minimize:
	if(ComprobarExistenciaBoton())
		FileCopy, lib\script_generator\code_snippets\ScriptGenerator_QuickActions_Minimize.ahk,%BotonActivo%.ahk,1
return

ScriptGenerator_QuickActions_ShowDesktop:
	if(ComprobarExistenciaBoton())
		FileCopy, lib\script_generator\code_snippets\ScriptGenerator_QuickActions_ShowDesktop.ahk,%BotonActivo%.ahk,1
return

ScriptGenerator_QuickActions_NewExplorer:
	if(ComprobarExistenciaBoton())
		FileCopy, lib\script_generator\code_snippets\ScriptGenerator_QuickActions_NewExplorer.ahk,%BotonActivo%.ahk,1
return

ScriptGenerator_QuickActions_NewFolder:
	if(ComprobarExistenciaBoton())
		FileCopy, lib\script_generator\code_snippets\ScriptGenerator_QuickActions_NewFolder.ahk,%BotonActivo%.ahk,1
return

ScriptGenerator_QuickActions_QuickRename:
	if(ComprobarExistenciaBoton())
		FileCopy, lib\script_generator\code_snippets\ScriptGenerator_QuickActions_QuickRename.ahk,%BotonActivo%.ahk,1
return

ScriptGenerator_QuickActions_LockPC:
	if(ComprobarExistenciaBoton())
		FileCopy, lib\script_generator\code_snippets\ScriptGenerator_QuickActions_LockPC.ahk,%BotonActivo%.ahk,1
return

ScriptGenerator_QuickActions_Shutdown:
	if(ComprobarExistenciaBoton())
		FileCopy, lib\script_generator\code_snippets\ScriptGenerator_QuickActions_Shutdown.ahk,%BotonActivo%.ahk,1
return

ScriptGenerator_QuickActions_SystemInfo:
	if(ComprobarExistenciaBoton())
		FileCopy, lib\script_generator\code_snippets\ScriptGenerator_QuickActions_SystemInfo.ahk,%BotonActivo%.ahk,1
return

ScriptGenerator_QuickActions_FullSystemInfo:
	if(ComprobarExistenciaBoton())
		FileCopy, lib\script_generator\code_snippets\ScriptGenerator_QuickActions_FullSystemInfo.ahk,%BotonActivo%.ahk,1
return

ScriptGenerator_QuickActions_Cmd:
	if(ComprobarExistenciaBoton())
		FileCopy, lib\script_generator\code_snippets\ScriptGenerator_QuickActions_Cmd.ahk,%BotonActivo%.ahk,1
return

ScriptGenerator_QuickActions_PowerShell:
	if(ComprobarExistenciaBoton())
		FileCopy, lib\script_generator\code_snippets\ScriptGenerator_QuickActions_PowerShell.ahk,%BotonActivo%.ahk,1
return

ScriptGenerator_QuickActions_ScreenShot:
	if(ComprobarExistenciaBoton())
		FileCopy, lib\script_generator\code_snippets\ScriptGenerator_QuickActions_ScreenShot.ahk,%BotonActivo%.ahk,1
return

ScriptGenerator_QuickActions_SnipImage:
	if(ComprobarExistenciaBoton())
		FileCopy, lib\script_generator\code_snippets\ScriptGenerator_QuickActions_SnipImage.ahk,%BotonActivo%.ahk,1
return

ScriptGenerator_QuickActions_GamePanel:
	if(ComprobarExistenciaBoton())
		FileCopy, lib\script_generator\code_snippets\ScriptGenerator_QuickActions_GamePanel.ahk,%BotonActivo%.ahk,1
return

NotImplemented:
	MsgBox, Not implemented
return

ComprobarExistenciaBoton()
{
	buttonPath := "" BotonActivo ".ahk"
	if FileExist(buttonPath)
	{
		OnMessage(0x44, "OnMsgBox")
		MsgBoxBtn1 = Overwrite
		MsgBoxBtn2 = Cancel
		MsgBox 0x34, Overwrite?, This button already has a macro file`, do you want to overwrite it?`n`nPrevious function will be lost!
		OnMessage(0x44, "")

		IfMsgBox Yes, {
			return 1
		}else{
			return 0
		}
	}
	else
	{
		return 1
	}
}

SiempreVisible:
	if(SiempreVisible)
	{
		Winset, AlwaysOnTop, Off, A
		SiempreVisible := 0
		Menu ContextMenuGenerico, UnCheck, Always on Top
	}
	else
	{
		Winset, AlwaysOnTop, , A
		SiempreVisible := 1
		Menu ContextMenuGenerico, Check, Always on Top
	}
return

MoverRatonAlPulsarBotonToggle:
	if(MoverRatonAlPulsarBoton)
	{
		MoverRatonAlPulsarBoton := 0
		Menu ContextMenuGenerico, UnCheck, Center Mouse after Activation
	}
	else
	{
		MoverRatonAlPulsarBoton := 1
		Menu ContextMenuGenerico, Check, Center Mouse after Activation
	}
return

enviarAltTabAlPulsarBotonToggle:
	if(enviarAltTabAlPulsarBoton)
	{
		enviarAltTabAlPulsarBoton := 0
		Menu ContextMenuGenerico, UnCheck, Send Alt+Tab after Activation
	}
	else
	{
		enviarAltTabAlPulsarBoton := 1
		Menu ContextMenuGenerico, Check, Send Alt+Tab after Activation
	}
return

cargaProgresivaIconosToggle:
	if(cargaProgresivaIconos)
	{
		cargaProgresivaIconos := 0
		Menu ContextMenuGenerico, UnCheck, Progressive Icon Loading
	}
	else
	{
		cargaProgresivaIconos := 1
		Menu ContextMenuGenerico, Check, Progressive Icon Loading
	}
return
 
CambiarDimensionesCliente:
if(!cargaProgresivaIconos)
	DllCall("LockWindowUpdate", "UInt", windowHandler)
if MiniClient
{
	Menu, ContextMenuGenerico, Rename, Normal Client, Mini Client
	MiniClient = 0
	GuiControl, MoveDraw, Activar1, x120 y40 w150 h150
	GuiControl, MoveDraw, Activar2, x280 y40 w150 h150
	GuiControl, MoveDraw, Activar3, x440 y40 w150 h150
	GuiControl, MoveDraw, Activar4, x600 y40 w150 h150
	GuiControl, MoveDraw, Activar5, x760 y40 w150 h150
	GuiControl, MoveDraw, Activar6, x120 y220 w150 h150
	GuiControl, MoveDraw, Activar7, x280 y220 w150 h150
	GuiControl, MoveDraw, Activar8, x440 y220 w150 h150
	GuiControl, MoveDraw, Activar9, x600 y220 w150 h150
	GuiControl, MoveDraw, Activar10, x760 y220 w150 h150
	GuiControl, MoveDraw, Activar11, x120 y400 w150 h150
	GuiControl, MoveDraw, Activar12, x280 y400 w150 h150
	GuiControl, MoveDraw, Activar13, x440 y400 w150 h150
	GuiControl, MoveDraw, Activar14, x600 y400 w150 h150
	GuiControl, MoveDraw, Activar15, x760 y400 w150 h150
	GuiControl, MoveDraw, LeftPage, x0 y230 w130 h130
	GuiControl, MoveDraw, RightPage, x910 y230 w130 h130
	GuiControl, MoveDraw, MoverVentanaUp, x0 y0 w1024 h50
	GuiControl, MoveDraw, MoverVentanaDown, x0 y570 w1024 h50
	Gui Show, w1024 h600, Nova Macros Client
}
else
{
	Menu, ContextMenuGenerico, Rename, Mini Client, Normal Client
	MiniClient = 1
	GuiControl, MoveDraw, Activar1, x54 y14 w59 h59
	GuiControl, MoveDraw, Activar2, x110 y14 w59 h59
	GuiControl, MoveDraw, Activar3, x166 y14 w59 h59
	GuiControl, MoveDraw, Activar4, x222 y14 w59 h59
	GuiControl, MoveDraw, Activar5, x278 y14 w59 h59
	GuiControl, MoveDraw, Activar6, x54 y70 w59 h59
	GuiControl, MoveDraw, Activar7, x110 y70 w59 h59
	GuiControl, MoveDraw, Activar8, x166 y70 w59 h59
	GuiControl, MoveDraw, Activar9, x222 y70 w59 h59
	GuiControl, MoveDraw, Activar10, x278 y70 w59 h59
	GuiControl, MoveDraw, Activar11, x54 y126 w59 h59
	GuiControl, MoveDraw, Activar12, x110 y126 w59 h59
	GuiControl, MoveDraw, Activar13, x166 y126 w59 h59
	GuiControl, MoveDraw, Activar14, x222 y126 w59 h59
	GuiControl, MoveDraw, Activar15, x278 y126 w59 h59
	GuiControl, MoveDraw, LeftPage, x0 y75 w49 h49
	GuiControl, MoveDraw, RightPage, x340 y75 w49 h49
	GuiControl, MoveDraw, MoverVentanaUp, x-8 y0 w413 h23
	GuiControl, MoveDraw, MoverVentanaDown, x0 y187 w401 h23
	Gui, Show, w385 h200, Nova Macros Client
}
DllCall("LockWindowUpdate", "UInt", 0)
if(EnCarpeta)
{
	EstablecerPaginaCarpeta(CarpetaBoton, PaginaCarpeta)
}
else
{
	EstaBlecerPagina(NumeroPagina)
}
Return

MoverVentana:
PostMessage, 0xA1, 2,,, A 
Return

Boton1:
PulsarBoton(1)
return

Boton2:
PulsarBoton(2)
return

Boton3:
PulsarBoton(3)
return

Boton4:
PulsarBoton(4)
return

Boton5:
PulsarBoton(5)
return

Boton6:
PulsarBoton(6)
return

Boton7:
PulsarBoton(7)
return

Boton8:
PulsarBoton(8)
return

Boton9:
PulsarBoton(9)
return

Boton10:
PulsarBoton(10)
return

Boton11:
PulsarBoton(11)
return

Boton12:
PulsarBoton(12)
return

Boton13:
PulsarBoton(13)
return

Boton14:
PulsarBoton(14)
return

Boton15:
PulsarBoton(15)
return

PulsarBoton(BotonAPulsar)
{
	if(MoverRatonAlPulsarBoton)
		MouseMove, %Pantalla_Mitad_X%, %Pantalla_Mitad_Y%, 0
	AltTab()
	; Lógica Botón
	if(EnCarpeta)
	{
		if(BotonAPulsar != 15)
		{
			IdBoton := CarpetaBoton 15*PaginaCarpeta+BotonAPulsar
			if GetKeyState("Control")
			{
				if GetKeyState("Shift")
				{
					EstablecerImagenBoton(IdBoton)
					return
				}
				MsgBox,,Button ID, Clicked button Id is: %IdBoton%
				return
			}
			if GetKeyState("Alt")
			{
				;CambiarImagenAlternativaBoton(BotonAPulsar, IdBoton)
				return
			}
			if GetKeyState("Shift")
			{
				EditarScriptBoton(IdBoton)
				return
			}
			i = 1
			while(i <= BotonesCarpetas0)
			{
				BotonIteracion := BotonesCarpetas%i%
				if(IdBoton = BotonIteracion)
				{
					EnCarpeta = 1
					CarpetaBoton := CarpetasBotones%i%
					global PaginaCarpeta := 0
					EstablecerPaginaCarpeta(CarpetaBoton, PaginaCarpeta)
					return
				}
				i++
			}
			j = 1
			while(j <= BotonesDuales0)
			{
				if(IdBoton = BotonesDuales%j%)
				{
					if(EstadosBotonesDuales[j] = 0)
					{
						IdVisual :=IdBoton "Enabled"
						EstadosBotonesDuales[j] := 1
					}
					else
					{
						IdVisual :=IdBoton
						EstadosBotonesDuales[j] := 0
					}
					Boton%BotonAPulsar% = 1
					EjecutarFuncionBoton(BotonAPulsar, IdVisual)
					return
				}
				j++
			}
			IdVisual := IdBoton
			EjecutarFuncionBoton(BotonAPulsar, IdVisual)
		}
		else if (BotonAPulsar = 15)
		{
			; Este es un caso especial ya que si está en carpeta siempre tiene el valor volver (salir fuera de la carpeta)
			IdBoton := CarpetaBoton 15*PaginaCarpeta+BotonAPulsar
			EstablecerPagina(NumeroPagina)
			EnCarpeta = 0
			PaginaCarpeta = 0
			return	
		}
	}
	else
	{
		IdBoton := 15*NumeroPagina+BotonAPulsar
		if GetKeyState("Control")
		{
			if GetKeyState("Shift")
			{
				EstablecerImagenBoton(IdBoton)
				return
			}
			MsgBox,,Button ID, Clicked button Id is: %IdBoton%
			return
		}
		if GetKeyState("Alt")
		{
			;CambiarImagenAlternativaBoton(BotonAPulsar, IdBoton)
			return
		}
		if GetKeyState("Shift")
		{
			EditarScriptBoton(IdBoton)
			return
		}
		i = 1
		while(i <= BotonesCarpetas0)
		{
			BotonIteracion := BotonesCarpetas%i%
			if(IdBoton = BotonIteracion)
			{
				EnCarpeta = 1
				CarpetaBoton := CarpetasBotones%i%
				global PaginaCarpeta := 0
				EstablecerPaginaCarpeta(CarpetaBoton, PaginaCarpeta)
				return
			}
			i++
		}
		j = 1
		while(j <= BotonesDuales0)
		{
			if(IdBoton = BotonesDuales%j%)
			{
				if(EstadosBotonesDuales[j] = 0)
				{
					IdVisual := IdBoton "Enabled"
					EstadosBotonesDuales[j] := 1
				}
				else
				{
					IdVisual := IdBoton
					EstadosBotonesDuales[j] := 0
				}
				Boton%BotonAPulsar% = 1
				EjecutarFuncionBoton(BotonAPulsar, IdVisual)
				return
			}
			j++
		}
		IdVisual := IdBoton
		EjecutarFuncionBoton(BotonAPulsar, IdVisual)
	}
	Boton%BotonAPulsar% = 1
}

EstablecerPagina(NumeroPagina)
{
	global
	if(!cargaProgresivaIconos)
		DllCall("LockWindowUpdate", "UInt", windowHandler)
	CarpetaBoton := ""
	RutaBoton1 := CarpetaBoton 15*NumeroPagina+1 ".png"
	RutaBoton2 := CarpetaBoton 15*NumeroPagina+2 ".png"
	RutaBoton3 := CarpetaBoton 15*NumeroPagina+3 ".png"
	RutaBoton4 := CarpetaBoton 15*NumeroPagina+4 ".png"
	RutaBoton5 := CarpetaBoton 15*NumeroPagina+5 ".png"
	RutaBoton6 := CarpetaBoton 15*NumeroPagina+6 ".png"
	RutaBoton7 := CarpetaBoton 15*NumeroPagina+7 ".png"
	RutaBoton8 := CarpetaBoton 15*NumeroPagina+8 ".png"
	RutaBoton9 := CarpetaBoton 15*NumeroPagina+9 ".png"
	RutaBoton10 := CarpetaBoton 15*NumeroPagina+10 ".png"
	RutaBoton11 := CarpetaBoton 15*NumeroPagina+11 ".png"
	RutaBoton12 := CarpetaBoton 15*NumeroPagina+12 ".png"
	RutaBoton13 := CarpetaBoton 15*NumeroPagina+13 ".png"
	RutaBoton14 := CarpetaBoton 15*NumeroPagina+14 ".png"
	RutaBoton15 := CarpetaBoton 15*NumeroPagina+15 ".png"
	
	if(MiniClient)
	{
		RefrescarBotonesMini()
	}
	else
	{
		RefrescarBotones()
	}
	DllCall("LockWindowUpdate", "UInt", 0)
}

EstablecerPaginaCarpeta(CarpetaBoton, PaginaCarpeta)
{
	global
	if(!cargaProgresivaIconos)
		DllCall("LockWindowUpdate", "UInt", windowHandler)
	RutaBoton1 := CarpetaBoton 15*PaginaCarpeta+1 ".png"
	RutaBoton2 := CarpetaBoton 15*PaginaCarpeta+2 ".png"
	RutaBoton3 := CarpetaBoton 15*PaginaCarpeta+3 ".png"
	RutaBoton4 := CarpetaBoton 15*PaginaCarpeta+4 ".png"
	RutaBoton5 := CarpetaBoton 15*PaginaCarpeta+5 ".png"
	RutaBoton6 := CarpetaBoton 15*PaginaCarpeta+6 ".png"
	RutaBoton7 := CarpetaBoton 15*PaginaCarpeta+7 ".png"
	RutaBoton8 := CarpetaBoton 15*PaginaCarpeta+8 ".png"
	RutaBoton9 := CarpetaBoton 15*PaginaCarpeta+9 ".png"
	RutaBoton10 := CarpetaBoton 15*PaginaCarpeta+10 ".png"
	RutaBoton11 := CarpetaBoton 15*PaginaCarpeta+11 ".png"
	RutaBoton12 := CarpetaBoton 15*PaginaCarpeta+12 ".png"
	RutaBoton13 := CarpetaBoton 15*PaginaCarpeta+13 ".png"
	RutaBoton14 := CarpetaBoton 15*PaginaCarpeta+14 ".png"
		
	if(MiniClient)
	{
		RefrescarBotonesMini(true)
	}
	else
	{
		RefrescarBotones(true)
	}
	DllCall("LockWindowUpdate", "UInt", 0)
}

RefrescarBotones(esCarpeta = false)
{
	global
	if(!cargaProgresivaIconos)
		DllCall("LockWindowUpdate", "UInt", windowHandler)
	GuiControl, Text, Boton1, resources\img\%RutaBoton1%
	GuiControl, MoveDraw, Boton1, x130 y50 w130 h130 ; Al cambiarle la ruta hay que resizear el boton
	GuiControl, Text, Boton2, resources\img\%RutaBoton2%
	GuiControl, MoveDraw, Boton2, x290 y50 w130 h130
	GuiControl, Text, Boton3, resources\img\%RutaBoton3%
	GuiControl, MoveDraw, Boton3, x450 y50 w130 h130
	GuiControl, Text, Boton4, resources\img\%RutaBoton4%
	GuiControl, MoveDraw, Boton4, x610 y50 w130 h130
	GuiControl, Text, Boton5, resources\img\%RutaBoton5%
	GuiControl, MoveDraw, Boton5, x770 y50 w130 h130
	GuiControl, Text, Boton6, resources\img\%RutaBoton6%
	GuiControl, MoveDraw, Boton6, x130 w130 y230 h130
	GuiControl, Text, Boton7, resources\img\%RutaBoton7%
	GuiControl, MoveDraw, Boton7, x290 w130 y230 h130
	GuiControl, Text, Boton8, resources\img\%RutaBoton8%
	GuiControl, MoveDraw, Boton8, x450 w130 y230 h130
	GuiControl, Text, Boton9, resources\img\%RutaBoton9%
	GuiControl, MoveDraw, Boton9, x610 w130 y230 h130
	GuiControl, Text, Boton10, resources\img\%RutaBoton10%
	GuiControl, MoveDraw, Boton10, x770 y230 w130 h130
	GuiControl, Text, Boton11, resources\img\%RutaBoton11%
	GuiControl, MoveDraw, Boton11, x130 x130 y410 w130 h130
	GuiControl, Text, Boton12, resources\img\%RutaBoton12%
	GuiControl, MoveDraw, Boton12, x290 y410 w130 h130
	GuiControl, Text, Boton13, resources\img\%RutaBoton13%
	GuiControl, MoveDraw, Boton13, x450 y410 w130 h130
	GuiControl, Text, Boton14, resources\img\%RutaBoton14%
	GuiControl, MoveDraw, Boton14, x610 y410 w130 h130
	if(esCarpeta)
	{
		GuiControl, Text, Boton15, resources\img\Volver.png
		GuiControl, MoveDraw, Boton15, x770 y410 w130 h130	
	}
	else
	{
		GuiControl, Text, Boton15, resources\img\%RutaBoton15%
		GuiControl, MoveDraw, Boton15, x770 y410 w130 h130		
	}
	DllCall("LockWindowUpdate", "UInt", 0)
}

RefrescarBotonesMini(esCarpeta = false)
{
	global
	if(!cargaProgresivaIconos)
		DllCall("LockWindowUpdate", "UInt", windowHandler)
	GuiControl, Text, Boton1, resources\img\%RutaBoton1%
	GuiControl, MoveDraw, Boton1, x59 y19 w49 h49
	GuiControl, Text, Boton2, resources\img\%RutaBoton2%
	GuiControl, MoveDraw, Boton2, x115 y19 w49 h49
	GuiControl, Text, Boton3, resources\img\%RutaBoton3%
	GuiControl, MoveDraw, Boton3, x171 y19 w49 h49
	GuiControl, Text, Boton4, resources\img\%RutaBoton4%
	GuiControl, MoveDraw, Boton4, x227 y19 w49 h49
	GuiControl, Text, Boton5, resources\img\%RutaBoton5%
	GuiControl, MoveDraw, Boton5, x283 y19 w49 h49
	GuiControl, Text, Boton6, resources\img\%RutaBoton6%
	GuiControl, MoveDraw, Boton6, x59 y75 w49 h49
	GuiControl, Text, Boton7, resources\img\%RutaBoton7%
	GuiControl, MoveDraw, Boton7, x115 y75 w49 h49
	GuiControl, Text, Boton8, resources\img\%RutaBoton8%
	GuiControl, MoveDraw, Boton8, x171 y75 w49 h49
	GuiControl, Text, Boton9, resources\img\%RutaBoton9%
	GuiControl, MoveDraw, Boton9, x227 y75 w49 h49
	GuiControl, Text, Boton10, resources\img\%RutaBoton10%
	GuiControl, MoveDraw, Boton10, x283 y75 w49 h49
	GuiControl, Text, Boton11, resources\img\%RutaBoton11%
	GuiControl, MoveDraw, Boton11, x59 y131 w49 h49
	GuiControl, Text, Boton12, resources\img\%RutaBoton12%
	GuiControl, MoveDraw, Boton12, x115 y131 w49 h49
	GuiControl, Text, Boton13, resources\img\%RutaBoton13%
	GuiControl, MoveDraw, Boton13, x171 y131 w49 h49
	GuiControl, Text, Boton14, resources\img\%RutaBoton14%
	GuiControl, MoveDraw, Boton14, x227 y131 w49 h49
	if(esCarpeta)
	{
		GuiControl, Text, Boton15, resources\img\Volver.png
		GuiControl, MoveDraw, Boton15, x283 y131 w49 h49
	}
	else
	{
		GuiControl, Text, Boton15, resources\img\%RutaBoton15%
		GuiControl, MoveDraw, Boton15, x283 y131 w49 h49
	}
	DllCall("LockWindowUpdate", "UInt", 0)
}

LeftPage:
	if(MoverRatonAlPulsarBoton)
		MouseMove, %Pantalla_Mitad_X%, %Pantalla_Mitad_Y%, 0
	AltTab()
	if(EnCarpeta)
	{
		if(PaginaCarpeta != 0)
		{
			if GetKeyState("Control")
			{
				if(PaginaCarpeta >= 10)
				{
					PaginaCarpeta := PaginaCarpeta - 10
					EstablecerPaginaCarpeta(CarpetaBoton, PaginaCarpeta)
				}
				return
			}
			PaginaCarpeta--
			EstablecerPaginaCarpeta(CarpetaBoton, PaginaCarpeta)
		}
	}
	else
	{
		if(NumeroPagina != 0)
		{
			if GetKeyState("Control")
			{
				if(NumeroPagina >= 10)
				{
					NumeroPagina := NumeroPagina - 10
					EstablecerPagina(NumeroPagina)
				}
			}
			else
			{
				NumeroPagina--
				EstablecerPagina(NumeroPagina)
			}
		}
	}
return

RightPage:
	if(MoverRatonAlPulsarBoton)
		MouseMove, %Pantalla_Mitad_X%, %Pantalla_Mitad_Y%, 0
	AltTab()
	if(EnCarpeta)
	{
		if GetKeyState("Control")
		{
			PaginaCarpeta := PaginaCarpeta + 10
			EstablecerPaginaCarpeta(CarpetaBoton, PaginaCarpeta)
			return
		}
		PaginaCarpeta++
		EstablecerPaginaCarpeta(CarpetaBoton, PaginaCarpeta)
	}
	else
	{
		if GetKeyState("Control")
		{
			NumeroPagina := NumeroPagina + 10
		}
		else
		{
			NumeroPagina++
		}
		EstablecerPagina(NumeroPagina)
	}
return

EstablecerImagenBoton(IdBoton)
{
	OnMessage(0x44, "OnMsgBox")
	MsgBoxBtn1 = Change Img
	MsgBoxBtn2 = Remove
	MsgBoxBtn3 = Cancel
	MsgBox 0x23, Change - Delete, Change Image or Remove Button?
	OnMessage(0x44, "")

	IfMsgBox Yes, {
		FileSelectFile, ImagenAEstablecer, ,,,*.jpg; *.png; *.gif; *.jpeg; *.bmp; *.ico
		if ImagenAEstablecer =
			MsgBox, No image selected!
		else
		{
			FileCopy, %ImagenAEstablecer%, ./resources/img/%IdBoton%.png, 1
		}
	} 
	Else IfMsgBox No, {
		FileDelete,./resources/img/%IdBoton%.png
		OnMessage(0x44, "OnMsgBox")
		MsgBoxBtn1 = Delete
		MsgBoxBtn2 = Keep
		MsgBox 0x34, Overwrite?, This button has a macro file`, do you want to delete it?`n`nIts function will be lost!
		OnMessage(0x44, "")

		IfMsgBox Yes, {
			FileDelete, %IdBoton%.ahk
		}
	} 
	Else IfMsgBox Cancel, {
		return
	}	
	Sleep, 300
	if(EnCarpeta)
	{
		EstablecerPaginaCarpeta(CarpetaBoton, PaginaCarpeta)
	}
	else
	{
		EstablecerPagina(NumeroPagina)	
	}
}

EditarScriptBoton(IdBoton)
{
	if(!FileExist("./conf/ScriptEditorPath.txt") || !FileExist("./conf/ExtensionScripts.txt"))
	{
		MsgBox,,Script Editor, Select Script Editor Path
		gosub, CambiarRutaEditor
	}
	else
	{
		if(RutaEditorScripts = "")
		{
			FileReadLine,RutaEditorScripts,./conf/ScriptEditorPath.txt,1
		}
		if(ExtensionScripts = "")
		{
			FileReadLine,ExtensionScripts,./conf/ExtensionScripts.txt,1
		}
		RutaScript := "" IdBoton "." ExtensionScripts ""
		if(!FileExist(RutaScript))
		{
			FileAppend,,%RutaScript%
		}
		Run, "%RutaEditorScripts%" "%RutaScript%"
	}
}

CambiarRutaEditor:
; Ruta Editor
FileSelectFile, RutaEditorScripts, ,,,*.exe
if RutaEditorScripts =
	MsgBox, No executable selected!
else
{
	FileDelete, ./conf/ScriptEditorPath.txt
	FileAppend, %RutaEditorScripts%`n, ./conf/ScriptEditorPath.txt
}
; Extension Scripts
InputBox, ExtensionScripts, Button Script EXT, Insert the extension of the Scripts triggered by the buttons`nExamples`: exe`, ahk`, py`.`.`., , 500, 145,,,,,ahk
if ExtensionScripts =
	MsgBox, Couldn't retrieve the extension!
else
{
	FileDelete, ./conf/ExtensionScripts.txt
	FileAppend, %ExtensionScripts%`n, ./conf/ExtensionScripts.txt
}
return

GuiClose:
Exit:
	ExitApp

; HOTKEYS
; *******************************
~Right::
IfWinActive, Nova Macros Client
{
	gosub, RightPage
}
return

~Left::
IfWinActive, Nova Macros Client
{
	gosub, LeftPage
}
return

~^Right::
IfWinActive, Nova Macros Client
{
	gosub, RightPage ; Incremento de 10 en 10
}
return

~^Left::
IfWinActive, Nova Macros Client
{
	gosub, LeftPage ; Decremento de 10 en 10
}
return

EjecutarFuncionBoton(BotonVisual, FicheroEjecutar)
{
	Activacion := "Activar" BotonVisual
	GuiControl, Show, %Activacion%
	try
	{
		Run, %FicheroEjecutar%.%ExtensionScripts%
	}
	;CambiarImagenAlternativaBoton(BotonVisual, FicheroEjecutar)
	feedbackEjecucion.push(Activacion)
	SetTimer, OcultarFeedbackEjecucion, 150
}

OcultarFeedbackEjecucion:
	if(feedbackEjecucion.length() = 1)
	{
		SetTimer, OcultarFeedbackEjecucion, Off
	}
	GuiControl, Hide, % feedbackEjecucion[1]
	feedbackEjecucion.remove(1)
return

CambiarImagenAlternativaBoton(BotonVisual, NumeroBoton)
{ ; Deprecated, los botones no van a tener estados de momento
	BotonPulsar := "Boton" BotonVisual
	if(VariableCambioImagen = 0)
	{
		RutaImagen := "resources\img\" NumeroBoton "Enabled.png"
		if FileExist(RutaImagen)
		{
			GuiControl, Text, %BotonPulsar%, %RutaImagen%
			if(MiniClient)
			{
				GuiControl, MoveDraw, %BotonPulsar%, w49 h49
			}
			else
			{
				GuiControl, MoveDraw, %BotonPulsar%, w130 h130
			}
			VariableCambioImagen := 1
		}
	}
	else
	{
		RutaImagen := "resources\img\" NumeroBoton ".png"
		if FileExist(RutaImagen)
		{
			GuiControl, Text, %BotonPulsar%, %RutaImagen%
			if(MiniClient)
			{
				GuiControl, MoveDraw, %BotonPulsar%, w49 h49
			}
			else
			{
				GuiControl, MoveDraw, %BotonPulsar%, w130 h130
			}
			VariableCambioImagen := 0
		}
	}
	return
}

CreateFolderButton:
	InputBox, nombreCarpetaNueva, Input Folder Name, Input the folder name WITHOUT spaces or weird symbols. Samples: (Programs`,GameFolder`,OBS_Buttons...)
	if(nombreCarpetaNueva != "" && !Instr(nombreCarpetaNueva, A_Space))
	{
		nuevosBotonesCarpetas := "" ; Fila 1: 1|5|25...
		nuevosCarpetasBotones := "" ; Fila 2: OBS|Chrome|Programas...
		i = 1
		while(i <= BotonesCarpetas0)
		{
			BotonIteracion := BotonesCarpetas%i%
			CarpetaBoton := CarpetasBotones%i%
			nuevosBotonesCarpetas := nuevosBotonesCarpetas BotonIteracion "|"
			nuevosCarpetasBotones := nuevosCarpetasBotones CarpetaBoton "|"
			i++
		}
		nuevosBotonesCarpetas := nuevosBotonesCarpetas BotonActivo
		nuevosCarpetasBotones := nuevosCarpetasBotones nombreCarpetaNueva
		FileDelete, conf\FolderButtons.txt
		FileAppend, % nuevosBotonesCarpetas "`n" nuevosCarpetasBotones, conf\FolderButtons.txt
		gosub, CargarBotonesCarpeta
	}
	else
	{
		MsgBox,,Error, Error while creating folder or cancelled.
	}
return

DeleteFolderButton:
	OnMessage(0x44, "OnMsgBox")
	MsgBoxBtn1 = Delete
	MsgBoxBtn2 = Cancel
	MsgBox 0x34, Delete Folder?, If this button is a folder it may contain other buttons, delete it anyway?
	OnMessage(0x44, "")

	IfMsgBox Yes, {
		nuevosBotonesCarpetas := "" ; Fila 1: 1|5|25...
		nuevosCarpetasBotones := "" ; Fila 2: OBS|Chrome|Programas...
		i = 1
		while(i <= BotonesCarpetas0)
		{
			BotonIteracion := BotonesCarpetas%i%
			if(BotonActivo != BotonIteracion)
			{
				CarpetaBoton := CarpetasBotones%i%
				nuevosBotonesCarpetas := nuevosBotonesCarpetas BotonIteracion "|"
				nuevosCarpetasBotones := nuevosCarpetasBotones CarpetaBoton "|"
			}
			i++
		}
		nuevosBotonesCarpetas:=SubStr(nuevosBotonesCarpetas,1,StrLen(nuevosBotonesCarpetas)-1) ; Remove last |
		nuevosCarpetasBotones:=SubStr(nuevosCarpetasBotones,1,StrLen(nuevosCarpetasBotones)-1) ; Remove last |
		FileDelete, conf\FolderButtons.txt
		FileAppend, % nuevosBotonesCarpetas "`n" nuevosCarpetasBotones, conf\FolderButtons.txt
		gosub, CargarBotonesCarpeta
	}else{
		return
	}	
return

DeleteButtonFunction:
	OnMessage(0x44, "OnMsgBox")
	MsgBoxBtn1 = Delete
	MsgBoxBtn2 = Cancel
	MsgBox 0x34, Delete Function?, If this button has a function it will be deleted!
	OnMessage(0x44, "")

	IfMsgBox Yes, {
		FileDelete, %BotonActivo%.ahk
	}
return

CargarBotonesCarpeta:
	;~ Cargar Botones asociados a carpetas
	NumeroLoop := 1
	Loop, read, ./conf/FolderButtons.txt
	{
		StringSplit, LineArray, A_LoopReadLine, %A_Tab%
		if(NumeroLoop == "1")
		{
			BotonesCarpetasRead := LineArray1
		}
		else if(NumeroLoop == "2")
		{
			CarpetasBotonesRead := LineArray1
		}
		NumeroLoop++
	}
	StringSplit, BotonesCarpetas, BotonesCarpetasRead, |,
	StringSplit, CarpetasBotones, CarpetasBotonesRead, |,
	global BotonesCarpetas0
return

OnMsgBox() {
    DetectHiddenWindows, On
    Process, Exist
    If (WinExist("ahk_class #32770 ahk_pid " . ErrorLevel)) {
        ControlSetText Button1, % MsgBoxBtn1
        ControlSetText Button2, % MsgBoxBtn2
        ControlSetText Button3, % MsgBoxBtn3
        ControlSetText Button4, % MsgBoxBtn4
    }
}

AltTab(){
	global
	; Alt tab replacement, faster, less distracting
	if(enviarAltTabAlPulsarBoton)
	{
		list := ""
		WinGet, id, list
		Loop, %id%
		{
			this_ID := id%A_Index%
			IfWinActive, ahk_id %this_ID%
				continue    
			WinGetTitle, title, ahk_id %this_ID%
			If (title = "")
				continue
			If (!IsWindow(WinExist("ahk_id" . this_ID))) 
				continue
			WinActivate, ahk_id %this_ID%, ,2
				break
		}
	}
}

; Check whether the target window is activation target
IsWindow(hWnd){
    WinGet, dwStyle, Style, ahk_id %hWnd%
    if ((dwStyle&0x08000000) || !(dwStyle&0x10000000)) {
        return false
    }
    WinGet, dwExStyle, ExStyle, ahk_id %hWnd%
    if (dwExStyle & 0x00000080) {
        return false
    }
    WinGetClass, szClass, ahk_id %hWnd%
    if (szClass = "TApplication") {
        return false
    }
    return true
}