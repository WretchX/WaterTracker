#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=Media\favicon.ico
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#Region INCLUDES
#include <ButtonConstants.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <GUIListBox.au3>
#include <ProgressConstants.au3>
#include <SliderConstants.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#include <GuiSlider.au3>
#include <MsgBoxConstants.au3>
#include <Date.au3>
#include <DateTimeConstants.au3>
#include <FontConstants.au3>
#include <ColorConstants.au3>
#include <WindowsConstants.au3>
#include <WinAPIFiles.au3>
#include <File.au3>
#include <AutoItConstants.au3>
#include <Misc.au3>
#include <GuiListView.au3>
#include <GuiListBox.au3>
#include <TrayConstants.au3>
#EndRegion INCLUDES

#Region WRAPPER + OPTIONS
TraySetIcon(@ScriptDir & "\media\favicon.ico")
GUISetIcon(@ScriptDir & "\Media\favicon.ico")
Opt("TrayMenuMode", 3) ;hide default paused and exit
Opt("TrayAutoPause", 0)
Opt("TrayIconHide", 0)
TraySetClick(8)
_DateTimeFormat(_NowCalc(), 3)  ;sets DateTimeFormat to short 12-hour
Global $version = "1.1.0"
#EndRegion WRAPPER + OPTIONS

#Region PRE-GUI IINITIALIZATION
;Checks if settings.ini exists. If not, creates it and opens the program once it exists.
If FileExists(@ScriptDir & "\settings.ini") = False Then
	ProgressOn("WaterTracker", "Creating Settings file....", "0%")
	create_ini()
	For $i = 10 To 100 Step 10
		Sleep(200)
		ProgressSet($i, $i & "%")
	Next
	ProgressSet(100, "Done", "Complete")
	Do
		Sleep(100)
	Until FileExists(@ScriptDir & "\settings.ini") = True
	ProgressOff()
Else
	Sleep(10)
EndIf
;redundancy check
If _Singleton(@ScriptName, 1) = 0 Then Exit MsgBox(262144 + 16, "Error!", @ScriptName & " is already running!")
init()
debug(0) ;1 for debug mode on, 0 for off
#EndRegion PRE-GUI IINITIALIZATION

#Region GLOBALS
Global $currentIntake = 0
Global $percent = 0
Global $sStyle = "hh:mm tt"
Global $sound1 = (@ScriptDir & "\Media\Water.wav")
Global $XS_n, $labRemindWarning, $dailyIntake, $logging, $remindsound, $remindpopup, $shorttime, $logtime, $reminder1, $reminder2, $reminder3, $reminder4
Global $reminder5, $reminder6, $reminder7, $reminder8, $reminder9, $reminder10, $debugMode, $iniMinimize, $iniCustom1, $iniCustom2, $iniCustom3
#EndRegion GLOBALS

#Region TRAY
$trayDonate = TrayCreateItem("Donate")
$trayAbout = TrayCreateItem("About")
TrayCreateItem("")
$trayResetPos = TrayCreateMenu("Reset window position")
$trayTopLeft = TrayCreateItem("Top Left", $trayResetPos)
$trayTopRight = TrayCreateItem("Top Right", $trayResetPos)
$trayBottomLeft = TrayCreateItem("Bottom Left", $trayResetPos)
$trayBottomRight = TrayCreateItem("Bottom Right", $trayResetPos)
$trayCenter = TrayCreateItem("Center", $trayResetPos)
TrayCreateItem("")
$trayOptions = TrayCreateItem("Options")
$trayReminders = TrayCreateItem("Reminders")
TrayCreateItem("")
$trayExit = TrayCreateItem("Exit")
TraySetState($TRAY_ICONSTATE_SHOW)
#EndRegion TRAY

