#include once "MainFormWndProc.bi"
#include once "win\windowsx.bi"
#include once "MainFormEvents.bi"
#include once "Nine.rh"
#include once "MainForm.bi"

Function MainFormWndProc(ByVal hWin As HWND, ByVal wMsg As UINT, ByVal wParam As WPARAM, ByVal lParam As LPARAM) As LRESULT
	Select Case wMsg
		Case WM_CREATE
			MainForm_Load(hWin, wParam, lParam)
			
		Case WM_COMMAND
			Select Case HiWord(wParam)
				Case BN_CLICKED, 1
					Select Case LoWord(wParam)
						Case IDM_GAME_NEW
							MainFormMenuNewGame_Click(hWin, lParam)
							
						Case IDM_GAME_NEW_NETWORK
							MainFormMenuNewNetworkGame_Click(hWin, lParam)
							
						Case IDM_GAME_NEW_AI
							MainFormMenuNewAIGame_Click(hWin, lParam)
							
						Case IDM_FILE_EXIT
							MainFormMenuFileExit_Click(hWin, lParam)
							
						Case IDM_HELP_CONTENTS
							MainFormMenuHelpContents_Click(hWin, lParam)
							
						Case IDM_HELP_ABOUT
							MainFormMenuHelpAbout_Click(hWin, lParam)
							
					End Select
			End Select
			
		Case WM_LBUTTONDOWN
			MainForm_LeftMouseDown(hWin, wParam, lParam)
			
		Case WM_KEYDOWN
			MainForm_KeyDown(hWin, wParam, lParam)
			
		Case WM_TIMER
			Select Case wParam
				Case LeftEnemyDealCardTimerId
					LeftEnemyDealCardTimer_Tick(hWin)
					
				Case PlayerDealCardTimerId
					PlayerDealCardTimer_Tick(hWin)
					
				Case RightEnemyDealCardTimerId
					RightEnemyDealCardTimer_Tick(hWin)
					
				Case BankDealCardTimerId
					BankDealCardTimer_Tick(hWin)
					
			End Select
			
		Case WM_PAINT
			MainForm_Paint(hWin, wParam, lParam)
			
		Case WM_SIZE
			MainForm_ReSize(hWin, wParam, lParam)
			
		Case WM_CLOSE
			MainForm_Close(hWin, wParam, lParam)
			
		Case WM_DESTROY
			MainForm_UnLoad(hWin, wParam, lParam)
			PostQuitMessage(0)
			
		Case PM_NEWGAME
			MainForm_NewGame(hWin, wParam, lParam)
			
		Case PM_NEWSTAGE
			MainForm_NewStage(hWin, wParam, lParam)
			
		Case PM_DEFAULTMONEY
			MainForm_DefaultMoney(hWin, wParam, lParam)
			
		Case PM_DEALMONEY
			MainForm_DealMoney(hWin, wParam, lParam)
			
		Case PM_DEALPACK
			MainForm_DealPack(hWin, wParam, lParam)
			
		Case PM_RENEMYATTACK
			MainForm_RightEnemyAttack(hWin, wParam, lParam)
			
		Case PM_USERATTACK
			MainForm_UserAttack(hWin, wParam, lParam)
			
		Case PM_LENEMYATTACK
			MainForm_LeftEnemyAttack(hWin, wParam, lParam)
			
		Case PM_RENEMYFOOL
			MainForm_RightEnemyFool(hWin)
			
		Case PM_USERFOOL
			MainForm_UserFool(hWin)
			
		Case PM_LENEMYFOOL
			MainForm_LeftEnemyFool(hWin)
			
		Case PM_RENEMYWIN
			MainForm_RightEnemyWin(hWin)
			
		Case PM_USERWIN
			MainForm_UserWin(hWin)
			
		Case PM_LENEMYWIN
			MainForm_LeftEnemyWin(hWin)
			
		Case PM_RENEMYDEALCARD
			MainForm_RightEnemyDealCard(hWin, wParam)
			
		Case PM_USERDEALCARD
			MainForm_UserDealCard(hWin, wParam)
			
		Case PM_LENEMYDEALCARD
			MainForm_LeftEnemyDealCard(hWin, wParam)
			
		Case Else
			Return DefWindowProc(hWin, wMsg, wParam, lParam)
			
	End Select
	
	Return 0
End Function
