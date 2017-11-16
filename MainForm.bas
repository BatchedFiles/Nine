#include once "MainForm.bi"

#include once "Cards.bi"
#include once "MainFormEvents.bi"
#include once "PlayerCard.bi"
#include once "Nine.rh"
#include once "IntegerToWString.bi"
#include once "crt.bi"
#include once "ThreadProc.bi"
#include once "Irc.bi"
#include once "IrcEvents.bi"
#include once "IrcReplies.bi"
#include once "NetworkParamDialogProc.bi"
#include once "AboutDialogProc.bi"

' Режим игры
Enum GameMode
	' Игра остановлена
	Stopped
	' Игра с самим собой
	Normal
	' Игра с компьютером
	AI
	' Игра по сети
	Network
End Enum

' Тёмно‐зелёный цвет
Const DarkGreenColor As Integer = &h006400

' Начальные сумы денег у игроков
Const DefaultMoney As Integer = 20
' Количество денег, которое кладётся в банк в начале игры
Const ZZZMoney As Integer = 2
' Количество денег, которое кладётся в банк если у игрока нет карт для хода
Const FFFMoney As Integer = 1

' Количество частей в траектории анимации карты
Const DealCardAnimationPartsCount As Integer = 32
' Количество миллисекунд таймера
Const TimerElapsedTime As Integer = 25
Const TimerElapsedTimeDealPack As Integer = TimerElapsedTime

' Имена игроков
Dim Shared RightEnemyName As WString * 512
Dim Shared PlayerName As WString * 512
Dim Shared LeftRightEnemyName As WString * 512
Dim Shared BankName As WString * 512
Dim Shared CurrencyChar As WString * 16

' Массив точек для анимации карты игрока
Dim Shared PlayerDealCardAnimationPointStart As Point
Dim Shared PlayerDealCardAnimationCardSortNumber As Integer
Dim Shared PlayerDealCardAnimationCardIncrementX As Integer
Dim Shared PlayerDealCardAnimationCardIncrementY As Integer
Dim Shared PlayerDealCardAnimationPointStartCount As Integer
Dim Shared PlayerDealCardAnimationHDC As HDC
Dim Shared PlayerDealCardAnimationBitmap As HBITMAP
' Анимация выдачи карт
Dim Shared BankDealCardAnimationStartCount As Integer
Dim Shared BankDealCardAnimationCardNumber As Integer


' Ширина и высота карты
Dim Shared mintWidth As Integer
Dim Shared mintHeight As Integer
' Игра идёт
Dim Shared CurrentGameMode As GameMode

' Рисование
Dim Shared DarkGreenBrush As HBRUSH
Dim Shared DarkGreenPen As HPEN
Dim Shared DoubleFont As HFONT

' Колода
Dim Shared BankDeck(35) As PlayerCard
' Карты
Dim Shared PlayerDeck(11) As PlayerCard
Dim Shared LeftEnemyDeck(11) As PlayerCard
Dim Shared RightEnemyDeck(11) As PlayerCard
' Деньги
Dim Shared PlayerMoney As Money
Dim Shared LeftEnemyMoney As Money
Dim Shared RightEnemyMoney As Money
Dim Shared BankMoney As Money

' Игрок может щёлкать по своим картам
Dim Shared PlayerCanPlay As Boolean
' Указатель на индекс карты для ввода с клавиатуры
Dim Shared PlayerKeyboardCardNumber As Integer

Dim Shared m_IrcClient As IrcClient

' Любое серверное сообщение
Sub ServerMessage(ByVal AdvData As Any Ptr, ByVal ServerCode As WString Ptr, ByVal MessageText As WString Ptr)
	If lstrcmp(ServerCode, @RPL_WELCOME) = 0 Then
		m_IrcClient.JoinChannel(@Channel)
	End If
End Sub

' Пользователь присоединился к каналу
Sub UserJoined(ByVal AdvData As Any Ptr, ByVal Channel As WString Ptr, ByVal UserName As WString Ptr)
	' Если это мы, то нужно дать понять, что готовы создать серверное
	If lstrcmp(@Nick, UserName) = 0 Then
		' Нужно получить список серверов
		' Клиенты должны ответить что они «сервер и количество свободных мест»
		' либо что они не являются серверами, а простыми клиентами
		
		' Нужно спросить о создании сервера
		If MessageBox(0, "Игра уже идёт. Точно остановить?", "Девятка", MB_YESNO + MB_ICONEXCLAMATION + MB_DEFBUTTON2) = IDYES Then
			' Отправить в чат сообщение о создании сервера
			' Пользователи должны отправить сообщение о присоединении
			' Затем должно быть сообщение о запуске игры на сервере
		End If
		' Нужно спросить о присоединении к свободному серверу
		
		' Клиенты ожидают от сервера сообщения о начале игры
	Else
	End If
End Sub

Sub DrawCharactersPack(ByVal hDC As HDC, ByVal pc As PlayerCard Ptr, ByVal Character As Characters)
	' TODO Пересчёт координат карт при удалении из массива, чтобы не было пустых мест
	' Dim oldFont As HFONT = SelectObject(PlayerDealCardAnimationHDC, DoubleFont)
	' Dim oldColor As Integer = SetTextColor(PlayerDealCardAnimationHDC, &hFFFFFF)
	' Dim BkMode As Integer = SetBkMode(PlayerDealCardAnimationHDC, TRANSPARENT)
	Dim OldPen As HPEN = SelectObject(PlayerDealCardAnimationHDC, DarkGreenPen)
	Dim OldBrush As HBRUSH = SelectObject(PlayerDealCardAnimationHDC, DarkGreenBrush)
	
	' Стереть
	Rectangle(PlayerDealCardAnimationHDC, 0, 0, pc[11].X - pc[0].X + mintWidth, pc[11].Y - pc[0].Y + mintHeight)
	
	For i As Integer = 0 To 11
		If CurrentGameMode <> GameMode.Stopped Then
			' Нарисовать те, что на руках у персонажей
			If pc[i].IsUsed Then
				If Character = Characters.Player Then
					' Для игрока нарисовать лицевую сторону
					cdtDrawExt(PlayerDealCardAnimationHDC, pc[i].X - pc[0].X, pc[i].Y - pc[0].Y, mintWidth, mintHeight, pc[i].CardNumber, CardViews.Normal, 0)
				Else
					' Для врагов нарисовать рубашку
					cdtDrawExt(PlayerDealCardAnimationHDC, pc[i].X - pc[0].X, pc[i].Y - pc[0].Y, mintWidth, mintHeight, Backs.Sky, CardViews.Back, 0)
				End If
			End If
		End If
	Next
	
	SelectObject(PlayerDealCardAnimationHDC, OldBrush)
	SelectObject(PlayerDealCardAnimationHDC, OldPen)
	' SetBkMode(PlayerDealCardAnimationHDC, BkMode)
	' SetTextColor(PlayerDealCardAnimationHDC, oldColor)
	' SelectObject(PlayerDealCardAnimationHDC, oldFont)
	
	' Восстановить изображение из памяти
	BitBlt(hDC, pc[0].X, pc[0].Y, pc[11].X - pc[0].X + mintWidth, pc[11].Y - pc[0].Y + mintHeight, PlayerDealCardAnimationHDC, 0, 0, SRCCOPY)
End Sub

