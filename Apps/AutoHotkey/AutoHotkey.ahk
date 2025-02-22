#Requires AutoHotkey v2.0
#NoTrayIcon
;#WinActivateForce

;
; References:
; https://learn.microsoft.com/en-us/windows/win32/inputdev/wm-appcommand
;

;
; Built-in shortcuts:
;   Win + Up: Maximize window
;   Win + Down: De-maximize window, if more than once - minimize
;   Win + Left, Win + Right: Split Screen
;

; Reload AutoHotkey
; Ctrl + Win + A
^#a:: {
  result := MsgBox("Do you want to reload autohotkey script?",, "YesNo")
  if result = "Yes" {
    Reload
  }

  return
}

; Minimize active window
; Win + Alt  + Down
#!Down:: {
  WinMinimize "A"
}

; taskmgr
; Ctrl + Shift + ~
; Fix for FC660 keyboard
^+~:: {
  Run "taskmgr"
}

; Open "Everything" browser
; Win + Alt + S
#!s:: {
  Run "everything"
}

; Media Keys
; https://gist.github.com/mistic100/d3c0c1eb63fb7e4ee545
^!Space:: Send "{Media_Play_Pause}" ; Ctrl + Alt + Space
^!Left::  Send "{Media_Prev}"       ; Ctrl + Alt + Left
^!Right:: Send "{Media_Next}"       ; Ctrl + Alt + Right
;^!0::     Send "{Volume_Mute}"      ; Ctrl + Alt + 0
;^!-::     Send "{Volume_Down}"      ; Ctrl + Alt + -
;^!=::     Send "{Volume_Up}"        ; Ctrl + Alt + =

;
; Windows Terminal Built-in shortcuts:
;   Alt + Enter: Fullscreen mode
;

; Open terminal
; Ctrl + Alt + T
^!t:: {
  Run "wt"
}

; Open terminal with elevated permissions
; Ctrl + Shift + Alt + T
^+!t:: {
  try {
    Run "*RunAs wt"
  }
  catch error {
    ; do nothing
  }
}