#Region GUI
#Region GUI_MAIN
$gui_main = GUICreate("Water Tracker", 324, 278, -1, -1)
XPStyleToggle(1) ;must be toggled in order for $Progress1 to be colored
$Progress1 = GUICtrlCreateProgress(16, 16, 297, 41)
GUICtrlSetBkColor(-1, 0xDBEFFF)
GUICtrlSetColor(-1, 0x65A8FF)
XPStyleToggle(0)
Global $labPercent = GUICtrlCreateLabel($percent & "%", 150, 24, 80, 30, $SS_CENTERIMAGE)
GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
GUICtrlSetFont(-1, 18, 400, $GUI_FONTNORMAL, "", $ClEARTYPE_QUALITY)
$labTotals = GUICtrlCreateLabel($currentIntake & "/" & $dailyIntake & "oz.", 30, 70, 120, 40, $SS_CENTER)
GUICtrlSetFont(-1, 18, 400, $GUI_FONTNORMAL, "", $ClEARTYPE_QUALITY)
$grpQuickAdd = GUICtrlCreateLabel("Quick Add", 34, 145, 60, 20)
GUICtrlSetFont(-1, 9, 500, $GUI_FONTNORMAL, "", $CLEARTYPE_QUALITY)
$inQuickAdd = GUICtrlCreateInput("", 32, 162, 57, 21, BitOR($ES_CENTER, $ES_NUMBER))
GUICtrlSetFont(-1, 9, 500, $GUI_FONTNORMAL, "", $CLEARTYPE_QUALITY)
GUICtrlSetLimit(-1, 3, 0)
$butCustom1 = GUICtrlCreateButton($iniCustom1 & " oz", 20, 108, 45, 28)
GUICtrlSetFont(-1, 9, 500, $GUI_FONTNORMAL, "", $CLEARTYPE_QUALITY)
$butCustom2 = GUICtrlCreateButton($iniCustom2 & " oz.", 72, 108, 45, 28)
GUICtrlSetFont(-1, 9, 500, $GUI_FONTNORMAL, "", $CLEARTYPE_QUALITY)
$butCustom3 = GUICtrlCreateButton($iniCustom3 & " oz.", 125, 108, 45, 28)
GUICtrlSetFont(-1, 9, 500, $GUI_FONTNORMAL, "", $CLEARTYPE_QUALITY)
$labOz = GUICtrlCreateLabel("oz.", 94, 168, 18, 17)
GUICtrlSetFont(-1, 9, 500, $GUI_FONTNORMAL, "", $CLEARTYPE_QUALITY)
$butQuickAdd = GUICtrlCreateButton("Add", 115, 154, 50, 33)
GUICtrlSetFont(-1, 9, 500, $GUI_FONTNORMAL, "", $CLEARTYPE_QUALITY)
$Slider1 = GUICtrlCreateSlider(16, 192, 160, 33, BitOR($TBS_TOOLTIPS, $TBS_AUTOTICKS, $TBS_ENABLESELRANGE))
GUICtrlSetLimit(-1, $dailyIntake, 0) ; control, max, min
GUICtrlCreateGroup("", -99, -99, 1, 1)
If $debugMode = "On" Then
	$debugNotifier = GUICtrlCreateLabel("DEBUG MODE ON", 194, 58, 129, 50)
	GUICtrlSetFont($debugNotifier, 9, 800, "", "", "")
	GUICtrlSetColor($debugNotifier, $COLOR_RED)
EndIf
$List1 = GUICtrlCreateList("", 184, 72, 129, 150)
GUICtrlSetFont(-1, 10, 400, $GUI_FONTNORMAL, "", $ClEARTYPE_QUALITY)
$butReminders = GUICtrlCreateButton("Reminders", 16, 235, 65, 33)
GUICtrlSetFont(-1, 8.5, 500, $GUI_FONTNORMAL, "", $CLEARTYPE_QUALITY)
$butOptions = GUICtrlCreateButton("Options", 88, 235, 65, 33)
GUICtrlSetFont(-1, 8.5, 500, $GUI_FONTNORMAL, "", $CLEARTYPE_QUALITY)
$butReset = GUICtrlCreateButton("Reset", 160, 235, 73, 33)
GUICtrlSetFont(-1, 8.5, 500, $GUI_FONTNORMAL, "", $CLEARTYPE_QUALITY)
$butExit = GUICtrlCreateButton("Exit", 240, 235, 73, 33)
GUICtrlSetFont(-1, 8.5, 500, $GUI_FONTNORMAL, "", $CLEARTYPE_QUALITY)
GUISetIcon(@ScriptDir & "\favicon.ico")
GUISetState(@SW_SHOW)
#EndRegion GUI_MAIN

#Region GUI_OPTIONS
$gui_options = GUICreate("Options", 169, 235, -1, -1)
$labDailyGoal = GUICtrlCreateLabel("Daily Goal", 22, 18, 60, 17)
GUICtrlSetFont(-1, 9, 500, $GUI_FONTNORMAL, "", $CLEARTYPE_QUALITY)
$inDailyGoal = GUICtrlCreateInput($dailyIntake, 84, 16, 40, 21, BitOR($ES_CENTER, $ES_NUMBER))
GUICtrlSetFont(-1, 9, 500, $GUI_FONTNORMAL, "", $CLEARTYPE_QUALITY)
GUICtrlSetLimit(-1, 3, 0)
$labOz2 = GUICtrlCreateLabel("oz.", 128, 18, 18, 17)
GUICtrlSetFont(-1, 9, 500, $GUI_FONTNORMAL, "", $CLEARTYPE_QUALITY)
$checkLogging = GUICtrlCreateCheckbox("Logging Enabled", 26, 45, 115, 25)
GUICtrlSetFont(-1, 9, 500, $GUI_FONTNORMAL, "", $CLEARTYPE_QUALITY)
$labCustom1 = GUICtrlCreateLabel("Custom value 1: ", 15, 110, 100, 30)
GUICtrlSetFont(-1, 9, 500, $GUI_FONTNORMAL, "", $CLEARTYPE_QUALITY)
$labCustomOz1 = GUICtrlCreateLabel("oz.", 142, 111, 15, 20)
GUICtrlSetFont(-1, 9, 500, $GUI_FONTNORMAL, "", $CLEARTYPE_QUALITY)
$inCustom1 =  GUICtrlCreateInput($iniCustom1, 110, 109, 30, 20, BitOR($ES_CENTER, $ES_NUMBER))
GUICtrlSetLimit(-1, 3)
$labCustom2 = GUICtrlCreateLabel("Custom value 2: ", 15, 135, 100, 30)
GUICtrlSetFont(-1, 9, 500, $GUI_FONTNORMAL, "", $CLEARTYPE_QUALITY)
$labCustomOz1 = GUICtrlCreateLabel("oz.", 142, 136, 15, 20)
GUICtrlSetFont(-1, 9, 500, $GUI_FONTNORMAL, "", $CLEARTYPE_QUALITY)
$inCustom2 =  GUICtrlCreateInput($iniCustom2, 110, 134, 30, 20, BitOR($ES_CENTER, $ES_NUMBER))
GUICtrlSetLimit(-1, 3)
$labCustom3 = GUICtrlCreateLabel("Custom value 3: ", 15, 160, 100, 30)
GUICtrlSetFont(-1, 9, 500, $GUI_FONTNORMAL, "", $CLEARTYPE_QUALITY)
$labCustomOz1 = GUICtrlCreateLabel("oz.", 142, 161, 15, 20)
GUICtrlSetFont(-1, 9, 500, $GUI_FONTNORMAL, "", $CLEARTYPE_QUALITY)
$inCustom3 =  GUICtrlCreateInput($iniCustom3, 110, 159, 30, 20, BitOR($ES_CENTER, $ES_NUMBER))
GUICtrlSetLimit(-1, 3)