Sub DrawBankPack(ByVal hDC As HDC)
	' Нарисовать в памяти
	Dim OldPen As HPEN = SelectObject(PlayerDealCardAnimationHDC, DarkGreenPen)
	Dim OldBrush As HBRUSH = SelectObject(PlayerDealCardAnimationHDC, DarkGreenBrush)
	
	For i As Integer = 0 To 35
		If CurrentGameMode = GameMode.Stopped Then
			' Нарисовать все карты
			cdtDrawExt(PlayerDealCardAnimationHDC, BankDeck(i).X - BankDeck(0).X, BankDeck(i).Y - BankDeck(0).Y, mintWidth, mintHeight, BankDeck(i).CardNumber, CardViews.Normal, 0)
		Else
			' Нарисовать только те, что лежат на рабочем столе
			If BankDeck(i).IsUsed Then
				cdtDrawExt(PlayerDealCardAnimationHDC, BankDeck(i).X - BankDeck(0).X, BankDeck(i).Y - BankDeck(0).Y, mintWidth, mintHeight, BankDeck(i).CardNumber, CardViews.Normal, 0)
			Else
				' Для остальных рамки
				Rectangle(PlayerDealCardAnimationHDC, BankDeck(i).X - BankDeck(0).X, BankDeck(i).Y - BankDeck(0).Y, BankDeck(i).X - BankDeck(0).X + mintWidth, BankDeck(i).Y - BankDeck(0).Y + mintHeight)
			End If
		End If
	Next
	SelectObject(PlayerDealCardAnimationHDC, OldPen)
	SelectObject(PlayerDealCardAnimationHDC, OldBrush)
	
	' Восстановить изображение из памяти
	BitBlt(hDC, BankDeck(0).X, BankDeck(0).Y, BankDeck(8).X - BankDeck(0).X + mintWidth, BankDeck(35).Y - BankDeck(0).Y + mintHeight, PlayerDealCardAnimationHDC, 0, 0, SRCCOPY)
	
End Sub

Sub GetMoneyString(ByVal buffer As WString Ptr, ByVal Value As Integer, ByVal CharacterName As WString Ptr)
	Dim bufferMoney As WString * 256 = Any
	
	itow(Value, @bufferMoney, 10)
	lstrcpy(buffer, CharacterName)
	lstrcat(Buffer, ": ")
	lstrcat(buffer, bufferMoney)
	lstrcat(buffer, " ")
	lstrcat(buffer, CurrencyChar)
End Sub

Sub DrawMoney(ByVal hDC As HDC, ByVal OldRightEnemyMoney As Integer,  ByVal OldPlayerMoney As Integer, ByVal OldLeftEnemyMoney As Integer, ByVal OldBankMoney As Integer)
	' Шрифт
	Dim oldFont As HFONT = SelectObject(hDC, DoubleFont)
	Dim oldColor As Integer = SetTextColor(hDC, &hFFF8F0)
	Dim BkMode As Integer = SetBkMode(hDC, TRANSPARENT)
	Dim OldPen As HPEN = SelectObject(hDC, DarkGreenPen)
	Dim OldBrush As HBRUSH = SelectObject(hDC, DarkGreenBrush)
	
	' Деньги игрока, соперников и банка
	
	Dim buffer As WString * 256 = Any
	
	Scope
		GetMoneyString(buffer, OldRightEnemyMoney, @RightEnemyName)
		
		Dim MoneyTextSize As SIZE = Any
		GetTextExtentPoint32(hDC, @buffer, lstrlen(@buffer), @MoneyTextSize)
		
		Rectangle(hDC, RightEnemyMoney.X, RightEnemyMoney.Y, RightEnemyMoney.X + MoneyTextSize.cx, RightEnemyMoney.Y + MoneyTextSize.cy)
		
		GetMoneyString(buffer, RightEnemyMoney.Value, @RightEnemyName)
		
		TextOut(hDC, RightEnemyMoney.X, RightEnemyMoney.Y, @buffer, lstrlen(@buffer))
	End Scope
	
	Scope
		GetMoneyString(buffer, OldPlayerMoney, @PlayerName)
		
		Dim MoneyTextSize As SIZE = Any
		GetTextExtentPoint32(hDC, @buffer, lstrlen(@buffer), @MoneyTextSize)
		
		Rectangle(hDC, PlayerMoney.X, PlayerMoney.Y, PlayerMoney.X + MoneyTextSize.cx, PlayerMoney.Y + MoneyTextSize.cy)
		
		GetMoneyString(buffer, PlayerMoney.Value, @PlayerName)
		
		TextOut(hDC, PlayerMoney.X, PlayerMoney.Y, @buffer, lstrlen(@buffer))
	End Scope
	
	Scope
		GetMoneyString(buffer, OldLeftEnemyMoney, @LeftRightEnemyName)
		
		Dim MoneyTextSize As SIZE = Any
		GetTextExtentPoint32(hDC, @buffer, lstrlen(@buffer), @MoneyTextSize)
		
		Rectangle(hDC, LeftEnemyMoney.X, LeftEnemyMoney.Y, LeftEnemyMoney.X + MoneyTextSize.cx, LeftEnemyMoney.Y + MoneyTextSize.cy)
		
		GetMoneyString(buffer, LeftEnemyMoney.Value, @LeftRightEnemyName)
		
		TextOut(hDC, LeftEnemyMoney.X, LeftEnemyMoney.Y, @buffer, lstrlen(@buffer))
	End Scope
	
	Scope
		GetMoneyString(buffer, OldBankMoney, @BankName)
		
		Dim MoneyTextSize As SIZE = Any
		GetTextExtentPoint32(hDC, @buffer, lstrlen(@buffer), @MoneyTextSize)
		
		Rectangle(hDC, BankMoney.X, BankMoney.Y, BankMoney.X + MoneyTextSize.cx, BankMoney.Y + MoneyTextSize.cy)
		
		GetMoneyString(buffer, BankMoney.Value, @BankName)
		
		TextOut(hDC, BankMoney.X, BankMoney.Y, @buffer, lstrlen(@buffer))
	End Scope
	
	' Очистка
	SelectObject(hDC, OldBrush)
	SelectObject(hDC, OldPen)
	SetBkMode(hDC, BkMode)
	SetTextColor(hDC, oldColor)
	SelectObject(hDC, oldFont)
End Sub

Sub DrawUpArrow(ByVal hDC As HDC, ByVal NewCardNumber As Integer)
	Const UpArrow = "↑"
	' Шрифт
	Dim oldFont As HFONT = SelectObject(hDC, DoubleFont)
	Dim oldColor As Integer = SetTextColor(hDC, &hFFF8F0) 'SetTextColor(hDC, &hFFFFFF)
	Dim BkMode As Integer = SetBkMode(hDC, TRANSPARENT)
	Dim OldPen As HPEN = SelectObject(hDC, DarkGreenPen)
	Dim OldBrush As HBRUSH = SelectObject(hDC, DarkGreenBrush)
	
	' Стереть старое изображение стрелки
	Rectangle(hDC, PlayerDeck(0).X, PlayerDeck(0).Y + mintHeight, PlayerDeck(11).X + mintWidth, PlayerDeck(11).Y + 2 * mintHeight)
	
	If CurrentGameMode <> GameMode.Stopped Then
		' Нарисовать стрелку по координанам карт игрока
		TextOut(hDC, PlayerDeck(NewCardNumber).X + mintWidth \ 2, PlayerDeck(NewCardNumber).Y + mintHeight + 5, @UpArrow, lstrlen(@UpArrow))
	End If
	
	' Очистка
	SelectObject(hDC, OldBrush)
	SelectObject(hDC, OldPen)
	SetBkMode(hDC, BkMode)
	SetTextColor(hDC, oldColor)
	SelectObject(hDC, oldFont)
End Sub

