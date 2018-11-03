#CDN_INITDONE = #CDN_FIRST - 0 
#CDN_SELCHANGE = #CDN_FIRST - 1 
#CDN_FOLDERCHANGE = #CDN_FIRST - 2 
Procedure OF_HookFunc(hDlg, msg, wParam, lParam) 
  Select msg 
    Case #WM_NOTIFY 
      *pNMHDR.NMHDR = lParam 
      Select *pNMHDR\code 
        Case #CDN_FOLDERCHANGE 
          ;...Change text in Static control
          SendMessage_(*pNMHDR\hwndFrom, #CDM_SETCONTROLTEXT, 1090, "Folder Name") 
          path$ = Space(#MAX_PATH)
          ;...Get current selected folder
          SendMessage_(*pNMHDR\hwndFrom, #CDM_GETFOLDERPATH, #MAX_PATH, @path$)
          ;...Change text in Edit control to current folder name
          SendMessage_(*pNMHDR\hwndFrom, #CDM_SETCONTROLTEXT, 1152, path$) 
      EndSelect 
  EndSelect 
  ProcedureReturn 0 
EndProcedure 

Procedure.s MyOpenFileRequester(title$, defaultDir$, pattern$, patternPosition) 
  Shared *selectedFile 
  ;...For filter to function properly, we need 
  ;...to replace | with null Chr(0) directly in memory 
  ;...Filter must end with 2 null chars 
  pattern$ + "||" 
  l = Len(pattern$) 
  For n = 0 To l - 1 
    If PeekB(@pattern$ + n) = Asc("|") 
      PokeB(@pattern$ + n, $0) 
    EndIf 
  Next n 
  ;...Buffer to hold selected folder name(s) 
  buffSize = #MAX_PATH 
  If *selectedFolder = 0 
    *selectedFolder = AllocateMemory(buffSize) 
  Else 
    ;...First byte must be null if no initial folder name is to be displayed 
    PokeB(*selectedFolder, $0) 
  EndIf 
  ;...Fill in our OPENFILENAME structure 
  myOpenDlg.OPENFILENAME 
  myOpenDlg\hwndOwner = WindowID(GetActiveWindow()) 
  myOpenDlg\lStructSize = SizeOf(OPENFILENAME) 
  myOpenDlg\hInstance = #Null 
  myOpenDlg\lpstrFilter = @pattern$ 
  myOpenDlg\lpstrCustomFilter = #Null 
  myOpenDlg\nMaxCustFilter = #Null 
  myOpenDlg\nFilterIndex = patternPosition 
  myOpenDlg\lpstrFile = *selectedFolder 
  myOpenDlg\nMaxFile = buffSize 
  myOpenDlg\lpstrFileTitle = #Null 
  myOpenDlg\nMaxFileTitle = #Null 
  myOpenDlg\lpstrInitialDir= @defaultDir$ 
  myOpenDlg\lpstrTitle = @title$ 
  myOpenDlg\flags = #OFN_EXPLORER | #OFN_ENABLEHOOK | #OFN_NOVALIDATE
  myOpenDlg\lpfnHook=@OF_HookFunc() 
  ;...Open the FileRequester 
  GetOpenFileName_(@myOpenDlg) 
  folderReturn$ = PeekS(*selectedFolder) 
  ProcedureReturn folderReturn$ 
EndProcedure 

Procedure.i FileExists (FileName$)
  Define FileAttributes

  CompilerSelect #PB_Compiler_OS

    CompilerCase #PB_OS_Windows
      If GetFileAttributes (FileName$) & #FILE_ATTRIBUTE_DIRECTORY = #False
        ProcedureReturn #True
      EndIf

    CompilerCase #PB_OS_Linux
      If FileSize (FileName$) > -1
        ProcedureReturn #True
      EndIf

    CompilerCase #PB_OS_MacOS
      If FileSize (FileName$) > -1
        ProcedureReturn #True
      EndIf

  CompilerEndSelect

EndProcedure

; http://pure-basic.narod.ru/article/sfx/sfx_zip.html
Global NewList Files$()
Procedure Find_File(Path.s, Sub.s)

  If Right(Path.s,1)<>"\":Path + "\":EndIf    ; Начало сканирования папки.
  Directory = ExamineDirectory(#PB_Any, Path, "*.*")
  If Directory
    While NextDirectoryEntry(Directory) ; Следующий файл / папка.

      Type.l = DirectoryEntryType(Directory) ; Тип объекта (файл или папка).
      Name.s = DirectoryEntryName(Directory) ; Имя объекта.

      If Type = #PB_DirectoryEntry_File ; Найден файл.
        AddElement( Files$() )           ; Добавления элемента в список.
        Files$() = Sub + Name            ; Запись в список имени файла.
      ElseIf Type = #PB_DirectoryEntry_Directory ; Найдена папка.
        If Name <> "." And Name <> ".." ; Не текущая и не родительская папка.
          ; Рекурсивный вызов процедуры.
          Find_File(Path + Name, Sub + Name + "\")
        EndIf
      EndIf

    Wend
    FinishDirectory(Directory) ; Завершение сканирования папки.
  EndIf

EndProcedure

Global appName.s = GetPathPart(ProgramFilename()) + "" + GetFilePart(ProgramFilename(), #PB_FileSystem_NoExtension) + ".txt"

; IDE Options = PureBasic 5.60 (Windows - x86)
; CursorPosition = 116
; FirstLine = 85
; Folding = -
; EnableXP