If $logging = "True" Then ;checks ini
	GUICtrlSetState($checkLogging, $GUI_CHECKED)
Else
	GUICtrlSetState($checkLogging, $GUI_UNCHECKED)
EndIf
$checkMinimize = GUICtrlCreateCheckbox("X minimizes to tray", 22, 75, 125, 25)

If $iniMinimize = "True" Then ;checks ini
	GUICtrlSetState($checkMinimize, $GUI_CHECKED)
Else
	GUICtrlSetState($checkMinimize, $GUI_UNCHECKED)
EndIf

GUICtrlSetFont(-1, 9, 500, $GUI_FONTNORMAL, "", $CLEARTYPE_QUALITY)
$butSave = GUICtrlCreateButton("Save", 26, 190, 114, 35)
GUICtrlSetFont(-1, 9, 500, $GUI_FONTNORMAL, "", $CLEARTYPE_QUALITY)
GUISetIcon(@ScriptDir & "\favicon.ico")
GUISetState(@SW_HIDE)
#EndRegion GUI_OPTIONS

#Region GUI_REMINDERS
$gui_reminders = GUICreate("Reminders", 290, 290, -1, -1)
$listReminders = GUICtrlCreateList("", 8, 8, 200, 250)
GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
GUICtrlSetFont(-1, 16, 400, $GUI_FONTNORMAL, "", $ClEARTYPE_QUALITY)
$butClose2 = GUICtrlCreateButton("Close", 215, 215, 65, 41)
GUICtrlSetFont(-1, 9, 500, $GUI_FONTNORMAL, "", $CLEARTYPE_QUALITY)
$labRemindWarning = GUICtrlCreateLabel("Warning: No notifications selected.", 18, 262, 350, 20)
GUICtrlSetFont(-1, 10, 800, $GUI_FONTNORMAL, "", $CLEARTYPE_QUALITY)
$butNew = GUICtrlCreateButton("New", 215, 8, 65, 41)
GUICtrlSetFont(-1, 9, 800, $GUI_FONTNORMAL, "", $CLEARTYPE_QUALITY)
$butDelete = GUICtrlCreateButton("Delete", 215, 55, 65, 41)
GUICtrlSetFont(-1, 9, 500, $GUI_FONTNORMAL, "", $CLEARTYPE_QUALITY)
$butDeleteAll = GUICtrlCreateButton("Delete" & @CRLF & "all", 215, 102, 65, 41, $BS_MULTILINE)
GUICtrlSetFont(-1, 9, 500, $GUI_FONTNORMAL, "", $CLEARTYPE_QUALITY)
$checkRemindSound = GUICtrlCreateCheckbox("Sound", 220, 160, 105, 17)
GUICtrlSetFont(-1, 9, 500, $GUI_FONTNORMAL, "", $CLEARTYPE_QUALITY)
If $remindsound = "True" Then ;checks ini
	GUICtrlSetState($checkRemindSound, $GUI_CHECKED)
Else
	GUICtrlSetState($checkRemindSound, $GUI_UNCHECKED)
EndIf
$checkRemindPopup = GUICtrlCreateCheckbox("Popup", 220, 185, 105, 17)
GUICtrlSetFont(-1, 9, 500, $GUI_FONTNORMAL, "", $CLEARTYPE_QUALITY)
If $remindpopup = "True" Then ;checks ini
	GUICtrlSetState($checkRemindPopup, $GUI_CHECKED)
Else
	GUICtrlSetState($checkRemindPopup, $GUI_UNCHECKED)
EndIf

If GUICtrlRead($checkRemindPopup) = 4 And GUICtrlRead($checkRemindSound) = 4 Then
	GUICtrlSetState($labRemindWarning, $GUI_SHOW)