Function IncrementX(ByVal X As Integer)As Integer
	' Если координата X больше, то увеличить
	If X > PlayerDealCardAnimationPointStart.X Then
		Return PlayerDealCardAnimationCardIncrementX
	Else
		' Иначе уменьшить
		Return -1 * PlayerDealCardAnimationCardIncrementX
	End If
End Function

Function IncrementY(ByVal Y As Integer)As Integer
	' Если коордитата Y больше, то уменьшить
	If Y > PlayerDealCardAnimationPointStart.Y Then
		Return PlayerDealCardAnimationCardIncrementY
	Else
		' Иначе увеличить
		Return -1 * PlayerDealCardAnimationCardIncrementY
	End If
End Function

Sub LoadCharacterNick(ByVal Buffer As WString Ptr, ByVal ResId As Integer)
	LoadString(GetModuleHandle(0), ResId, Buffer, 512 - 3)
End Sub

Sub MainForm_Load(ByVal hWin As HWND, ByVal wParam As WPARAM, ByVal lParam As LPARAM)
	' Ники игроков
	LoadCharacterNick(@RightEnemyName, IDS_RIGHTENEMYNICK)
	LoadCharacterNick(@PlayerName, IDS_USERNICK)
	LoadCharacterNick(@LeftRightEnemyName, IDS_LEFTENEMYNICK)
	LoadCharacterNick(@BankName, IDS_BANKNICK)
	
	LoadString(GetModuleHandle(0), IDS_CURRENCYCHAR, @CurrencyChar, 8)
	
	' Инициализация случайных чисел
	Dim dtNow As SYSTEMTIME = Any
	GetSystemTime(@dtNow)
	srand(dtNow.wMilliseconds - dtNow.wSecond + dtNow.wMinute + dtNow.wHour)
	
	' Инициализация библиотеки
	cdtInit(@mintWidth, @mintHeight)
	
	' Размеры карт
	For i As Integer = 0 To 35
		' Карта лежит на рабочем столе
		BankDeck(i).IsUsed = True
		BankDeck(i).CardNumber = GetCardNumber(i)
		BankDeck(i).CardSortNumber = i
	Next
	
	' Объекты GDI
	DarkGreenBrush = CreateSolidBrush(DarkGreenColor)
	DarkGreenPen = CreatePen(PS_SOLID, 1, DarkGreenColor)
	' Шрифт
	Dim hDefaultFont As HFONT = GetStockObject(DEFAULT_GUI_FONT)
	Dim oFont As LOGFONT = Any
	GetObject(hDefaultFont, SizeOf(LOGFONT), @oFont)
	oFont.lfHeight *= 4 'oFont.lfHeight * 3 - oFont.lfHeight \ 2
	DoubleFont = CreateFontIndirect(@oFont)
	
	PlayerDealCardAnimationHDC = CreateCompatibleDC(0)
	If PlayerDealCardAnimationHDC = 0 Then
		' MessageBox(hWin, @"Не могу создать контекст устройства", @"Девятка", MB_ICONINFORMATION)
	End If
	
	Dim hDCmem As HDC = GetDC(hWin)
	PlayerDealCardAnimationBitmap = CreateCompatibleBitmap(hDCmem,  GetDeviceCaps(PlayerDealCardAnimationHDC, HORZRES),  GetDeviceCaps(PlayerDealCardAnimationHDC, VERTRES))
	
	If PlayerDealCardAnimationBitmap = 0 Then
		' MessageBox(hWin, @"Не могу создать изображение", @"Девятка", MB_ICONINFORMATION)
	End If
	If SelectObject(PlayerDealCardAnimationHDC, PlayerDealCardAnimationBitmap) = 0 Then
		' MessageBox(hWin, @"Не могу выбрать изображение", @"Девятка", MB_ICONINFORMATION)
	End If
	If DeleteDC(hDCmem) = 0 Then
		' MessageBox(hWin, @"Не могу удалить контекст", @"Девятка", MB_ICONINFORMATION)
	End If
End Sub

Sub MainFormMenuNewGame_Click(ByVal hWin As HWND)
	' Новая игра
	If CurrentGameMode <> GameMode.Stopped Then
		' Игра идёт
		' Спросить у пользователя
		' желает ли он прервать текущую игру
		' Dim WarningMsg As WString *256
		' LoadString(hInst, IDS_NEWGAMEWARNING, WarningMsg, 256)
		If MessageBox(hWin, "Игра уже идёт. Точно остановить?", "Девятка", MB_YESNO + MB_ICONEXCLAMATION + MB_DEFBUTTON2) <> IDYES Then
			' Начинаем заново
			Exit Sub
		End If
	End If
	CurrentGameMode = GameMode.Normal
	PostMessage(hWin, PM_NEWGAME, 0, 0)
End Sub

Sub MainFormMenuNewNetworkGame_Click(ByVal hWin As HWND)
	' TODO Сделать сетевой режим
	If CurrentGameMode <> GameMode.Stopped Then
		If MessageBox(hWin, "Игра уже идёт. Точно остановить?", "Девятка", MB_YESNO + MB_ICONEXCLAMATION + MB_DEFBUTTON2) <> IDYES Then
			' Начинаем заново
			Exit Sub
		End If
	End If
	If DialogBoxParam(GetModuleHandle(NULL), MAKEINTRESOURCE(IDD_DLG_NETWORK), hWin, @NetworkParamDialogProc, 0) <> IDOK Then
		Exit Sub
	End If
	' Открыть соединение с сервером
	' m_IrcClient.ExtendedData = @m_IrcClient
	' m_IrcClient.ServerMessageEvent = @ServerMessage
	' m_IrcClient.UserJoinedEvent = @UserJoined
	' If m_IrcClient.OpenIrc(@Server, @Port, @LocalAddress, @LocalPort, @"", @Nick, @Nick, @"Gaming The Nine Bot", False) = ResultType.None Then
		' Запустить второй поток для генерации событий
		' Dim hThread As Handle = CreateThread(NULL, 0, @ThreadProc, @m_IrcClient, 0, 0)
		' CloseHandle(hThread)
	' End If
	CurrentGameMode = GameMode.Network
	PostMessage(hWin, PM_NEWGAME, 0, 0)
End Sub

Sub MainFormMenuNewAIGame_Click(ByVal hWin As HWND)
	' Игры компьютеров друг с другом
	If CurrentGameMode <> GameMode.Stopped Then
		If MessageBox(hWin, "Игра уже идёт. Точно остановить?", "Девятка", MB_YESNO + MB_ICONEXCLAMATION + MB_DEFBUTTON2) <> IDYES Then
			' Начинаем заново
			Exit Sub
		End If
	End If
	CurrentGameMode = GameMode.AI
	PostMessage(hWin, PM_NEWGAME, 0, 0)
End Sub

Sub MainFormMenuFileExit_Click(ByVal hWin As HWND)
	DestroyWindow(hWin)
End Sub

Sub MainFormMenuHelpContents_Click(ByVal hWin As HWND)
	MessageBox(hWin, "Справочная система ещё не реализована", "Девятка", MB_OK + MB_ICONINFORMATION)
End Sub

Sub MainFormMenuHelpAbout_Click(ByVal hWin As HWND)
	DialogBoxParam(GetModuleHandle(NULL), MAKEINTRESOURCE(IDD_DLG_ABOUT), hWin, @AboutDialogProc, 0)
End Sub

