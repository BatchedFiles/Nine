#ifndef NETWORKPARAMDIALOGPROC_BI
#define NETWORKPARAMDIALOGPROC_BI

#ifndef unicode
#define unicode
#endif

#include once "windows.bi"

' Сетевые настройки
Const MaxCharsLength As Integer = 255
Dim Shared Nick As WString * (MaxCharsLength + 1)
Dim Shared Server As WString * (MaxCharsLength + 1)
Dim Shared Port As WString * (MaxCharsLength + 1)
Dim Shared Channel As WString * (MaxCharsLength + 1)
Dim Shared LocalAddress As WString * (MaxCharsLength + 1)
Dim Shared LocalPort As WString * (MaxCharsLength + 1)

Declare Function NetworkParamDialogProc(ByVal hwndDlg As HWND, ByVal uMsg As UINT, ByVal wParam As WPARAM, ByVal lParam As LPARAM)As INT_PTR

#endif
