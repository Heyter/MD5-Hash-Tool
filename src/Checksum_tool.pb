XIncludeFile "UI.pbi"

OpenWindow_0()

UseMD5Fingerprint()

Repeat
    Event = WaitWindowEvent()
    Select EventWindow()
        Case Window_0
            Window_0_Events(Event)
    EndSelect
Until Event = #PB_Event_CloseWindow
; IDE Options = PureBasic 5.60 (Windows - x86)
; CursorPosition = 4
; EnableXP
; Executable = CheckSum_Tool.exe