Sub MainForm_LeftMouseDown(ByVal hWin As HWND, ByVal KeyModifier As Integer, ByVal X As Integer, ByVal Y As Integer)
	If PlayerCanPlay Then
		' Получить номер карты, на который щёлкнул пользователь
		Dim CardNumber As Integer = GetClickPlayerCardNumber(@PlayerDeck(0), X, Y, mintWidth, mintHeight)
		If CardNumber >= 0 Then
			' Проверить правильность хода пользователя
			If ValidatePlayerCardNumber(PlayerDeck(CardNumber).CardSortNumber, @BankDeck(0)) Then
				' Запретить ходить пользователю
				PlayerCanPlay = False
				' Ходить
				PostMessage(hWin, PM_USERATTACK, CardNumber, True)
			End If
		End If
	End If
End Sub

Sub MainForm_KeyDown(ByVal hWin As HWND, ByVal KeyCode As Integer)
	' Выбрать карту
	Select Case KeyCode
		Case VK_LEFT
			' Установить номер на ближайшую левую карту
			Dim tmpNumber As Integer = PlayerKeyboardCardNumber
			Do
				tmpNumber -= 1
				If tmpNumber < 0 Then
					tmpNumber = 11
				End If
				If PlayerDeck(tmpNumber).IsUsed Then
					Exit Do
				End If
			Loop While tmpNumber <> PlayerKeyboardCardNumber
			PlayerKeyboardCardNumber = tmpNumber
			' Перерисовать стрелку‐указатель
			Scope
				Dim hDC As HDC = GetDC(hWin)
				DrawUpArrow(hDC, PlayerKeyboardCardNumber)
				ReleaseDC(hWin, hDC)
			End Scope

		Case VK_RIGHT
			' Установить номер на ближайшую правую карту
			Dim tmpNumber As Integer = PlayerKeyboardCardNumber
			Do
				tmpNumber += 1
				If tmpNumber > 11 Then
					tmpNumber = 0
				End If
				If PlayerDeck(tmpNumber).IsUsed Then
					Exit Do
				End If
			Loop While tmpNumber <> PlayerKeyboardCardNumber
			PlayerKeyboardCardNumber = tmpNumber
			' Перерисовать стрелку‐указатель
			Scope
				Dim hDC As HDC = GetDC(hWin)
				DrawUpArrow(hDC, PlayerKeyboardCardNumber)
				ReleaseDC(hWin, hDC)
			End Scope
			
		Case VK_RETURN
			' Проверить правильность хода пользователя
			If PlayerCanPlay Then
				If ValidatePlayerCardNumber(PlayerDeck(PlayerKeyboardCardNumber).CardSortNumber, @BankDeck(0)) Then
					' Запретить ходить пользователю
					PlayerCanPlay = False
					' Ходить
					PostMessage(hWin, PM_USERATTACK, PlayerKeyboardCardNumber, True)
				End If
			End If
	End Select
End Sub

Sub MainForm_Paint(ByVal hWin As HWND)
	Dim ClientRectangle As RECT = Any
	GetClientRect(hWin, @ClientRectangle)
	
	' Рисуем игровое поле
	Dim pnt As PAINTSTRUCT = Any
	Dim hDC As HDC = BeginPaint(hWin, @pnt)
	
	' Закрасить рабочий стол зелёным цветом
	Dim oldBrush As HBRUSH = SelectObject(hDC, DarkGreenBrush)
	Dim oldPen As HPEN = SelectObject(hDC, DarkGreenPen)
	ExtFloodFill(hDC, 0, 0, &h004000, FLOODFILLBORDER)
	
	' Карты игрока и врагов
	DrawCharactersPack(hDC, @RightEnemyDeck(0), Characters.RightCharacter)
	DrawCharactersPack(hDC, @PlayerDeck(0), Characters.Player)
	DrawCharactersPack(hDC, @LeftEnemyDeck(0), Characters.LeftCharacter)
	' Рабочий стол
	DrawBankPack(hDC)
	
	' Деньги
	DrawMoney(hDC, RightEnemyMoney.Value, PlayerMoney.Value, LeftEnemyMoney.Value, BankMoney.Value)
	
	' Стрелка
	DrawUpArrow(hDC, PlayerKeyboardCardNumber)
	
	' Очистка
	SelectObject(hDC, oldPen)
	SelectObject(hDC, oldBrush)
	EndPaint(hWin, @pnt)
End Sub

Sub MainForm_Resize(ByVal hWin As HWND, ByVal ResizingRequested As Integer, ByVal ClientWidth As Integer, ByVal ClientHeight As Integer)
	' Изменение размеров окна, пересчитать координаты карт
	
	' TODO Адаптивный дизайн: масштабирование и распределение по всему окну
	
	' Центр клиентской области
	Dim ClientRectangle As RECT = Any
	GetClientRect(hWin, @ClientRectangle)
	Dim cx As Integer = ClientRectangle.right \ 2
	Dim cy As Integer = ClientRectangle.bottom \ 2
	
	Scope
		' Карты банка
		' Смещение относительно центра клиентской области для центрирования карт
		Dim dx As Integer = cx - (mintWidth * 9) \ 2
		Dim dy As Integer = mintHeight
		
		For k As Integer = 0 To 3
			For j As Integer = 0 To 8
				Dim i As Integer = k * 9 + j
				BankDeck(i).X = j * mintWidth + dx
				BankDeck(i).Y = k * mintHeight + dy
			Next
		Next
		' Деньги банка
		BankMoney.X = cx - mintWidth
		BankMoney.Y = mintHeight \ 3
	End Scope
	
	Scope
		' Карты игрока
		Dim dxPlayer As Integer = cx - (mintWidth * 12) \ 2
		Dim dyPlayer As Integer = mintHeight * 6 - mintHeight \ 3
		For i As Integer = 0 To 11
			PlayerDeck(i).X = i * mintWidth + dxPlayer
			PlayerDeck(i).Y = dyPlayer
		Next
		' Деньги игрока
		PlayerMoney.X = cx - mintWidth
		PlayerMoney.Y = mintHeight * 6 - 3 * mintHeight \ 3
	End Scope
	
	Scope
		' Карты левого врага
		Dim dxEnemyLeft As Integer = cx - (mintWidth * 9) \ 2 - mintWidth - mintWidth \ 2
		Dim dyEnemyLeft As Integer = mintHeight - mintHeight \ 3
		For i As Integer = 0 To 11
			LeftEnemyDeck(i).X = dxEnemyLeft
			LeftEnemyDeck(i).Y = i * (mintHeight \ 3) + dyEnemyLeft
		Next
		' Деньги левого врага
		LeftEnemyMoney.X = dxEnemyLeft
		LeftEnemyMoney.Y = mintHeight \ 8
	End Scope
	
	Scope
		' Карты правого врага
		Dim dxEnemyRight As Integer = cx + (mintWidth * 9) \ 2 + mintWidth \ 2
		Dim dyEnemyRight As Integer = mintHeight - mintHeight \ 3
		For i As Integer = 0 To 11
			RightEnemyDeck(i).X = dxEnemyRight
			RightEnemyDeck(i).Y = i * (mintHeight \ 3) + dyEnemyRight
		Next
		' Деньги правого врага
		RightEnemyMoney.X = dxEnemyRight - mintWidth
		RightEnemyMoney.Y = mintHeight \ 8
	End Scope
End Sub

Sub MainForm_Close(ByVal hWin As HWND)
	' Пользователь пытается закрыть окно
	' Если игра уже идёт, то спросить
	DestroyWindow(hWin)
End Sub

