Opt("TrayAutoPause",0)
Opt("TrayMenuMode",1)
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#include <GUIConstantsEx.au3>
#include <Timers.au3>
#include <Date.au3>
#include <ProgressConstants.au3>

If $CmdLine[0] <> 2 Then
	Msgbox(1,"UptimeMonitor","Argument(s) missing! You must specify the number of hours to wait and the action, (reboot or logoff). as an argument." & @CRLF & "Example: " & @ScriptName & " 24 <reboot/logoff>")
	Exit
EndIf

$maxTime = $CmdLine[1]	;Number of hours to wait specified at command line.
$Stopper = $maxTime	;Number of hours to wait specified at command line.
TrayTip(" " & Int($Stopper) & " hrs before automatic logoff.", " * Logging out and back in will reset the timer." & @CRLF & " * Remember to save your work often!",2,1)
TraySetToolTip(" " & Int($Stopper) & " hrs before automatic logoff." & @CRLF & " * Remember to save your work often!")
Sleep(5000)
TrayTip(" " & Int($Stopper) & " hrs before automatic logoff.","",0)

Do
	$Stopper -= 1
	Sleep(3600000)	;Sleep 1 Hour
	TrayTip(" " & Int($Stopper) & " hrs before automatic logoff.", " * Logging out and back in will reset the timer." & @CRLF & " * Remember to save your work often!",2,1)
	TraySetToolTip(" " & Int($Stopper) & " hrs before automatic logoff." & @CRLF & " * Remember to save your work often!")
	Sleep(5000)
	TrayTip(" " & Int($Stopper) & " hrs before automatic logoff.","",0)

Until $Stopper = 0
TrayTip("This system is going to reboot within 2 minutes.", " * Logging out and back in will reset the timer." & @CRLF & " * Remember to save your work often!",2,1)
TraySetToolTip("This system is going to reboot within 2 minutes." & @CRLF & " * Remember to save your work often!")
Sleep(5000)
TrayTip("This system is going to reboot within 2 minutes.","",0)
Global $iPrompts = 0

While 1
$iPrompts += 1
Global $iCountdown = 120 ; Sets the time-out to 2 minutes in seconds
Global $Task = $CmdLine[2] ;This is the type of task to perform. shutdown or logoff are accepted.
Global $Prompt = "You have been logged into your system for more than " & $maxTime & " hour(s). To improve performance, it is recommended that this system is restarted." & @CRLF & "Your system will restart automatically in "
Global $iTotal_Time = $iCountdown ; Copies the starting time to another variable.


;$Form1 = GUICreate("Restart Required", 415, 145, -1, -1, BitOR($WS_CAPTION, $WS_POPUP, $WS_BORDER, $WS_CLIPSIBLINGS), $WS_EX_WINDOWEDGE) ; Creates GUI Window
$Form1 = GUICreate("Restart Required", 415, 165, -1, -1, $DS_MODALFRAME,BitOR($WS_EX_TOPMOST,$WS_EX_DLGMODALFRAME))
$Progress = GUICtrlCreateProgress(10, 65, 395, 15, $PBS_SMOOTH) ; Creates Progress Bar
GUICtrlSetColor($Progress, 0xff0000) ; Sets Progress Bar Colour
$RestartNow = GUICtrlCreateButton("Restart Now", 235, 112, 80, 23, 0) ; Creates Restart Now Button
$RestartLater = GUICtrlCreateButton("Restart Later", 325, 112, 80, 23, 0) ; Creates Restart Later Button
$Label1 = GUICtrlCreateLabel($Prompt & _SecsToTime($iCountdown) & " minutes.", 10, 10, 405, 55)
$Label2 = GUICtrlCreateLabel("Do you want to restart your system now?", 10, 90, 405, 20)

If $iPrompts > 2 Then
    GUICtrlSetState($RestartLater, $GUI_disable)
EndIf

GUISetState(@SW_SHOW)

_Timer_SetTimer($Form1, 1000, '_Countdown')
While 1
    $nMsg = GUIGetMsg()
    Switch $nMsg
		Case $RestartNow
			If $Task = "reboot" Then
				_Restart(6)
			Else
				_Restart(4)
			EndIf
        Case $RestartLater
			GUISetState(@SW_HIDE)
			Sleep(120000)	;Sleep 2 minutes
			;Sleep(5000)	;Sleep 5 Seconds
			ExitLoop
    EndSwitch
WEnd
WEnd

Func _Countdown($hWnd, $iMsg, $iIDTimer, $dwTime)
    $iCountdown -= 1
    $percent_value = Floor(($iCountdown / $iTotal_Time) * 100)
    $percent_value = 100 - $percent_value
    If $iCountdown > 0 Then
        GUICtrlSetData($Label1, $Prompt & _SecsToTime($iCountdown) & " minutes.")
        GUICtrlSetData($Progress, $percent_value)
    ElseIf $iCountdown = 0 Then
        GUICtrlSetData($Label1, $Prompt & _SecsToTime($iCountdown) & " minutes.")
        GUICtrlSetData($Progress, $percent_value)
        _Timer_KillTimer($hWnd, $iIDTimer)
        ControlClick($Form1, '', $RestartNow) ; Default action when Countdown equals 0
    EndIf
EndFunc  ;==>_Countdown

Func _SecsToTime($iSecs)
    Local $iHours, $iMins, $iSec_s
    _TicksToTime($iSecs*1000,$iHours,$iMins,$iSec_s)
    Return StringFormat("%02i:%02i",$iMins, $iSec_s)
EndFunc

Func _Restart($iType)
	;msgbox(1,"RESTART",$iType)
    Shutdown($iType)  ;Force a logoff or reboot
    Exit
EndFunc