Else
	GUICtrlSetState($labRemindWarning, $GUI_HIDE)
EndIf
GUISetIcon(@ScriptDir & "\favicon.ico")
GUISetState(@SW_HIDE)
#EndRegion GUI_REMINDERS

#Region GUI_ADDREMINDER
$gui_addreminder = GUICreate("Add Reminder", 190, 130, -1, -1)
$idDate = GUICtrlCreateDate("", 20, 20, 150, 40, $DTS_TIMEFORMAT) ;culprit
GUICtrlSetFont(-1, 18, 400, "", "", "")
GUICtrlSendMsg($idDate, $DTM_SETFORMATW, 0, $sStyle)
GUICtrlSendMsg($idDate, $DTM_SETFORMATW, 0, $sStyle)
$butAddReminder = GUICtrlCreateButton("Add", 20, 70, 65, 45)
GUICtrlSetFont(-1, 9, 500, $GUI_FONTNORMAL, "", $CLEARTYPE_QUALITY)
$butCancelReminder = GUICtrlCreateButton("Cancel", 105, 70, 65, 45)
GUICtrlSetFont(-1, 9, 500, $GUI_FONTNORMAL, "", $CLEARTYPE_QUALITY)
GUISetIcon(@ScriptDir & "\favicon.ico")
GUISetState(@SW_HIDE)
#EndRegion GUI_ADDREMINDER
#EndRegion GUI

#Region POST-GUI INITIALIZATION
PopulateReminders()
AdlibRegister("ReminderCheck", 60001) ;checks if current time matches alarm time every 60 seconds
$hWndTT = _GUICtrlSlider_GetToolTips($Slider1)
_GUICtrlSlider_SetToolTips($Slider1, $hWndTT)
#EndRegion POST-GUI INITIALIZATION

#Region MAIN LOOP
While 1
	$nMsg = GUIGetMsg()
	Switch $nMsg
		;GUI_MAIN CASES
		Case $butQuickAdd
			$amount = GUICtrlRead($inQuickAdd)
			If $amount > 0 Then
				Add()
				AddListItem()
				Update()
			Else
				MsgBox(0, "Error", "Unable to add 0oz.")
			EndIf
		Case $Slider1
			GUICtrlSetData($inQuickAdd, "", "")
			GUICtrlSetData($inQuickAdd, GUICtrlRead($Slider1), 0)
		Case $butCustom1
			$amount = $iniCustom1
			QuickAdd($iniCustom1)
		Case $butCustom2
			$amount = $iniCustom2
			QuickAdd($iniCustom2)
		Case $butCustom3
			$amount = $iniCustom3
			QuickAdd($iniCustom3)
		Case $butReset
			If MsgBox(3, "Reset Data", "Are you sure you want to reset all data?") = 6 Then Reset() ;if "Yes" clicked
		Case $butOptions
			RelativePosition()
			GUISetState(@SW_SHOW, $gui_options)
			;GUI_OPTIONS CASES
		Case $butSave
			If GUICtrlRead($inDailyGoal) = 0 Then
				GUISetState(@SW_HIDE, $gui_options)
			Else
				ini_write()
				init()
				GUICtrlSetData($labTotals, $currentIntake & "/" & $dailyIntake & "oz.")
				GUICtrlSetLimit($Slider1, $dailyIntake, 0)
				Update()
				GUISetState(@SW_HIDE, $gui_options)
			EndIf
			GUICtrlSetData($butCustom1, $iniCustom1 & " oz.")
			GUICtrlSetData($butCustom2, $iniCustom2 & " oz.")
			GUICtrlSetData($butCustom3, $iniCustom3 & " oz.")
		Case $butReminders
			RelativePosition()
			GUISetState(@SW_SHOW, $gui_reminders)
		Case $checkLogging
			If FileExists(@ScriptDir & "\dailylogs.txt") Then
				Logit()
			Else
				_FileCreate("dailylogs.txt")
			EndIf
			;GUI_REMINDERS CASES
		Case $butNew ;																					work on this
			GetTime()
			RelativePosition()
			GUICtrlSetData($idDate, "")
			GUISetState(@SW_SHOW, $gui_addreminder)
		Case $butDelete
			DeleteReminder()
		Case $butDeleteAll
			GUICtrlSetData($listReminders, "")
		Case $checkRemindPopup
			If GUICtrlRead($checkRemindPopup) = 4 And GUICtrlRead($checkRemindSound) = 4 Then
				GUICtrlSetState($labRemindWarning, $GUI_SHOW)
			Else
				GUICtrlSetState($labRemindWarning, $GUI_HIDE)
			EndIf
		Case $checkRemindSound
			If GUICtrlRead($checkRemindPopup) = 4 And GUICtrlRead($checkRemindSound) = 4 Then
				GUICtrlSetState($labRemindWarning, $GUI_SHOW)
			Else
				GUICtrlSetState($labRemindWarning, $GUI_HIDE)
			EndIf
		Case $butClose2
			ini_write()
			GUISetState(@SW_HIDE, $gui_reminders)
			;GUI_ADDREMINDER CASES
		Case $butAddReminder
			AddReminder()
			GUISetState(@SW_HIDE, $gui_addreminder)
		Case $butCancelReminder
			GUISetState(@SW_HIDE, $gui_addreminder)
			;CLOSE CASES
		Case $GUI_EVENT_CLOSE
			If WinActive("Options") Then
				GUISetState(@SW_HIDE, $gui_options)
			ElseIf WinActive("Reminders") Then
				GUISetState(@SW_HIDE, $gui_reminders)
			ElseIf WinActive("Add Reminder") Then
				GUISetState(@SW_HIDE, $gui_addreminder)
			Else
				If $iniMinimize = "True" Then
					GUISetState(@SW_HIDE, $gui_main)
					$pos = WinGetPos($gui_main)
					ToolTip("WaterTracker minimized to tray." & @CRLF & "Left click tray icon to open.", $pos[0], $pos[1], "", $TIP_BALLOON)
					AdlibRegister("ToolTipTimeOut", 5000)
				Else
					Exit
				EndIf
			EndIf
		Case $butExit
			terminate()
	EndSwitch
	#Region TRAY CASES

	$tMsg = TrayGetMsg()
	Switch $tMsg
		Case $TRAY_EVENT_PRIMARYDOWN ;when tray icon left-clicked, show gui
			GUISetState(@SW_SHOW, $gui_main)
		Case $trayOptions
			GUISetState(@SW_SHOW, $gui_options)
		Case $trayReminders
			GUISetState(@SW_SHOW, $gui_reminders)
		Case $trayTopLeft
			ResetPosition("TopLeft")
		Case $trayTopRight
			ResetPosition("TopRight")
		Case $trayBottomLeft
			ResetPosition("BottomLeft")
		Case $trayBottomRight
			ResetPosition("BottomRight")
		Case $trayCenter
			ResetPosition("Center")
		Case $trayDonate
			Donate()
		Case $trayAbout
			About()
		Case $trayExit
			Exit 1
	EndSwitch