Sub MainForm_UnLoad(ByVal hWin As HWND)
	' Очистка
	m_IrcClient.QuitFromServer("Quit")
	m_IrcClient.CloseIrc()
	
	DeleteObject(DoubleFont)
	If DeleteObject(PlayerDealCardAnimationBitmap) = 0 Then
		MessageBox(hWin, @"Не могу удалить картинку", @"Девятка", MB_ICONINFORMATION)
	End If
	If DeleteDC(PlayerDealCardAnimationHDC) = 0 Then
		MessageBox(hWin, @"Не могу удалить устройство рисования", @"Девятка", MB_ICONINFORMATION)
	End If
	If DeleteObject(DarkGreenPen) = 0 Then
		' MessageBox(hWin, @"Не могу удалить перо", @"Девятка", MB_ICONINFORMATION)
	End If
	If DeleteObject(DarkGreenBrush) = 0 Then
		' MessageBox(hWin, @"Не могу удалить кисть", @"Девятка", MB_ICONINFORMATION)
	End If
	cdtTerm()
End Sub

Sub MainForm_NewGame(ByVal hWin As HWND, ByVal wParam As WPARAM, ByVal lParam As LPARAM)
	' Начинаем новую игру
	
	' Событие восстановления суммы денег
	SendMessage(hWin, PM_DEFAULTMONEY, 0, 0)
	
	' Начать новый раунд
	PostMessage(hWin, PM_NEWSTAGE, 0, 0)
End Sub

Sub MainForm_NewStage(ByVal hWin As HWND, ByVal wParam As WPARAM, ByVal lParam As LPARAM)
	' Новый раунд игры
	
	PlayerKeyboardCardNumber = 0
	
	If PlayerMoney.Value <= 0 Then
		' Проигрыш
		' TODO Анимация проигрыша
		CurrentGameMode = GameMode.Stopped
		If MessageBox(hWin, "Ты проиграл. Начать заново?", "Девятка", MB_YESNO + MB_ICONEXCLAMATION + MB_DEFBUTTON1) = IDYES Then
			' Начинаем заново
			PostMessage(hWin, PM_NEWGAME, 0, 0)
		End If
		
	Else
		If RightEnemyMoney.Value <= 0 Then
			' Проигрыш
			' TODO Анимация проигрыша
			CurrentGameMode = GameMode.Stopped
			If MessageBox(hWin, "Зиновий проиграл. Начать заново?", "Девятка", MB_YESNO + MB_ICONEXCLAMATION + MB_DEFBUTTON1) = IDYES Then
				' Начинаем заново
				PostMessage(hWin, PM_NEWGAME, 0, 0)
			End If
		Else
			If LeftEnemyMoney.Value <= 0 Then
				' Проигрыш
				' TODO Анимация проигрыша
				CurrentGameMode = GameMode.Stopped
				If MessageBox(hWin, "Ева проиграла. Начать заново?", "Девятка", MB_YESNO + MB_ICONEXCLAMATION + MB_DEFBUTTON1) = IDYES Then
					' Начинаем заново
					PostMessage(hWin, PM_NEWGAME, 0, 0)
				End If
			Else
				' Событие взятия суммы у игроков
				SendMessage(hWin, PM_DEALMONEY, 0, 0)
				
				' Событие раздачи колоды карт игрокам
				PostMessage(hWin, PM_DEALPACK, 0, 0)
			End If
		End If
	End If
End Sub

Sub MainForm_DefaultMoney(ByVal hWin As HWND, ByVal wParam As WPARAM, ByVal lParam As LPARAM)
	' Событие восстановления денег
	' TODO Анимация восстановления денег
	Dim m(3) As Integer = Any
	m(0) = PlayerMoney.Value
	m(1) = RightEnemyMoney.Value
	m(2) = LeftEnemyMoney.Value = DefaultMoney
	m(3) = BankMoney.Value
	
	PlayerMoney.Value = DefaultMoney
	LeftEnemyMoney.Value = DefaultMoney
	RightEnemyMoney.Value = DefaultMoney
	BankMoney.Value = 0
	' RightEnemyMoney.Value, PlayerMoney.Value, LeftEnemyMoney.Value, BankMoney.Value
	Scope
		Dim hDC As HDC = GetDC(hWin)
		DrawMoney(hDC, m(0), m(1), m(2), m(3))
		ReleaseDC(hWin, hDC)
	End Scope
End Sub

Sub MainForm_DealMoney(ByVal hWin As HWND, ByVal wParam As WPARAM, ByVal lParam As LPARAM)
	' Взятие денег у персонажей
	' TODO Анимация взятия денег у игроков
	' RedrawWindow(hWin, NULL, NULL, RDW_INVALIDATE)
	Dim m(3) As Integer = Any
	m(0) = PlayerMoney.Value
	m(1) = RightEnemyMoney.Value
	m(2) = LeftEnemyMoney.Value = DefaultMoney
	m(3) = BankMoney.Value
	
	PlayerMoney.Value -= ZZZMoney
	LeftEnemyMoney.Value -= ZZZMoney
	RightEnemyMoney.Value -= ZZZMoney
	BankMoney.Value = 3 * ZZZMoney
	
	Scope
		Dim hDC As HDC = GetDC(hWin)
		DrawMoney(hDC, m(0), m(1), m(2), m(3))
		ReleaseDC(hWin, hDC)
	End Scope
End Sub

Sub MainForm_DealPack(ByVal hWin As HWND, ByVal wParam As WPARAM, ByVal lParam As LPARAM)
	' Раздача колоды
	
	' Перемешивание массива
	Dim RandomNumbers(35) As Integer = Any
	ShuffleArray(@RandomNumbers(0), 36)
	
	' Выдача игрокам
	For i As Integer = 0 To 11
		PlayerDeck(i).IsUsed = True
		PlayerDeck(i).CardSortNumber = RandomNumbers(i)
		PlayerDeck(i).CardNumber = GetCardNumber(RandomNumbers(i))
	Next
	For i As Integer = 0 To 11
		LeftEnemyDeck(i).IsUsed = True
		LeftEnemyDeck(i).CardSortNumber = RandomNumbers(i + 12)
		LeftEnemyDeck(i).CardNumber = GetCardNumber(RandomNumbers(i + 12))
	Next
	For i As Integer = 0 To 11
		RightEnemyDeck(i).IsUsed = True
		RightEnemyDeck(i).CardSortNumber = RandomNumbers(i + 2 * 12)
		RightEnemyDeck(i).CardNumber = GetCardNumber(RandomNumbers(i + 2 * 12))
	Next
	
	' Сортировать карты по мастям по старшинству
	SortCharacterPack(@RightEnemyDeck(0))
	SortCharacterPack(@PlayerDeck(0))
	SortCharacterPack(@LeftEnemyDeck(0))
	
	' Анимация раздачи колоды
	SetTimer(hWin, BankDealCardTimerId, TimerElapsedTimeDealPack, NULL)
End Sub

Sub MainForm_RightEnemyAttack(ByVal hWin As HWND, ByVal wParam As WPARAM, ByVal lParam As LPARAM)
	' Ход правого врага
	If lParam = False Then
		' Номер карты определить самостоятельно
		Dim CardIndex As Integer = GetPlayerDealCard(@RightEnemyDeck(0), @BankDeck(0))
		If CardIndex >= 0 Then
			wParam = CardIndex
			lParam = True
		End If
	End If
	If lParam Then
		' В параметре wParam номер карты
		' Отправить карту на поле
		PostMessage(hWin, PM_RENEMYDEALCARD, wParam, 0)
	Else
		' Правый враг не может ходить
		SendMessage(hWin, PM_RENEMYFOOL, 0, 0)
		
		Select Case CurrentGameMode
			Case GameMode.Normal
				lParam = False
			Case GameMode.AI
				' Выбрать карту за игрока
				Dim CardIndex As Integer = GetPlayerDealCard(@PlayerDeck(0), @BankDeck(0))
				If CardIndex >= 0 Then
					wParam = CardIndex
					lParam = True
				Else
					lParam = False
				End If
			Case GameMode.Network
				
		End Select
		' Передать ход игроку
		PostMessage(hWin, PM_USERATTACK, wParam, lParam)
	End If
