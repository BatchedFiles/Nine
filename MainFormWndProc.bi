#ifndef MAINFORMWNDPROC_BI
#define MAINFORMWNDPROC_BI

#ifndef unicode
#define unicode
#endif

#include once "windows.bi"

Declare Function MainFormWndProc(ByVal hWnd As HWND, ByVal wMsg As UINT, ByVal wParam As WPARAM, ByVal lParam As LPARAM) As LRESULT

#endif
