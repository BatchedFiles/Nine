#ifndef GDIGRAPHICS_BI
#define GDIGRAPHICS_BI

#ifndef unicode
#define unicode
#endif
#include once "windows.bi"

Type GdiGraphics
	Dim DeviceContext As HDC
	Dim Bitmap As HBITMAP
	Dim OldBitmap As HBITMAP
	Dim OldPen As HPEN
	Dim OldBrush As HBRUSH
	Dim OldFont As HFONT
End Type

Declare Sub InitializeGraphics(ByVal g As GdiGraphics Ptr, ByVal hWin As HWND, ByVal DefaultPen As HPEN, ByVal DefaultBrush As HBRUSH, ByVal DefaultFont As HFONT)

Declare Sub UnInitializeGraphics(ByVal g As GdiGraphics Ptr)

#endif
