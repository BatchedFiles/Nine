#include "NetworkParamDialogProc.bi"
#include "Resources.rh"

Function NetworkParamDialogProc(ByVal hwndDlg As HWND, ByVal uMsg As UINT, ByVal wParam As WPARAM, ByVal lParam As LPARAM)As INT_PTR
	
	Select Case uMsg
		
		Case WM_INITDIALOG
			
		Case WM_COMMAND
			
			Select Case LOWORD(wParam)
				
				Case IDOK
					GetDlgItemText(hwndDlg, IDC_EDT_NICK, @Nick, MaxCharsLength)
					GetDlgItemText(hwndDlg, IDC_EDT_SERVER, @Server, MaxCharsLength)
					GetDlgItemText(hwndDlg, IDC_EDT_PORT, @Port, MaxCharsLength)
					GetDlgItemText(hwndDlg, IDC_EDT_CHANNEL, @Channel, MaxCharsLength)
					GetDlgItemText(hwndDlg, IDC_EDT_LOCALADDRESS, @LocalAddress, MaxCharsLength)
					GetDlgItemText(hwndDlg, IDC_EDT_LOCALPORT, @LocalPort, MaxCharsLength)
					EndDialog(hwndDlg, IDOK)
					
				Case IDCANCEL
					EndDialog(hwndDlg, IDCANCEL)
					
			End Select
			
		Case WM_CLOSE
			EndDialog(hwndDlg, 0)
			
		Case Else
			Return False
			
	End Select
	
	Return True
	
End Function