WEnd
#EndRegion TRAY CASES
#EndRegion MAIN LOOP

#Region FUNCTIONS
#Region MAIN FUNCTIONS
Func Add() ;adds what new data entry is added via Quick Add to the already entered intake data
	$currentIntake += $amount
EndFunc   ;==>Add

Func QuickAdd($a)
	$currentIntake += $a
	AddListItemQuick()
	Update()
EndFunc   ;==>QuickAdd

Func UpdatePercentage() ;updates the percentage text overlaying progress bar in GUI_MAIN
	GUICtrlSetData($labPercent, $percent & "%")
EndFunc   ;==>UpdatePercentage

Func AddListItem() ;adds log entry to $GUI_MAIN list, $List1
	GetTime()
	GUICtrlSetData($List1, $shorttime & "      + " & GUICtrlRead($inQuickAdd) & "oz.", "")
EndFunc   ;==>AddListItem

Func AddListItemQuick()
	GetTime()
	GUICtrlSetData($List1, $shorttime & "      + " & $amount & "oz.", "")
EndFunc   ;==>AddListItemQuick

Func Update() ;updates all data. triggered when $butQuickAdd in $GUI_MAIN pressed
	GUICtrlSetData($labTotals, $currentIntake & "/" & $dailyIntake & "oz.")
	$percent = Int(($currentIntake / $dailyIntake) * 100)
	GUICtrlSetData($labPercent, $percent & "%")
	GUICtrlSetData($Progress1, $percent)
	GUICtrlSetData($inQuickAdd, 0)
	GUICtrlSetData($Slider1, 0)
	UpdatePercentage()
EndFunc   ;==>Update

Func GetTime() ;gets the time, and formats it to HH:MMam/pm
	Global $s12time = _NowTime(3) ;12 Hour Time
	$ampm = StringRight($s12time, 2)
	$time = StringTrimRight($s12time, 6)
	;experimentation
	Global $hours = StringFormat("%02i", StringMid($s12time, 1, 2))
	Global $mins = StringFormat("%02i", StringMid($s12time, 3, 2))
	Global $shorttime = $time & StringLower($ampm)
	Global $comparetime = ($time & " " & $ampm)
	Global $longtime = StringFormat("%02i:%02i", $hours, $mins) & " " & $ampm
EndFunc   ;==>GetTime

Func Reset() ;resets functional values when $butReset pressed
	Global $currentIntake = 0
	Global $percent = 0
	GUICtrlSetData($List1, "")
	Update()
EndFunc   ;==>Reset

Func Logit() ;automatically logs daily stats in dailylogs.txt if program is open at $logtime, found in ini
	$todaysdate = _NowDate()
	$day = _DateDayOfWeek(@WDAY)
	$logfile = (@ScriptDir & "\dailylogs.txt")
	$iCount = _GUICtrlListBox_GetCount($List1)
	FileWrite($logfile, "- Daily log for " & $todaysdate & " (" & $day & ")" & @CRLF)
	For $i = 1 To $iCount
		FileWrite($logfile, _GUICtrlListBox_GetText($List1, ($i - 1)) & @CRLF)
	Next
	FileWrite($logfile, "Total hydration: " & $currentIntake & "oz." & @CRLF & "Daily goal: " & $dailyIntake & "oz." & @CRLF & "Percent Goal: " & $percent & "%" & @CRLF)
	FileWrite($logfile, " " & @CRLF & @CRLF)