End Sub

Sub MainForm_LeftEnemyAttack(ByVal hWin As HWND, ByVal wParam As WPARAM, ByVal lParam As LPARAM)
	' Ход левого врага
	If lParam = False Then
		' Определить номер карты, которой можно ходить
		Dim CardIndex As Integer = GetPlayerDealCard(@LeftEnemyDeck(0), @BankDeck(0))
		If CardIndex >= 0 Then
			wParam = CardIndex
			lParam = True
		Else
			lParam = False
		End If
	End If
	If lParam Then
		' В параметре wParam номер карты
		' Отправить карту на поле
		PostMessage(hWin, PM_LENEMYDEALCARD, wParam, 0)
	Else
		' Левый враг не может ходить
		SendMessage(hWin, PM_LENEMYFOOL, 0, 0)
		' Передать правому врагу
		PostMessage(hWin, PM_RENEMYATTACK, 0, 0)
	End If
End Sub

Sub MainForm_UserAttack(ByVal hWin As HWND, ByVal wParam As WPARAM, ByVal lParam As LPARAM)
	' Ход игрока
	If lParam Then
		' Установить номер на ближайшую правую карту
		Dim tmpNumber As Integer = wParam
		Do
			tmpNumber += 1
			If tmpNumber > 11 Then
				tmpNumber = 0
			End If
			If PlayerDeck(tmpNumber).IsUsed Then
				Exit Do
			End If
		Loop While tmpNumber <> wParam
		PlayerKeyboardCardNumber = tmpNumber
		' Перерисовать стрелку‐указатель
		Scope
			Dim hDC As HDC = GetDC(hWin)
			DrawUpArrow(hDC, PlayerKeyboardCardNumber)
			ReleaseDC(hWin, hDC)
		End Scope
		' Ходить указанной картой
		PostMessage(hWin, PM_USERDEALCARD, wParam, 0)
	Else
		' Проверить, может ли игрок ходить
		If GetPlayerDealCard(@PlayerDeck(0), @BankDeck(0)) >= 0 Then
			PlayerCanPlay = True
		Else
			' У пользователя нет карт для хода
			' MessageBox(hWin, @"Игрок не может ходить", @"Девятка", MB_ICONINFORMATION)
			SendMessage(hWin, PM_USERFOOL, 0, 0)
			' Передать ход левому игроку
			PostMessage(hWin, PM_LENEMYATTACK, 0, 0)
		End If
	End If
End Sub

Sub MainForm_RightEnemyFool(ByVal hWin As HWND)
	' Взятие денег у игрока при отсутствии карты для хода
	Dim m(3) As Integer = Any
	m(0) = PlayerMoney.Value
	m(1) = RightEnemyMoney.Value
	m(2) = LeftEnemyMoney.Value
	m(3) = BankMoney.Value
	
	RightEnemyMoney.Value -= FFFMoney
	BankMoney.Value += FFFMoney
	
	' TODO Анимация взятия денег
	Scope
		Dim hDC As HDC = GetDC(hWin)
		DrawMoney(hDC, m(0), m(1), m(2), m(3))
		ReleaseDC(hWin, hDC)
	End Scope
End Sub

Sub MainForm_UserFool(ByVal hWin As HWND)
	' Взятие денег у игрока при отсутствии карты для хода
	Dim m(3) As Integer = Any
	m(0) = PlayerMoney.Value
	m(1) = RightEnemyMoney.Value
	m(2) = LeftEnemyMoney.Value
	m(3) = BankMoney.Value
	
	PlayerMoney.Value -= FFFMoney
	BankMoney.Value += FFFMoney
	
	' TODO Анимация взятия денег
	Scope
		Dim hDC As HDC = GetDC(hWin)
		DrawMoney(hDC, m(0), m(1), m(2), m(3))
		ReleaseDC(hWin, hDC)
	End Scope
End Sub

Sub MainForm_LeftEnemyFool(ByVal hWin As HWND)
	' Взятие денег у игрока при отсутствии карты для хода
	Dim m(3) As Integer = Any
	m(0) = PlayerMoney.Value
	m(1) = RightEnemyMoney.Value
	m(2) = LeftEnemyMoney.Value
	m(3) = BankMoney.Value
	
	LeftEnemyMoney.Value -= FFFMoney
	BankMoney.Value += FFFMoney
	
	' TODO Анимация взятия денег
	Scope
		Dim hDC As HDC = GetDC(hWin)
		DrawMoney(hDC, m(0), m(1), m(2), m(3))
		ReleaseDC(hWin, hDC)
	End Scope
End Sub

Sub MainForm_RightEnemyWin(ByVal hWin As HWND)
	' Игрок положил последнюю карту
	' TODO Анимация игрок забирает все деньги банка
	' BankDealMoneyTimerId
	' RedrawWindow(hWin, NULL, NULL, RDW_INVALIDATE)
	Dim m(3) As Integer = Any
	m(0) = PlayerMoney.Value
	m(1) = RightEnemyMoney.Value
	m(2) = LeftEnemyMoney.Value
	m(3) = BankMoney.Value
	
	RightEnemyMoney.Value += BankMoney.Value
	BankMoney.Value = 0
	
	Scope
		Dim hDC As HDC = GetDC(hWin)
		DrawMoney(hDC, m(0), m(1), m(2), m(3))
		ReleaseDC(hWin, hDC)
	End Scope
	
	' Начать новый раунд
	PostMessage(hWin, PM_NEWSTAGE, 0, 0)
End Sub

Sub MainForm_UserWin(ByVal hWin As HWND)
	' Игрок положил последнюю карту
	' TODO Анимация игрок забирает все деньги банка
	' BankDealMoneyTimerId
	' RedrawWindow(hWin, NULL, NULL, RDW_INVALIDATE)
	Dim m(3) As Integer = Any
	m(0) = PlayerMoney.Value
	m(1) = RightEnemyMoney.Value
	m(2) = LeftEnemyMoney.Value = DefaultMoney
	m(3) = BankMoney.Value
	
	PlayerMoney.Value += BankMoney.Value
	BankMoney.Value = 0
	
	Scope
		Dim hDC As HDC = GetDC(hWin)
		DrawMoney(hDC, m(0), m(1), m(2), m(3))
		ReleaseDC(hWin, hDC)
	End Scope
	
	' Начать новый раунд
	PostMessage(hWin, PM_NEWSTAGE, 0, 0)
End Sub

Sub MainForm_LeftEnemyWin(ByVal hWin As HWND)
	' Игрок положил последнюю карту
	' TODO Анимация игрок забирает все деньги банка
	' BankDealMoneyTimerId
	' RedrawWindow(hWin, NULL, NULL, RDW_INVALIDATE)
	Dim m(3) As Integer = Any
	m(0) = PlayerMoney.Value
	m(1) = RightEnemyMoney.Value
	m(2) = LeftEnemyMoney.Value = DefaultMoney
	m(3) = BankMoney.Value
	
	LeftEnemyMoney.Value += BankMoney.Value
	BankMoney.Value = 0
	
	Scope
		Dim hDC As HDC = GetDC(hWin)
		DrawMoney(hDC, m(0), m(1), m(2), m(3))
		ReleaseDC(hWin, hDC)
	End Scope
	
	' Начать новый раунд
	PostMessage(hWin, PM_NEWSTAGE, 0, 0)
