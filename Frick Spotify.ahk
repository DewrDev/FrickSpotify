#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases. 
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#InstallMouseHook
#Include TrayIcon.ahk
#Include klist.ahk

scriptVer=4.1
WriteLog("[SCRIPT] - FRICK SPOTIFY v" scriptVer " has been initialised")
; EXPERIMENTAL!!!!!
; RegRead, vRegRead, HKEY_CURRENT_USER\Control Panel\Desktop\,ForegroundLockTimeout
; ; MsgBox, %vRegRead%
; if(vRegRead != 0){
;     RegWrite, REG_DWORD, HKEY_CURRENT_USER\Control Panel\Desktop\,ForegroundLockTimeout,0 
;     msgbox, written
; }
; !!!!!!!!!!!!!!!!!!!!!

TrayTip , Frickin'!, Frick Spotify be runnin',, 0x10 ;creates Windows Notification "traytip" 
Menu, Tray, Tip, Open Frick Spotify Settings
Menu, Tray, Click, 1

formattime, Year,, yyyy ;
formattime, Date,, dd-MM-%year%
FileCreateDir, %A_appdata%\DewrDev\FrickSpotify
global LogDir:= A_appdata "\DewrDev\FrickSpotify\" Date ".log"
global SpotiPath=
global IniHotKey= 
global FrickBttnOnTop=0
global fkBtn=
global FrkSettings=0
global BtnSettingsOpen=0
global FrkConfirmSettings
global FrickBttnStartup=0
global FrickBttnOnTopBool=0
global FrkBttnOpacityBtn1=0
global FrkBttnOpacityBtn2=0
global FrkBttnOpacityTxt=0
global FrkBttnOpacity=255
global RunMinimised="Min"
global array := ["Spotify", "!f24", "Advertisement"] ; Array of Spotify window names.
global PrevWindow=0
global SpotifyPID=0
global MaximiseCheck=0
global MinimiseCheck=0
global IniHotKey=0
global WinName=0
global ConfigDir:= A_appdata "\DewrDev\FrickSpotify\FrickerSettings.ini"

if FileExist(ConfigDir) {
    WriteLog("[SCRIPT] - Reading configuration file")
    IniRead, SpotiPath, %ConfigDir%, Config, SpotifyPath
    IniRead, IniHotKey, %ConfigDir%, Config, FrickerKeyBind
    IniRead, FrickBttnOnTop, %ConfigDir%, Config, FrickBttnOnTop
    Iniread, FrickBttnStartup, %ConfigDir%, Config, FrickBttnStartup
    IniRead, LaunchStartup, %ConfigDir%, Config, LaunchOnStartup
    IniRead, RunMinimised, %ConfigDir%, Config, RunMinimised

    if !(IniHotKey = "ERROR" OR 0){
        WriteLog("[SCRIPT] - Hotkey found. Binding to key:'" IniHotKey "'" )
        Hotkey, %IniHotKey%, FrickBind, on
    }else IniHotKey=None

    if (FrickBttnOnTop="on")
        FrickBttnOnTopBool:=1
    else FrickBttnOnTopBool:=0

    if (RunMinimised="min") {
    MinimiseCheck=1
    }
    if (RunMinimised="max") {
        MaximiseCheck=1
    }

} else {
    WriteLog("[SCRIPT] - No configuration file found. Will present user with Settings UI.")
    IniHotKey=None
    ShowSettings=1
}

keylist := klist(0,1,1) ;script that generates the keymapper thingieee??

Loop keylist.Length() {
    if IniHotKey = keylist[A_index] ()
    {
        IniHotKey:= keylist[A_Index]
        MsgBox % keylist[A_Index]
    }
    else
        MsgBox % keylist[A_Index]
}

