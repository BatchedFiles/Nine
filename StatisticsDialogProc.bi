#ifndef STATISTICSDIALOGPROC_BI
#define STATISTICSDIALOGPROC_BI

#ifndef unicode
#define unicode
#endif

#include "windows.bi"

Type StatisticParams
	Dim WinsCount As DWORD
	Dim FailsCount As DWORD
End Type

Declare Function StatisticsDialogProc(ByVal hwndDlg As HWND, ByVal uMsg As UINT, ByVal wParam As WPARAM, ByVal lParam As LPARAM)As INT_PTR

#endif