End Sub

Sub MainForm_RightEnemyDealCard(ByVal hWin As HWND, ByVal CardNumber As Integer)
	' Удалить карту из массива
	RightEnemyDeck(CardNumber).IsUsed = False
	
	' Начальная и конечная точки
	PlayerDealCardAnimationCardSortNumber = RightEnemyDeck(CardNumber).CardSortNumber
	' Приращение аргумента
	PlayerDealCardAnimationCardIncrementX = Abs(BankDeck(PlayerDealCardAnimationCardSortNumber).X - RightEnemyDeck(CardNumber).X) \ DealCardAnimationPartsCount
	PlayerDealCardAnimationCardIncrementY = Abs(BankDeck(PlayerDealCardAnimationCardSortNumber).Y - RightEnemyDeck(CardNumber).Y) \ DealCardAnimationPartsCount
	
	PlayerDealCardAnimationPointStart.X = RightEnemyDeck(CardNumber).X
	PlayerDealCardAnimationPointStart.Y = RightEnemyDeck(CardNumber).Y
	
	' Запустить таймер
	SetTimer(hWin, RightEnemyDealCardTimerId, TimerElapsedTime, NULL)
End Sub

Sub MainForm_UserDealCard(ByVal hWin As HWND, ByVal CardNumber As Integer)
	' Удалить карту из массива
	PlayerDeck(CardNumber).IsUsed = False
	
	' Начальная и конечная точки
	PlayerDealCardAnimationCardSortNumber = PlayerDeck(CardNumber).CardSortNumber
	' Приращение аргумента
	PlayerDealCardAnimationCardIncrementX = Abs(BankDeck(PlayerDealCardAnimationCardSortNumber).X - PlayerDeck(CardNumber).X) \ DealCardAnimationPartsCount
	PlayerDealCardAnimationCardIncrementY = Abs(BankDeck(PlayerDealCardAnimationCardSortNumber).Y - PlayerDeck(CardNumber).Y) \ DealCardAnimationPartsCount
	
	PlayerDealCardAnimationPointStart.X = PlayerDeck(CardNumber).X
	PlayerDealCardAnimationPointStart.Y = PlayerDeck(CardNumber).Y
	
	' Запустить таймер
	SetTimer(hWin, PlayerDealCardTimerId, TimerElapsedTime, NULL)
End Sub

Sub MainForm_LeftEnemyDealCard(ByVal hWin As HWND, ByVal CardNumber As Integer)
	' Удалить карту из массива
	LeftEnemyDeck(CardNumber).IsUsed = False
	
	' Начальная карта
	PlayerDealCardAnimationCardSortNumber = LeftEnemyDeck(CardNumber).CardSortNumber
	' Приращение аргумента
	PlayerDealCardAnimationCardIncrementX = Abs(BankDeck(PlayerDealCardAnimationCardSortNumber).X - LeftEnemyDeck(CardNumber).X) \ DealCardAnimationPartsCount
	PlayerDealCardAnimationCardIncrementY = Abs(BankDeck(PlayerDealCardAnimationCardSortNumber).Y - LeftEnemyDeck(CardNumber).Y) \ DealCardAnimationPartsCount
	' Начальная точка
	PlayerDealCardAnimationPointStart.X = LeftEnemyDeck(CardNumber).X
	PlayerDealCardAnimationPointStart.Y = LeftEnemyDeck(CardNumber).Y
	
	' Запустить таймер
	SetTimer(hWin, LeftEnemyDealCardTimerId, TimerElapsedTime, NULL)
End Sub

Sub RightEnemyDealCardTimer_Tick(ByVal hWin As HWND)
	' Если на руках карт нет, то победа
	If IsPlayerWin(@RightEnemyDeck(0)) Then
		PostMessage(hWin, PM_RENEMYWIN, 0, 0)
	Else
		Dim wParam As WPARAM = Any
		Dim lParam As LPARAM = Any
		
		' Передать ход игроку
		Select Case CurrentGameMode
			Case GameMode.Normal
				lParam = False
				
			Case GameMode.AI
				' Выбрать карту за игрока
				Dim CardIndex As Integer = GetPlayerDealCard(@PlayerDeck(0), @BankDeck(0))
				If CardIndex >= 0 Then
					wParam = CardIndex
					lParam = True
				Else
					lParam = False
				End If
				
			Case GameMode.Network
				
		End Select
		
		PostMessage(hWin, PM_USERATTACK, wParam, lParam)
	End If
End Sub

Sub LeftEnemyDealCardTimer_Tick(ByVal hWin As HWND)
	' Анимация передвижения карты
	
	Dim hDC As HDC = GetDC(hWin)
	
	Select Case PlayerDealCardAnimationPointStartCount
		Case 0
			PlayerDealCardAnimationPointStartCount = 1
			' TODO Исправить мигание колоды: стереть только ненужную карту
			DrawCharactersPack(hDC, @RightEnemyDeck(0), Characters.RightCharacter)
			DrawCharactersPack(hDC, @PlayerDeck(0), Characters.Player)
			DrawCharactersPack(hDC, @LeftEnemyDeck(0), Characters.LeftCharacter)
			' Увеличить координаты X и Y
			' PlayerDealCardAnimationPointStart.X += IncrementX(BankDeck(PlayerDealCardAnimationCardSortNumber).X)
			' PlayerDealCardAnimationPointStart.Y += IncrementY(BankDeck(PlayerDealCardAnimationCardSortNumber).Y)
			
			' Положить в память старое изображение
			BitBlt(PlayerDealCardAnimationHDC, 0, 0, mintWidth, mintHeight, hDC, PlayerDealCardAnimationPointStart.X, PlayerDealCardAnimationPointStart.Y, SRCCOPY)
			
		Case 1
			' Восстановить изображение из памяти
			BitBlt(hDC, PlayerDealCardAnimationPointStart.X, PlayerDealCardAnimationPointStart.Y, mintWidth, mintHeight, PlayerDealCardAnimationHDC, 0, 0, SRCCOPY)
			
			' Увеличить координаты X и Y
			PlayerDealCardAnimationPointStart.X += IncrementX(BankDeck(PlayerDealCardAnimationCardSortNumber).X)
			PlayerDealCardAnimationPointStart.Y += IncrementY(BankDeck(PlayerDealCardAnimationCardSortNumber).Y)
			
			' Поместить в память изображение взяв оттуда где будет новое
			BitBlt(PlayerDealCardAnimationHDC, 0, 0, mintWidth, mintHeight, hDC, PlayerDealCardAnimationPointStart.X, PlayerDealCardAnimationPointStart.Y, SRCCOPY)
			' Нарисовать новое
			cdtDrawExt(hDC, PlayerDealCardAnimationPointStart.X, PlayerDealCardAnimationPointStart.Y, mintWidth, mintHeight, BankDeck(PlayerDealCardAnimationCardSortNumber).CardNumber, CardViews.Normal, 0)
			
			Dim dx As Integer = Abs(BankDeck(PlayerDealCardAnimationCardSortNumber).X - PlayerDealCardAnimationPointStart.X)
			Dim dy As Integer = Abs(BankDeck(PlayerDealCardAnimationCardSortNumber).Y - PlayerDealCardAnimationPointStart.Y)
			If dx < Abs(PlayerDealCardAnimationCardIncrementX) OrElse dy < Abs(PlayerDealCardAnimationCardIncrementY) Then
				' Как только будет достигнута последняя точка, то остановить таймер
				PlayerDealCardAnimationPointStartCount = 2
			End If
			
		Case 2
			' KillTimer(hWin, wParam)
			KillTimer(hWin, LeftEnemyDealCardTimerId)
			PlayerDealCardAnimationPointStartCount = 0
			' Восстановить изображение из памяти
			BitBlt(hDC, PlayerDealCardAnimationPointStart.X, PlayerDealCardAnimationPointStart.Y, mintWidth, mintHeight, PlayerDealCardAnimationHDC, 0, 0, SRCCOPY)
			
			' Сделать карту видимой на поле
			BankDeck(PlayerDealCardAnimationCardSortNumber).IsUsed = True
			
			' Нарисовать карту
			cdtDrawExt(hDC, BankDeck(PlayerDealCardAnimationCardSortNumber).X, BankDeck(PlayerDealCardAnimationCardSortNumber).Y, mintWidth, mintHeight, BankDeck(PlayerDealCardAnimationCardSortNumber).CardNumber, CardViews.Normal, 0)
			
			' Если на руках карт нет, то победа
			If IsPlayerWin(@LeftEnemyDeck(0)) Then
				' Победа
				PostMessage(hWin, PM_LENEMYWIN, 0, 0)
			Else
				' Передать ход правому врагу
				PostMessage(hWin, PM_RENEMYATTACK, 0, 0)
			End If
	End Select
	
	ReleaseDC(hWin, hDC)