EndFunc   ;==>Logit

Func ToolTipTimeout()
	ToolTip("")
	AdlibUnRegister("ToolTipTimeout")
EndFunc   ;==>ToolTipTimeout

#EndRegion MAIN FUNCTIONS

#Region REMINDER FUNCTIONS
Func AddReminder()
	Local $reminder = GUICtrlRead($idDate)
	GUICtrlSetData($listReminders, $reminder)
EndFunc   ;==>AddReminder

Func DeleteReminder() ;deletes selected reminder
	$sName = GUICtrlRead($listReminders)
	_GUICtrlListBox_DeleteString($listReminders, _GUICtrlListBox_GetCurSel($listReminders))
EndFunc   ;==>DeleteReminder

Func ReminderCheck() ;runs via adlib. checks every minute if reminder matches up to current machine time.
	GetTime()
	$nCount = _GUICtrlListBox_GetCount($listReminders) ;gets number of list entries. reminder: return val is NOT indexed
	For $n = 0 To $nCount ;loops through available list entries
		If _GUICtrlListBox_GetText($listReminders, ($n)) = $longtime Then Reminder()
	Next
	If $longtime == $logtime Then Logit() ;creates daily log at log time
	If $longtime == "03:00 AM" Then Reset()
EndFunc   ;==>ReminderCheck

Func TestFunc()
	GetTime()
	ConsoleWrite($longtime)
EndFunc   ;==>TestFunc

Func Reminder() ;reminder trigger
	ini_read()
	$remaining = ($dailyIntake - $currentIntake)
	If $remindsound = "True" Then SoundPlay($sound1)
	If $remindpopup = "True" Then MsgBox(0, "Reminder", "Drink Water! You have " & $remaining & "oz. to go today.")
EndFunc   ;==>Reminder

Func PopulateReminders() ;populates $listReminders from ini
	If $reminder1 <> "0" Then GUICtrlSetData($listReminders, $reminder1)
	If $reminder2 <> "0" Then GUICtrlSetData($listReminders, $reminder2)
	If $reminder3 <> "0" Then GUICtrlSetData($listReminders, $reminder3)
	If $reminder4 <> "0" Then GUICtrlSetData($listReminders, $reminder4)
	If $reminder5 <> "0" Then GUICtrlSetData($listReminders, $reminder5)
	If $reminder6 <> "0" Then GUICtrlSetData($listReminders, $reminder6)
	If $reminder7 <> "0" Then GUICtrlSetData($listReminders, $reminder7)
	If $reminder8 <> "0" Then GUICtrlSetData($listReminders, $reminder8)
	If $reminder9 <> "0" Then GUICtrlSetData($listReminders, $reminder9)
	If $reminder10 <> "0" Then GUICtrlSetData($listReminders, $reminder10)
EndFunc   ;==>PopulateReminders
#EndRegion REMINDER FUNCTIONS

#Region WINDOW POSITIONING FUNCTIONS
Func RelativePosition() ;forces new gui windows to open centered relative to position of parent window
	Global $hWnd = WinGetHandle("Water Tracker")
	Global $pos = WinGetPos($hWnd)
	If WinActive($gui_main) = True Then
		WinMove($gui_options, "", $pos[0] + 80, $pos[1] + 80)
		WinMove($gui_reminders, "", $pos[0] + 10, $pos[1] + 10)
	ElseIf WinActive($gui_reminders) = True Then
		Local $hWndReminders = WinGetHandle("Reminders")
		Local $posReminders = WinGetPos($hWndReminders)
		WinMove($gui_addreminder, "", $posReminders[0] + 40, $posReminders[1] + 40)
	Else
		Sleep(10)
	EndIf
EndFunc   ;==>RelativePosition

Func ResetPosition($rPos) ;tray functionality. main gui size = 324, 278
	Local $hWnd = WinGetHandle("Water Tracker")
	Local $pos = WinGetPos($hWnd)
	If $rPos = "TopLeft" Then
		WinMove($gui_main, "", -1, -1)
	ElseIf $rPos = "TopRight" Then
		WinMove($gui_main, "", @DesktopWidth - 350, -1)
	ElseIf $rPos = "BottomLeft" Then
		WinMove($gui_main, "", -1, @DesktopHeight - 340)
	ElseIf $rPos = "BottomRight" Then
		WinMove($gui_main, "", @DesktopWidth - 350, @DesktopHeight - 340)
	ElseIf $rPos = "Center" Then
		WinMove($gui_main, "", @DesktopWidth / 2 - 162, @DesktopHeight / 2 - 139)
	Else
		WinMove($gui_main, "", -1, -1)
	EndIf
EndFunc   ;==>ResetPosition
#EndRegion WINDOW POSITIONING FUNCTIONS

