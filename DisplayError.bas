#include once "DisplayError.bi"

#ifndef unicode
#define unicode
#endif

#include once "windows.bi"
#include once "IntegerToWString.bi"

Sub DisplayError(ByVal ErrorCode As Integer, ByVal Caption As WString Ptr)
	Dim Buffer As WString * 100 = Any
	itow(ErrorCode, @Buffer, 10)
	MessageBox(0, @Buffer, Caption, MB_ICONERROR)
End Sub