End Sub

Sub PlayerDealCardTimer_Tick(ByVal hWin As HWND)
	' Если карт больше нет, то это победа
	If IsPlayerWin(@PlayerDeck(0)) Then
		' Победа
		PostMessage(hWin, PM_USERWIN, 0, 0)
	Else
		' Передать ход левому врагу
		PostMessage(hWin, PM_LENEMYATTACK, 0, 0)
	End If
End Sub

Sub BankDealCardTimer_Tick(ByVal hWin As HWND)
	' Анимация раздачи колоды
	Select Case BankDealCardAnimationStartCount
		Case 0
			' Колода исчезает
			' Do While BankDeck(BankDealCardAnimationCardNumber).IsUsed = False
				' BankDealCardAnimationCardNumber += 1
				' If BankDealCardAnimationCardNumber = 36 Then
					' BankDealCardAnimationCardNumber = 0
					' BankDealCardAnimationStartCount = 1
					' Exit Select
				' End If
			' Loop
			BankDeck(BankDealCardAnimationCardNumber).IsUsed = False
			Scope
				Dim hDC As HDC = GetDC(hWin)
				Dim OldPen As HPEN = SelectObject(hDC, DarkGreenPen)
				Dim OldBrush As HBRUSH = SelectObject(hDC, DarkGreenBrush)
				
				Dim NewNumber As Integer = GetBankCardNumberAnimateDealCard(BankDealCardAnimationCardNumber)
				
				Rectangle(hDC, BankDeck(NewNumber).X, BankDeck(NewNumber).Y, BankDeck(NewNumber).X + mintWidth, BankDeck(NewNumber).Y + mintHeight)
				
				SelectObject(hDC, OldPen)
				SelectObject(hDC, OldBrush)
				ReleaseDC(hWin, hDC)
			End Scope
			' Увеличить счётчик
			' Если вышли за границу, то перейти к следующему этапу анимации
			BankDealCardAnimationCardNumber += 1
			If BankDealCardAnimationCardNumber = 36 Then
				BankDealCardAnimationCardNumber = 0
				BankDealCardAnimationStartCount = 1
			End If
		Case 1
			' Появляются карты у правого персонажа
			Scope
				Dim hDC As HDC = GetDC(hWin)
				
				cdtDrawExt(hDC, RightEnemyDeck(BankDealCardAnimationCardNumber).X, RightEnemyDeck(BankDealCardAnimationCardNumber).Y, mintWidth, mintHeight, Backs.Sky, CardViews.Back, 0)
				
				ReleaseDC(hWin, hDC)
			End Scope
			BankDealCardAnimationCardNumber += 1
			If BankDealCardAnimationCardNumber = 12 Then
				BankDealCardAnimationCardNumber = 11
				BankDealCardAnimationStartCount = 2
			End If
		Case 2
			' Повляются карты у игрока
			Scope
				Dim hDC As HDC = GetDC(hWin)
				
				cdtDrawExt(hDC, PlayerDeck(BankDealCardAnimationCardNumber).X, PlayerDeck(BankDealCardAnimationCardNumber).Y, mintWidth, mintHeight, PlayerDeck(BankDealCardAnimationCardNumber).CardNumber, CardViews.Normal, 0)
				
				ReleaseDC(hWin, hDC)
			End Scope
			BankDealCardAnimationCardNumber -= 1
			If BankDealCardAnimationCardNumber = -1 Then
				BankDealCardAnimationCardNumber = 11
				BankDealCardAnimationStartCount = 3
			End If
		Case 3
			' Появляются карты у левого персонажа
			
			Scope
				Dim hDC As HDC = GetDC(hWin)
				
				If BankDealCardAnimationCardNumber <> 11 Then
					' Переместить в память
					BitBlt(PlayerDealCardAnimationHDC, 0, 0, mintWidth, LeftEnemyDeck(11).Y - LeftEnemyDeck(BankDealCardAnimationCardNumber + 1).Y + mintHeight, hDC, LeftEnemyDeck(BankDealCardAnimationCardNumber + 1).X, LeftEnemyDeck(BankDealCardAnimationCardNumber + 1).Y, SRCCOPY)
				End If
				
				' Нарисовать
				cdtDrawExt(hDC, LeftEnemyDeck(BankDealCardAnimationCardNumber).X, LeftEnemyDeck(BankDealCardAnimationCardNumber).Y, mintWidth, mintHeight, Backs.Sky, CardViews.Back, 0)
				
				' Переместить из памяти
				If BankDealCardAnimationCardNumber <> 11 Then
					BitBlt(hDC, LeftEnemyDeck(BankDealCardAnimationCardNumber + 1).X, LeftEnemyDeck(BankDealCardAnimationCardNumber + 1).Y, mintWidth, LeftEnemyDeck(11).Y - LeftEnemyDeck(BankDealCardAnimationCardNumber + 1).Y + mintHeight, PlayerDealCardAnimationHDC, 0, 0, SRCCOPY)
				End If
				
				ReleaseDC(hWin, hDC)
			End Scope
			
			BankDealCardAnimationCardNumber -= 1
			If BankDealCardAnimationCardNumber = -1 Then
				BankDealCardAnimationCardNumber = 0
				BankDealCardAnimationStartCount = 4
			End If
		Case 4
			' Закончилось
			KillTimer(hWin, BankDealCardTimerId)
			BankDealCardAnimationStartCount = 0
			
			' Найти того, у кого девятка бубен и сделать сделать его ход
			Dim cn As CharacterWithNine = GetNinePlayerNumber(@RightEnemyDeck(0), @PlayerDeck(0), @LeftEnemyDeck(0))
			Select Case cn.Char
				Case Characters.RightCharacter
					PostMessage(hWin, PM_RENEMYATTACK, cn.NineIndex, True)
				Case Characters.Player
					PostMessage(hWin, PM_USERATTACK, cn.NineIndex, True)
				Case Characters.LeftCharacter
					PostMessage(hWin, PM_LENEMYATTACK, cn.NineIndex, True)
			End Select
	End Select
End Sub

Sub BankDealMoneyTimer_Tick(ByVal hWin As HWND)
End Sub