#Region INI FUNCTIONS
Func ini_read() ;reads values from ini
	Global $search = FileFindFirstFile(@ScriptDir & "\settings.ini")
	Global $sFileName = FileFindNextFile($search)
	If $search = -1 Then
		MsgBox($MB_SYSTEMMODAL + $MB_ICONERROR, "Error", "settings.ini not found" & @CRLF & "If you are not running this directly from the program folder, try creating a shortcut instead." & @CRLF & @CRLF & "CODE: 111")
		Exit 111
	EndIf
	Global $dailyIntake = IniRead($sFileName, "settings", "dailyval", "Default")
	Global $logging = IniRead($sFileName, "settings", "logging", "Default")
	Global $iniMinimize = IniRead($sFileName, "settings", "minimize", "Default")
	Global $logtime = IniRead($sFileName, "settings", "dailylogtime", "Default")
	Global $remindsound = IniRead($sFileName, "settings", "remindsound", "Default")
	Global $remindpopup = IniRead($sFileName, "settings", "remindpopup", "Default")
	Global $iniCustom1 = IniRead($sFileName, "settings", "custom1", "Default")
	Global $iniCustom2 = IniRead($sFileName, "settings", "custom2", "Default")
	Global $iniCustom3 = IniRead($sFileName, "settings", "custom3", "Default")
	Global $reminder1 = IniRead($sFileName, "reminders", "reminder1", "Default")
	Global $reminder2 = IniRead($sFileName, "reminders", "reminder2", "Default")
	Global $reminder3 = IniRead($sFileName, "reminders", "reminder3", "Default")
	Global $reminder4 = IniRead($sFileName, "reminders", "reminder4", "Default")
	Global $reminder5 = IniRead($sFileName, "reminders", "reminder5", "Default")
	Global $reminder6 = IniRead($sFileName, "reminders", "reminder6", "Default")
	Global $reminder7 = IniRead($sFileName, "reminders", "reminder7", "Default")
	Global $reminder8 = IniRead($sFileName, "reminders", "reminder8", "Default")
	Global $reminder9 = IniRead($sFileName, "reminders", "reminder9", "Default")
	Global $reminder10 = IniRead($sFileName, "reminders", "reminder10", "Default")
EndFunc   ;==>ini_read

Func ini_write() ;writes values to ini from GUI controls
	IniWrite(@ScriptDir & "\settings.ini", "settings", "dailyval", GUICtrlRead($inDailyGoal))
	If GUICtrlRead($checkLogging) = 1 Then
		IniWrite(@ScriptDir & "\settings.ini", "settings", "logging", "True")
	Else
		IniWrite(@ScriptDir & "\settings.ini", "settings", "logging", "False")
	EndIf
	If GUICtrlRead($checkRemindSound) = 1 Then
		IniWrite(@ScriptDir & "\settings.ini", "settings", "remindsound", "True")
	Else
		IniWrite(@ScriptDir & "\settings.ini", "settings", "remindsound", "False")
	EndIf
	If GUICtrlRead($checkRemindPopup) = 1 Then
		IniWrite(@ScriptDir & "\settings.ini", "settings", "remindpopup", "True")
	Else
		IniWrite(@ScriptDir & "\settings.ini", "settings", "remindpopup", "False")
	EndIf
	If GUICtrlRead($checkMinimize) = 1 Then
		IniWrite(@ScriptDir & "\settings.ini", "settings", "minimize", "True")
	Else
		IniWrite(@ScriptDir & "\settings.ini", "settings", "minimize", "False")
	EndIf
	IniWrite(@ScriptDir & "\settings.ini", "settings", "custom1", GUICtrlRead($inCustom1))
	IniWrite(@ScriptDir & "\settings.ini", "settings", "custom2", GUICtrlRead($inCustom2))
	IniWrite(@ScriptDir & "\settings.ini", "settings", "custom3", GUICtrlRead($inCustom3))
	IniWrite(@ScriptDir & "\settings.ini", "reminders", "reminder1", _GUICtrlListBox_GetText($listReminders, 0))
	IniWrite(@ScriptDir & "\settings.ini", "reminders", "reminder2", _GUICtrlListBox_GetText($listReminders, 1))
	IniWrite(@ScriptDir & "\settings.ini", "reminders", "reminder3", _GUICtrlListBox_GetText($listReminders, 2))
	IniWrite(@ScriptDir & "\settings.ini", "reminders", "reminder4", _GUICtrlListBox_GetText($listReminders, 3))
	IniWrite(@ScriptDir & "\settings.ini", "reminders", "reminder5", _GUICtrlListBox_GetText($listReminders, 4))
	IniWrite(@ScriptDir & "\settings.ini", "reminders", "reminder6", _GUICtrlListBox_GetText($listReminders, 5))
	IniWrite(@ScriptDir & "\settings.ini", "reminders", "reminder7", _GUICtrlListBox_GetText($listReminders, 6))
	IniWrite(@ScriptDir & "\settings.ini", "reminders", "reminder8", _GUICtrlListBox_GetText($listReminders, 7))
	IniWrite(@ScriptDir & "\settings.ini", "reminders", "reminder9", _GUICtrlListBox_GetText($listReminders, 8))
	IniWrite(@ScriptDir & "\settings.ini", "reminders", "reminder10", _GUICtrlListBox_GetText($listReminders, 9))
