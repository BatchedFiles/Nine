#ifndef ABOUTDIALOGPROC_BI
#define ABOUTDIALOGPROC_BI

#ifndef unicode
#define unicode
#endif

#include once "windows.bi"

Declare Function AboutDialogProc(ByVal hwndDlg As HWND, ByVal uMsg As UINT, ByVal wParam As WPARAM, ByVal lParam As LPARAM)As INT_PTR

#endif
