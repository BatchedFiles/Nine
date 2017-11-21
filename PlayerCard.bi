#ifndef PLAYERCARD_BI
#define PLAYERCARD_BI

' Игроки
Enum Characters
	RightCharacter
	Player
	LeftCharacter
End Enum

' Ирок с индексом девятки в массиве
Type CharacterWithNine
	Dim Character As Characters
	Dim NineIndex As Integer
End Type

' Карта игрока
Type PlayerCard
	' Карта используется
	Dim IsUsed As Boolean
	
	' Координаты
	Dim X As Integer
	Dim Y As Integer
	
	' Номер карты для рисования
	Dim CardNumber As Integer
	
	' Порядковый номер карты для сортировки
	' Шестёрки самые младшие, тузы самые старшие
	Dim CardSortNumber As Integer
End Type

' Деньги
Type Money
	Const MaxCharacterNameLength As Integer = 511
	
	Dim CharacterName As WString * (MaxCharacterNameLength + 1)
	Dim Value As Integer
	
	Dim X As Integer
	Dim Y As Integer
End Type

' Возвращает номер карты из массива, которую можно положить на стол
' pc — массив карт игрока
' bc — массив карт на столе
Declare Function GetPlayerDealCard(ByVal pc as PlayerCard Ptr, ByVal bp As PlayerCard Ptr)As Integer

' Создание и перемешивание массива
Declare Sub ShuffleArray(ByVal a As Integer Ptr, ByVal length As Integer)

' Возвращает номер карты для отображения
Declare Function GetCardNumber(ByVal CardSortNumber As Integer)As Integer

' Возвращает порядковый номер карты
Declare Function GetClickPlayerCardNumber(ByVal pc As PlayerCard Ptr, ByVal X As Integer, ByVal Y As Integer)As Integer

' Персонаж выиграл
Declare Function IsPlayerWin(ByVal pc As PlayerCard Ptr)As Boolean

' Возвращает персонажа, у которого девятка бубен
Declare Function GetNinePlayerNumber(ByVal RightDeck As PlayerCard Ptr, ByVal PlayerDeck As PlayerCard Ptr, ByVal LeftDeck As PlayerCard Ptr)As CharacterWithNine

' Проверяет правильность выбора карты пользователем
Declare Function ValidatePlayerCardNumber(ByVal PlayerCardSortNumber As Integer, ByVal bp As PlayerCard Ptr)As Boolean

' Сортировка колоды игрока по мастям
Declare Sub SortCharacterPack(ByVal pc As PlayerCard Ptr)

' Возвращает номер карты в банке для анимации
Declare Function GetBankCardNumberAnimateDealCard(ByVal CardSortNumber As Integer)As Integer

#endif