EndFunc   ;==>ini_write

Func create_ini() ;creates ini file. used on first-time startup or if ini is not detected.
	_FileCreate("settings.ini")
	$testfile = (@ScriptDir & "\settings.ini")
	FileWrite($testfile, "[settings]" & @CRLF)
	FileWrite($testfile, "dailyval=150" & @CRLF)
	FileWrite($testfile, "dailylogtime=02:55 AM" & @CRLF)
	FileWrite($testfile, "logging=False" & @CRLF)
	FileWrite($testfile, "minimize=True" & @CRLF)
	FileWrite($testfile, "remindsound=True" & @CRLF)
	FileWrite($testfile, "remindsound=True" & @CRLF)
	FileWrite($testfile, "custom1=16" & @CRLF)
	FileWrite($testfile, "custom2=20" & @CRLF)
	FileWrite($testfile, "custom3=32" & @CRLF)
	FileWrite($testfile, "[reminders]" & @CRLF)
	FileWrite($testfile, "reminder1=0" & @CRLF)
	FileWrite($testfile, "reminder2=0" & @CRLF)
	FileWrite($testfile, "reminder3=0" & @CRLF)
	FileWrite($testfile, "reminder4=0" & @CRLF)
	FileWrite($testfile, "reminder5=0" & @CRLF)
	FileWrite($testfile, "reminder6=0" & @CRLF)
	FileWrite($testfile, "reminder7=0" & @CRLF)
	FileWrite($testfile, "reminder8=0" & @CRLF)
	FileWrite($testfile, "reminder9=0" & @CRLF)
	FileWrite($testfile, "reminder10=0" & @CRLF)
EndFunc   ;==>create_ini
#EndRegion INI FUNCTIONS

#Region TRAY FUNCTIONS
Func Donate() ;opens 'donate' msgbox, triggered via tray
	If MsgBox($MB_SYSTEMMODAL + $MB_YESNO + $MB_ICONINFORMATION, "Open Browser request", "Click Yes to allow this program to open a URL in your default browser.") = 6 Then
		ShellExecute("https://www.paypal.com/donate?hosted_button_id=LZHSKZXSWD4QA")
	EndIf
EndFunc   ;==>Donate

Func About() ;opens 'about' msgbox, triggered via tray
	MsgBox($MB_SYSTEMMODAL, "About", "WaterTracker version " & $version & @CRLF & @CRLF & _
			"Developed by GfG Design" & @CRLF & _
			"100% free Donationware" & @CRLF & @CRLF & _
			"WretchX on GitHub" & @CRLF & @CRLF & _
			"For custom software requests" & @CRLF & _
			"message WretcH#4128 on Discord" & @CRLF & @CRLF & _
			"For custom graphics art, visit" & @CRLF & _
			"gfgdesign.myportfolio.com")
EndFunc   ;==>About
#EndRegion TRAY FUNCTIONS

#Region OTHER FUNCTIONS
Func XPStyleToggle($OnOff = 1) ;toggles window style, briefly used to apply style to $Progress1 in GUI_MAIN
	If Not StringInStr(@OSType, "WIN32_NT") Then Return 0
	If $OnOff Then
		$XS_n = DllCall("uxtheme.dll", "int", "GetThemeAppProperties")
		DllCall("uxtheme.dll", "none", "SetThemeAppProperties", "int", 0)
		Return 1
	ElseIf IsArray($XS_n) Then
		DllCall("uxtheme.dll", "none", "SetThemeAppProperties", "int", $XS_n[0])
		$XS_n = ""
		Return 1
	EndIf
	Return 0
EndFunc   ;==>XPStyleToggle

Func init() ;initialization function, what the program does first
	ini_read()
	GetTime()
EndFunc   ;==>init

Func terminate()
	Exit 1
EndFunc   ;==>terminate
#EndRegion OTHER FUNCTIONS
#EndRegion FUNCTIONS

#Region TESTING

Func LogTest()
	Logit()
EndFunc   ;==>LogTest

Func OmgUnitTestForTime()
	GetTime()
	ConsoleWrite("val of $idDate is: " & GUICtrlRead($idDate) & @CRLF)
	ConsoleWrite("val of $comparetime is: " & $comparetime & @CRLF)
	ConsoleWrite("val of $longtime is: " & $longtime & @CRLF)
	ConsoleWrite("val of $hours is: " & $hours & @CRLF)
	ConsoleWrite("val of $mins is: " & $mins & @CRLF)
EndFunc   ;==>OmgUnitTestForTime

Func debug($d)
	If $d = 1 Then
		HotKeySet("{HOME}", "terminate")
		HotKeySet("{DEL}", "TestFunc")
		HotKeySet("{INS}", "LogTest")
		Global $debugMode = "On"
	Else
		Sleep(10)
	EndIf
EndFunc   ;==>debug
#EndRegion TESTING