Gui, Add, Tab2,center w440, Keybind |Options |Spotify.exe Location |Fricker Button |About
Gui, add, groupbox, x20 y+20 w410 h50, Select Hotkey
Gui, add, dropdownlist, w170 xp+10 yp+20 vNewKey , %keylist% ||%IniHotKey%||
Gui, add, checkbox, x+10 yp+5 vmod_ctrl, Ctrl
Gui, add, checkbox, x+20 vmod_alt, Alt
Gui, add, checkbox, x+20 vmod_shift, Shift
Gui, add, checkbox, x+20 vmod_win, Win
PageDivider()
Gui, tab, Keybind ; KEYBINDS PAGE
ConfirmBtn()
Gui, tab, Options ; OPTIONS PAGE
Gui, Add, button, vLaunchStartup gCreateStartup, Create Startup file (run on system startup)
PageDivider()
Gui, Add, Radio, vSpotiMin Checked%MinimiseCheck%, Start Spotify Minimised (Spotify doesn't pop-up when fricked)
Gui, Add, Radio, vSpotiMax Checked%MaximiseCheck%, Start Spotify Maximised (Spotify pops up. Can un-focus games temporarily)
ConfirmBtn()
Gui, tab, Spotify.exe Location ; Spotify.exe Location PAGE
Gui, add, groupbox, x10 y+20 w410 h80, Input Spotify folder
Gui, Add, Edit, w200 h50 xp+10 yp+20 vSpotiPath HwndSpotiPathBox, %SpotiPath%
ConfirmBtn()
Gui, tab, Fricker ; FRICKER BUTTON PAGE
Gui, Add, checkbox, vFrickBttnStartup Checked%FrickBttnStartup%, Open up the Fricker Button on Startup?
Gui, Add, checkbox, vFrickBttnOnTop Checked%FrickBttnOnTopBool%, Should the Fricker Button always be on-top?
ConfirmBtn()
Gui, tab, About ; ABOUT PAGE
Gui, Add, Text, y30 x130, Welcome to FRICK SPOTIFY v%scriptVer%!
Gui, Add, Text, y50 x20, Professionally and discreetly fricking ads since 2020
gui, default
ConfirmBtn()

Menu, Tray, Add, Settings, ShowSettings ; Adds Settings button to Tray Icon context menu
Menu, Tray, Add, BIG FRICK BUTTON!!!, FrickButton ; Adds Settings button to Tray Icon context menu
Menu, Tray, Default , Settings ; Sets the Settings button to default for when Tray Icon is clicked on

if (ShowSettings=1){ ; conditions that are checked on Startup
    ShowSettings()
    Gui, Flash 
    }

FindSpotifyPath()

if (FrickBttnStartup=1) {
    FrickButton()
}

; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;                         Show Spotify on Startup
;                          ~~~~~~~~~~~~~~~~~~~~~
; writeLog("[DEVELOPER] - Settings GUI will show on startup.")
; Gui, show,, Frick Spotify
; winwait, Frick Spotify
; WinGetPos, FrickX, FrickY,,, Frick Spotify
; FrickX += 225
; WinMove, Frick Spotify,, FrickX, FrickY,
;                         ~~~~~~~~~~~~~~~~~~~~~
;                         Show Spotify on Startup
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


AutoFricker()

; winWait, Spotify Free,, 
; oIcon := TrayIcon_GetInfo("Spotify.exe")[1]
; TrayIcon_Remove(oIcon.hWnd, oIcon.uID)
return ;end functions that are run on startup

ConfirmBtn(){
    Gui, Add, Button, Default center w100 h25 x175 y150, Confirm
}

PageDivider(){
    Gui, add, text, w420 x20 y+20 0x10 ;creates long line separator thingie
}


ShowSettings(){ ;Opens the Settings box when the Tray Icon is clicked on
Gui, show,, Frick Spotify
return
}

FrickButton() {
    if !WinExist("FrickerButton") {
        Gui, 2:New,,FrickerButton
        Gui, add, button, Default w250 h250 HwndFrkBtn vfkBtn gBtnFRICK, FRICK `n (Hold for Settings)
        ; SETITNGS MENU
        Gui, Add, GroupBox, w0 h0 vFrkSettings hidden, FRICKER BUTTON SETTINGS
        ; Checkboxes
        Gui, add, Checkbox, w0 h0 vFrickBttnStartup hidden Checked%FrickBttnStartup%, Open Button on Startup?
        Gui, add, Checkbox, w0 h0 vFrickBttnOnTop hidden Checked%FrickBttnOnTopBool%, Button always ontop?
        ; Opacity Buttons!!!!!!
        Gui, Add, Button, w0 h0 vFrkBttnOpacityBtn1 hidden gFrkBttnOpacityDwn , <
        Gui, Add, Text, w0 h0 vFrkBttnOpacityTxt HwndOpacityTxt hidden, Button Opacity
        Gui, Add, Button, w0 h0 vFrkBttnOpacityBtn2 hidden gFrkBttnOpacityUp , >
        ; Confirm button
        Gui, Add, Button, w0 h0 hidden gFrkSaveSetting vFrkConfirmSettings, Confirm

        Gui, show
        WinSet, AlwaysOnTop, %FrickBttnOnTop%, FrickerButton
        ; WinWaitActive, FrickerButton
        FrickBttnHold()
        } else {
            ; WinActivate, FrickerButton
            ; FrickBttnHold()
    }
}

FrkBttnOpacityDwn:
    FrkBttnOpacity:= FrkBttnOpacity-25
    WinSet, Transparent, %FrkBttnOpacity% , FrickerButton
    ControlSetText, Button Opacity, Button Opacity: `n          %FrkBttnOpacity%
return
FrkBttnOpacityUp:
    FrkBttnOpacity:= FrkBttnOpacity+25
    WinSet, Transparent, %FrkBttnOpacity% , FrickerButton
    ControlSetText, Button Opacity, Button Opacity: `n          %FrkBttnOpacity%

return

GuiClose:
Gui, Cancel
return

FrickBttnHold() {
    Thread, Priority,, Low
    loop {
        WinWaitActive, FrickerButton
            Hotkey, ~LButton, MBtnHeld, on
            Hotkey, ~RButton, MBtnHeld, on
            WinSet, Transparent, 255 , FrickerButton
        WinWaitNOTActive, FrickerButton
            WinSet, Transparent, %FrkBttnOpacity% , FrickerButton
            Hotkey, ~LButton, MBtnHeld, off 
            Hotkey, ~RButton, MBtnHeld, off
    }
}

BtnFRICK:
FrickSpotify()
return

MBtnHeld:
if WinActive("FrickerButton") {
    MouseGetPos,,,,HoverControl
    If (HoverControl="Button1") {
        Start:=A_TickCount ;Every click down resets start time
        while A_TickCount-Start <= 150 {
            Ticks:= A_TickCount - Start
            GetKeyState, LButtonHeld, LButton
            GetKeyState, RButtonHeld, RButton
            if (LButtonHeld!="U" OR RButtonHeld!="U"){
            }
        }
        ; GetKeyState, LButtonHeld, LButton 
        if (LButtonHeld="D" OR RButtonHeld="D") {
            FrickBttnSettings()
        }
    }
    return
}

FrickBttnSettings() {
    if (BtnSettingsOpen=0){
        ShowFrkBtn=hide
        ShowFrkSettings=show
        BtnSettingsOpen=1
        GuiControl, 2:move, fkBtn, w0 h0  y-0 x-0 ys
    }else {
        ShowFrkBtn=show
        ShowFrkSettings=hide
        BtnSettingsOpen=0
        GuiControl, 2:move, fkBtn, w250 h250 y5 x10
        GuiControl, 2:moveDraw, FrkSettings, w0 h0 ys
        GuiControl, 2:moveDraw, FrkConfirmSettings, w0 h0 ys
    }
    GuiControl, 2:%ShowFrkBtn%,  fkBtn
    
    GuiControl, 2:%ShowFrkSettings%, FrkSettings
    GuiControl, 2:%ShowFrkSettings%, FrkConfirmSettings
    GuiControl, 2:%ShowFrkSettings%, FrickBttnOnTop
    GuiControl, 2:%ShowFrkSettings%, FrickBttnStartup
    GuiControl, 2:%ShowFrkSettings%, FrkBttnOpacityBtn1
    GuiControl, 2:%ShowFrkSettings%, FrkBttnOpacityBtn2
    GuiControl, 2:%ShowFrkSettings%, FrkBttnOpacityTxt

    GuiControl, 2:moveDraw, FrkSettings, w250 h250 ys ;Big box thing that surrounds the thingies
;   Checkboxes n' stuff?
    GuiControl, 2:moveDraw, FrickBttnStartup, w150 h20 y25 x25
    GuiControl, 2:moveDraw, FrickBttnOnTop, w150 h20 y50 x25
;   Opacity Buttons
    GuiControl, 2:moveDraw, FrkBttnOpacityBtn1, w40 h40 y85 x25
    GuiControl, 2:moveDraw, FrkBttnOpacityBtn2, w40 h40 y85 x210
    GuiControl, 2:moveDraw, FrkBttnOpacityTxt, w150 h35 y95 x100

;   Confirm button
    GuiControl, 2:moveDraw, FrkConfirmSettings, w250 h20 y250
     
return
}

FrkSaveSetting:
Gui, Submit, nohide
WinSet, AlwaysOnTop, %FrickBttnOnTop%, FrickerButton

IniWrite, %FrickBttnStartup%, %ConfigDir%, Config, FrickBttnStartup

FrickBttnSettings()
return

SpotiMax:
RunMinimised="max"
return
SpotiMin:
RunMinimised="min"
return

CreateStartup:
        FileCreateShortcut, %A_ScriptFullPath%, %A_Startup%\FrickSpotify.lnk, %A_Scriptdir%,,Frick Spotify,,,
        ; RegWrite, REG_SZ, HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Run,Frick Spotify, "%A_ScriptFullPath%"
        ; RegWrite, REG_SZ, HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\%A_ScriptName%,Path,%A_ScriptDir%
return

ButtonConfirm:
    Gui, Submit, nohide
    if (OldKey=0) {
        Hotkey, %OldKey%, FrickSpotify, off
    }
    Hotkey, ~%NewKey%, FrickSpotify, on
    OldKey=%NewKey%
    ; mod_ctrl
    ; mod_alt
    ; mod_shift
    ; mod_win
    if (FrickBttnOnTop=1)
        FrickBttnOnTop:="on"
    else FrickBttnOnTop:="off"

    if (SpotiMax = 1){
        RunMinimised:="max"
    }else {
        RunMinimised:="min"
    }

    WinSet, AlwaysOnTop, %FrickBttnOnTop%, FrickerButton
    FileCreateDir, %A_appdata%\DewrDev\FrickSpotify

    IniWrite, %NewKey%, %ConfigDir%, Config, FrickerKeyBind
    IniWrite, %SpotiPath%, %ConfigDir%, Config, SpotifyPath

    IniWrite, %FrickBttnStartup%,%ConfigDir%, Config, FrickBttnStartup
    IniWrite, %FrickBttnOnTop%,%ConfigDir%, Config, FrickBttnOnTop

    IniWrite, %LaunchStartup%, %ConfigDir%, Config, LaunchOnStartup
    IniWrite, %RunMinimised%, %ConfigDir%, Config, RunMinimised


return

TglHtky(){ ;Function to toggle hotkey on/off function - cant always have these listening for no reason
    Hotkey, ~!F4 , breakloop, Toggle]
    Hotkey, ~!TAB , breakloop, Toggle]
    Hotkey, ~!LButton , breakloopCLICK, on]
    return
}

breakloop: ;function called by the hotkeys ALT-F4 and ALT-TAB. 
    b=1 ;Designed to CANCEL the re-focus loop, as this runs for 1 second and constantly attempts to keep that 1 window focused. 
    TglHtky() ;If you ALT-TAB etc. it'll stop re-focusing
return

breakloopCLICK: 
WinGetActiveTitle, Active
if (Active != PrevWindow) {
    b=1
    TglHtky()
}
return

FindSpotifyPath() {
    ; PotentialPaths:= array(%A_appdata%\Spotify"",A_ProgramFiles"\WindowsApps\SpotifyAB")
    RegRead, eoeoeo, HKEY_CURRENT_USER\SOFTWARE\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppModel\Repository\Packages\
    
    ; msgbox, %eoeoeo%
        Thread, Priority, Critical
        if (StrLen(SpotiPath)=0 OR FileExist(SpotiPath)=A) {
        WriteLog("[SCRIPT\Setup] - Spotify path is unknown.")
            While(Errorlevel=0) {
                Process, Exist , Spotify.exe
                ; msgbox, %ErrorLevel%
                ; MsgBox SpotifyPID: %ErrorLevel%
                sleep, 5000
            }
            ; Process, Exist , Spotify.exe
            ; MsgBox SpotifyPID: %ErrorLevel%
            WinGetTitle, Title, ahk_pid %ErrorLevel%
            Winget, SpotiPath , ProcessPath, ahk_pid %ErrorLevel%
            IniWrite, %SpotiPath%, %ConfigDir%, Config, SpotifyPath
            ControlSetText, Edit1, %Spotipath%, Frick Spotify

            } if (InStr(SpotiPath, "C:\Program Files\WindowsApps") = 1) {
                WriteLog("[SCRIPT\Setup] - Windowsapps installation found")
                FileCopy, %SpotiPath%, %A_Scriptdir%
                WriteLog("[SCRIPT\Setup] - Spotify.exe copy made at " A_ScriptDir "\Spotify.exe")
                Spotipath=%A_ScriptDir%\Spotify.exe
                IniWrite, %SpotiPath%, %ConfigDir%, Config, SpotifyPath
                ControlSetText, Edit1, %Spotipath%, Frick Spotify
                ; MsgBox %Spotipath%
            }
    return
}

FrickBind() {
    WriteLog("[HOTKEY] - Button Pressed. Timer started.")
    start:=A_TickCount
        loop {
            BindHeld := GetKeyState(IniHotKey,p)
            Ticks:=A_TickCount - start
            Seconds = % ticks / 1000
            if (BindHeld = 0 AND Ticks < 250) {
                    WriteLog("[HOTKEY] - Button released. Held for=" Ticks "ms, sending play/pause command")
                    send, {Media_Play_Pause}
                    ; run, %SpotiPath%,, Hide, SpotifyPID ;Open Spotfiy
                    return                
                Ticks:=A_TickCount - start
            }else if (BindHeld = 1 AND Ticks >= 250){
                WriteLog("[HOTKEY] - Hotkey held for=" Ticks "ms, FRICKING!")
                FrickSpotify()
                return
            }
        }
}

WriteLog(LogText){
    formattime, TimeNow,, HH:mm:ss:%A_msec% ;
    FileAppend,`n[%TimeNow%] - %LogText%, %LogDir%
}

GetTitle(){
    WinGetTitle, WinName, ahk_exeSpotify.exe,
    if (WinName = ""){
        writelog("Spotify NOT minimised")
        WinGetTitle, WinName, ahk_exeSpotify.exe, Chrome Legacy Window
    }
}

FrickSpotify(Autofricking=0) { ;run the FRICKER!!!
    WriteLog("[FRICKER] - Frick Script triggered")
    WinGetActiveTitle, PrevWindow
    Thread, Priority, Critical, on
    SetTitleMatchMode, 2

    GetTitle()
    WriteLog("[FRICKER] - WinGetTitle: '" WinName "'")
        WinClose, %WinName%
        ; if (WinName="" AND OR Process, Exist , Spotify.exe) { ;if Spotify name is not recognised, just kill it
        ; }
        if (errorlevel!=0){
            WriteLog("[FRICKER] - Couldn't close Spotify gracefully - force killing.")
            process, close, Spotify.exe
        }

        process, WaitClose, Spotify.exe ;Wait for Spotify to not exist
        sleep, 250
        run, %A_Scriptdir%\Spotify.lnk,, Hide , SpotifyPID ;Open Spotfiy
        WriteLog("[FRICKER] - Attempting to run Spotify using following path: '" Spotipath "'")
        ; run, "%SpotiPath%" --autostart --minimized,, Hide --autostart, SpotifyPID ;Open Spotfiy
        ; SpotifyPID=%ErrorLevel%
        ; MsgBox %Errorlevel%
        if (ErrorLevel!=0) {
            WriteLog("[ERROR] - Spotify EXE path unavailable.")
            ; MsgBox "Checking Spotify path!!!""
            FindSpotifyPath()
            ; sleep, 250 ////////////////////////////////////////////////////////
            ; run, "%SpotiPath%" --autostart --minimized,, Hide --autostart, SpotifyPID ;Open Spotfiy
            ; SpotifyPID=%ErrorLevel%
        } 
        ; WinWait, ahk_exeSpotify.exe
            ; Winset, AlwaysOnTop,On, %PrevWindow%

            ; loop {
            ;     if WinExist("Spotify Free") {
            ;         WinGetActiveTitle, eoaa
            ;         WriteLog("[FRICKER] - Active window is: '" eoaa "'")
            ;         sleep, 100
            ;         break
            ;     }else
            ;     ControlFocus,,%PrevWindow% 
            ; }
            
        WinWait, Spotify Free
        WinActivate, %PrevWindow%
        WinGetActiveTitle, eoaa
        WriteLog("[FRICKER] - Active window (post-frick) is: '" eoaa "'")
        PostMessage, 0x0006,1,,, %WinName% ;sends *temporary* focus to Spotify window
        PostMessage, 0x100,0x20,,, %WinName% ;sends spacebar input to Spotify window
        PostMessage, 0x0006,1,,, %PrevWindow% ;sends focus to the previous window
        WinMinimize, %WinName%
            ; Winset, AlwaysOnTop,Off, %PrevWindow%
            ; ControlFocus,ahk_parent,%PrevWindow%
        oIcon := TrayIcon_GetInfo("Spotify.exe")[1] ;remove tray icon
        TrayIcon_Remove(oIcon.hWnd, oIcon.uID)
        sleep, 500
        WriteLog("[FRICKER] - Attempting to send play/pause...")
        DoTheThing()
            ; PostMessage, 0x0006,1,,, %title%
            ; winset, Bottom,, %Title%
            ; PostMessage, 0x100,0x20,,, %title%
        tries:=1
        Loop, 4 {
            sleep, 500
            tries++
            WriteLog("[FRICKER] - Play Attempt (" tries ")")
            WinGetTitle, Playing, ahk_exeSpotify.exe
            WriteLog("[FRICKER] - Spotify Window Title is currently: '" Playing "'")
            if (Playing = "Spotify Free"){
                send, {Media_Play_Pause} ;Play and go to next track
                if (tries = 4 AND playing = "Spotify Free"){
                    WriteLog("[FRICKER Error] - Script has been unable to resume Spotify playback.")
                    TrayTip, Frick Spotify Error, Script has been unable to resume Spotify playback. `n Please ensure that no other media players (e.g. YouTube) are open. ,, 2 ;creates Windows Notification "traytip" 
                }
            }else {
                break
            }
        }
        ; send, {Media_Next} ; maybe not needed
        x=0 ;setting some base variables cos my coding knowledge is basic so this is how my loops function.
        b=0
        if (RunMinimised = "Max") {
            WriteLog("[FRICKER] - Attempting to re-focus previous window:'" PrevWindow "'")
            ; WinGetActiveTitle, PrevWindow ; Get current window
            TglHtky()
            while (x != 10){ ;while variable "x" is NOT 10, do:
                if (b = 1) { ;check to see if the ALT-TAB binding thing has been run (to cancel the loop)
                    break ;if ALT-TAB thing is run, cancel the loop and continue the rest of the script.
                    }
                else { ;if no ALT-TAB thing has happened, do this stuffs
                    WinActivate, %PrevWindow% ;Attempt to re-focus the previously focused window
                    Sleep, 100 ;wait for 100ms (loops 10 times, so a total of 1s worth of re-focusing efforts.)
                    x:= ++x ;increment variable "x" by 1 once all the other stuff is done. Loops from here.
                    }
                }
                
            }
        ; if(Autofricking=1){
        ;     writelog("[FRICKER] - This frick was triggered by the Autofricker.")
        ;     ; while (s<=120000){

        ;     ; }
        ; }

        Thread, Priority, Critical, on
        SetTitleMatchMode, 3
        Hotkey, %IniHotKey%, FrickBind, on
        ; autofricker()
    }

AutoFricker(){
    Thread, Priority, Critical, on
    AutoFrickerInterval=1000
    SetTitleMatchMode, 3
    ; MsgBox Autofricking!!
    AutoFricker=1
    WriteLog("[AUTOFRICKER] - Checking for Ads every " AutoFrickerInterval "ms")
    while (AutoFricker=1) {
        Loop % array.Length() { ;runs through an array of known Spotify window names and closes any it finds.
        ; WriteLog("[AUTOFRICKER] - Spotify window name is currently: '" )
            if WinExist(Array[A_Index]) { ;if the current Array item (window name) exists..
                ; WinGet, WinName , ProcessName, % Array[A_Index] 
                if (Array[A_index] = "Advertisement" OR Array[A_index] = "Spotify") {
                    WinGet, wowie, PID, % Array[A_index]
                    ; MsgBox %wowie%
                    ; MsgBox % Array[A_index]
                    ; SoundPlay, C:\Windows\Media\Windows Critical Stop.wav
                    WriteLog("[AUTOFRICKER] - Window detected:'" Array[A_index] "'")
                    FrickSpotify(1)
                    Thread, Priority, Critical, off
                    sleep 120000
                }
            }
        }
        sleep %AutoFrickerInterval%
    }
}

DoTheThing(){
    ; msgbox, %title%
    GetTitle()
    writelog(title)
    sendmessage, 0x0006,1,,, %title%
    ; winset, Bottom,, %Title%
    ; sendmessage, 0x100,0x20,,, %title%
    ControlSend, Chrome Legacy Window, {Space}, %title%
    title2:=title
    getTitle()
    if (title2=title){
        writelog("Doing the thing has  NOT worked!!!")
        ; send, {Media_Play_Pause}
    }else {
        writelog("Spotify title has been updated.")
    }
}


; ~XButton2:: 
; FrickBttnSettings()
; return

~^!r::
if !(A_IsCompiled = 1){
    WriteLog("[SYSTEM] - Reloading Script")
    reload
}
