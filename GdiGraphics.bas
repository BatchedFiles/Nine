#include "GdiGraphics.bi"

Sub InitializeGraphics( _
		ByVal g As GdiGraphics Ptr, _
		ByVal hWin As HWND, _
		ByVal DefaultPen As HPEN, _
		ByVal DefaultBrush As HBRUSH, _
		ByVal DefaultFont As HFONT _
	)
	
	g->DeviceContext = CreateCompatibleDC(0)
	
	Scope
		Dim hDCmem As HDC = GetDC(hWin)
		g->Bitmap = CreateCompatibleBitmap(hDCmem, GetDeviceCaps(g->DeviceContext, HORZRES), GetDeviceCaps(g->DeviceContext, VERTRES))
		ReleaseDC(hWin, hDCmem)
	End Scope
	
	g->OldBitmap = SelectObject(g->DeviceContext, g->Bitmap)
	g->OldPen = SelectObject(g->DeviceContext, DefaultPen)
	g->OldBrush = SelectObject(g->DeviceContext, DefaultBrush)
	g->OldFont = SelectObject(g->DeviceContext, DefaultFont)
	
End Sub

Sub UnInitializeGraphics( _
		ByVal g As GdiGraphics Ptr _
	)
	
	SelectObject(g->DeviceContext, g->OldFont)
	SelectObject(g->DeviceContext, g->OldBrush)
	SelectObject(g->DeviceContext, g->OldPen)
	SelectObject(g->DeviceContext, g->OldBitmap)
	DeleteObject(g->Bitmap)
	DeleteDC(g->DeviceContext)
	
End Sub
