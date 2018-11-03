﻿;
; This code is automatically generated by the FormDesigner.
; Manual modification is possible to adjust existing commands, but anything else will be dropped when the code is compiled.
; Event procedures needs to be put in another source file.
;

XIncludeFile "functions.pb"

Global Window_0
Global String_0, buttonPush, Button_1, textCopyright
Global pathFind$ = ""


Procedure OpenWindow_0(x = 0, y = 0, width = 310, height = 90)
    Window_0 = OpenWindow(#PB_Any, x, y, width, height, "MD5 Hash Tool", #PB_Window_SystemMenu | #PB_Window_ScreenCentered)
    String_0 = StringGadget(#PB_Any, 10, 10, 250, 25, "")
    buttonPush = ButtonGadget(#PB_Any, 200, 50, 100, 25, "ПУСК")
    Button_1 = ButtonGadget(#PB_Any, 270, 10, 30, 25, "+")
    GadgetToolTip(Button_1, "Выбрать путь до файлов")
    textCopyright = TextGadget(#PB_Any, 10, 70, 78, 15, "Версия: 0.0.0.1")
    SetGadgetColor(textCopyright, #PB_Gadget_FrontColor,RGB(0,128,0))
EndProcedure

Global errorTitle.s = "Ошибка"
Global errorMessage.s = "Укажи путь до файлов"
Global patternRequest.s = "Все файлы (*.*)|*.*"
#fileCr = 137

Procedure Window_0_Events(event)
  Select event
    Case #PB_Event_CloseWindow
      ProcedureReturn #False

    Case #PB_Event_Menu
      Select EventMenu()
      EndSelect

    Case #PB_Event_Gadget
        Select EventGadget()
            Case String_0 ; Вручную указываем путь
                pathFind$ = GetGadgetText(String_0)
            Case Button_1 ; Указываем через поиск
                pathFind$ = MyOpenFileRequester("Указать путь до файлов", Trim(GetCurrentDirectory()), patternRequest, 0)

                If pathFind$ <> ""
                    SetGadgetText(String_0, pathFind$)
                Else
                    MessageRequester(errorTitle, errorMessage, 16 | 0)
                    ProcedureReturn #True
                EndIf
            Case buttonPush ; Нажимаем ПУСК
                pathFind$ = Trim(GetGadgetText(String_0))
                If pathFind$ = ""
                    MessageRequester(errorTitle, errorMessage, 16 | 0)
                    ProcedureReturn #True
                EndIf

                createPack$ = SaveFileRequester("Куда сохранить", appName, patternRequest, 0)
                If pathFind$ And createPack$
                    ClearList(Files$()) ; Очистка массива.
                    Find_File(pathFind$, "") ; Рекурсивный поиск файлов.
                    countFiles.i = ListSize(Files$()) ; Число найденных файлов.

                    If countFiles <> 0 ; Если что-то есть то продолжаем
                        If CreateFile(#fileCr, createPack$, #PB_UTF8)
                            WriteStringN(#fileCr, "/* Кол-во файлов: " + Str(countFiles) + " */")
                            ForEach Files$()
                                WriteStringN(#fileCr, Files$() + ";" + FileFingerprint(pathFind$ + "\" + Files$(), #PB_Cipher_MD5))
                            Next
                            ClearList(Files$())
                            CloseFile(#fileCr)
                        EndIf
                    Else
                        MessageRequester(errorTitle, "В этой папке пусто!", 16 | 0)
                        ProcedureReturn #True
                    EndIf
                    countFiles = 0
                Else
                    MessageRequester(errorTitle, "Не удалось создать файл", 16 | 0)
                EndIf
                
                createPack$ = ""
                pathFind$ = ""
                ProcedureReturn #True
      EndSelect
  EndSelect
  ProcedureReturn #True
EndProcedure
; IDE Options = PureBasic 5.60 (Windows - x86)
; CursorPosition = 54
; FirstLine = 43
; Folding = -
; EnableXP