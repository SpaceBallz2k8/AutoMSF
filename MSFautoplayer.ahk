#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#Include console_include.ahk
#Include amsf_cvars.ahk

;variables
global rtaLoss := 0
global rtaWin := 0
global arenaWin := 0
global arenaLoss := 0
global weAreHome := 0
global rtaLoops := 1

;GUI Code
Gui,1: +AlwaysOnTop
Gui,1:Font, s9, Segoe UI
Gui,1:Add, Picture, x0 y-8 w450 h253, C:\Users\Ballz\Downloads\marvelstrikeforce_lob_log_01.png
Gui,1:Add, Button, gfullAuto x24 y216 w80 h23, Auto
Gui,1:Add, Button, gautoArena x104 y216 w80 h23, Arena
Gui,1:Add, Button, gdecRta w20 h23 x184 y190,-
Gui,1:Add, Text, x219 y195 w20 vmyRTA, %rtaLoops%
Gui,1:Add, Button, gincRta w20 h23 x244 y190,+
Gui,1:Add, Button, gautoRta x184 y216 w80 h23, RTA
Gui,1:Add, Button, x264 y216 w80 h23, Collect
Gui,1:Add, Button, gupdateVars x264 y190 w160 h23, Update Vars
Gui,1:Add, Button, gGuiClose x344 y216 w80 h23, Quit
Gui,1:Add, StatusBar,h20 w10, Arena Win/Loss %arenaWin%/%arenaLoss% - RTA Win/Loss %rtaWin%/%rtaLoss% - RTA Loops:%rtaLoops%
Gui,1:Show, x1440 y720 w449 h266, Marvel Strike Force Autoplayer
Return

; Functions & Routines
findClickLocation(Location){
	Loop {
		if ok:=FindText(0,0,150000,150000,0,0,Location)
		{
			CoordMode, Mouse
			X:=ok.1, Y:=ok.2, W:=ok.3, H:=ok.4, Comment:=ok.5
			MouseClick, Left, X+W//2, Y+H//2 
			break
		}
	}	
}

updateVars(){
	url := "https://home.ballz.uk/amsf_cvars.ahk"
	filename := "amsf_cvars.ahk"
	whr := ComObjCreate("WinHttp.WinHttpRequest.5.1")
	whr.Open("GET", "https://home.ballz.uk/autoMSF.txt", true)
	whr.Send()
; Using 'true' above and the call below allows the script to remain responsive.
	whr.WaitForResponse() ;this is taken from the installer. Can also be located as an example on the urldownloadtofile page of the quick reference guide.
	version := whr.ResponseText
	if(myVer != version){
		FileDelete, %A_WorkingDir%\%Filename%
		UrlDownloadToFile, *0 %url%, %A_WorkingDir%\%Filename%
		Reload
	} else {
		MsgBox,,Updater, Your cvar file is already upto date
	}
}

updateStatus(){
	SB_SetText("Arena Win/Loss " . arenaWin . "/" . arenaLoss . " - RTA Win/Loss " . rtaWin . "/" . rtaLoss . " - RTA Loops:" . rtaLoops)
}

incRta(){ 
	rtaLoops += 1
	GuiControl, , myRTA, %rtaLoops%
	updateStatus()
}

decRta(){
	rtaLoops -= 1
	if(rtaLoops <= 1){
		rtaLoops := 1
	}
	GuiControl, , myRTA, %rtaLoops%
	updateStatus()
}

closeOffers(){
	if(findLocation(closeOffer)){
		findClickLocation(closeOffer)
	}
	return
}

findLocation(Location){
	if ok:=FindText(0,0,150000,150000,0,0,Location)
	{
		return true
	}
	else
	{
		return false
	}
}

moveFullLeft(){
	CoordMode Mouse
	Loop,10{
		MouseClickDrag, left, 720, 500, 1220, 500, 15
		}
}

moveFullRight(){
	CoordMode Mouse
	Loop,10{
		MouseClickDrag, left, 720, 500, 220, 500, 15
	}
}

goHome(){
	if(!findLocation(homeCog)){
		if(findLocation(closeOffer)){
			findClickLocation(closeOffer)
			return		
		}
		if(findLocation(mainMenuHouse)){
			findClickLocation(mainMenuHouse)
			return
		}
		weAreHome :=1
	}
}

autoRta(){
	goHome()
	Loop,%rtaLoops%{
		moveFullRight()
		sleep, 1000
		findClickLocation(mainMenuRTA)
		sleep, 1000
		findClickLocation(rtaBattle)
		sleep, 1000
		findClickLocation(rtaReady)
		sleep, 20000
		goAuto()
		;findClickLocation(theWordAuto)
		sleep, 60000 ; sleep for a minute, the match is running
		;loop { ; check see if the match is still going by looking for auto
		;	if(!findLocation(theWordAuto)){
		;		sleep, 20000
		;		break
		;	}
		;	sleep, 10000 ; if auto is still there, wait 10 seconds
		;}
		loop{
			if(findLocation(rtaContinue)){ ; look for continue button (page loaded) then look to see if we won
				break
			}
			sleep, 2000
		}
		if(findLocation(rtaVictory)){ ; did we win, if no we lost
			rtaWin += 1
		} else {
			rtaLoss += 1
		}
		sleep, 2000
		findClickLocation(rtaContinue) ; end the match
		goHome() ; go main menu
		updateStatus() ; update statusbar
	}
	
}

goAuto(){
	Loop, {
		if(findLocation(speechBubble)){
			sleep, 2000
			CoordMode, mouse, Relative
			MouseClick, left, 50, 159
			break
		}
	}
}

autoArena(){
	goHome()
	moveFullLeft()
	sleep, 1000
	findClickLocation(mainMenuArena)
	sleep, 1000
	findClickLocation(arenaGo)
	sleep, 2000
	Random, whichButton, 1, 3
	sleep, 5000
	if((!findLocation(battleOneArena))||(!findLocation(battleTwoArena))||(!findLocation(battleThreeArena))){ ; arena battle buttons not there, timer must be running or were out of attempts
		goHome()
		return
	}
	if(whichButton = 1){
		findClickLocation(battleOneArena)
	}
	if(whichButton = 2){
		findClickLocation(battleTwoArena)
	}
	if(whichButton = 3){
		findClickLocation(battleThreeArena)
	}
	sleep, 5000
	findClickLocation(arenaReady)
	sleep, 10000 ; wait 10 seconds, game loading
	;findClickLocation(theWordAuto)
	goAuto()
	sleep, 2000
	if(findLocation(arenaSpeedOne)){
		findClickLocation(arenaSpeedOne)
	}
	if(findLocation(arenaSpeedTwo)){
		findClickLocation(arenaSpeedTwo)
	}
	if(findLocation(arenaSpeedThree)){
		; already on 3x
	}
	sleep, 60000 ; sleep for a minute battle running
	;loop { ; check see if the match is still going by looking for auto
	;	if(!findLocation(theWordAuto)){
	;		sleep, 10000
	;		break
	;	}
	;	sleep, 10000 ; if auto is still there, wait 10 seconds
	;}
	loop{
		if(findLocation(arenaContinue)){ ; look for continue button (page loaded) then look to see if we won
			break
		}
		sleep, 2000
	}
	if(findLocation(arenaDefeat)){
		arenaLoss += 1
	} else {
		arenaWin += 1
	}
	findClickLocation(arenaContinue)
	updateStatus()
	goHome()
}

fullAuto(){
	Loop{
		autoArena()
		sleep, 5000
		autoRta()
		sleep, 5000
		autoRta()
		sleep, 5000
		autoRta()
		sleep, 5000
	}
}
	
	GuiEscape:
	GuiClose:
	ExitApp
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	FindText(x,y,w,h,err1,err0,text)
	{
		xywh2xywh(x-w,y-h,2*w+1,2*h+1,x,y,w,h)
		if (w<1 or h<1)
			return, 0
		bch:=A_BatchLines
		SetBatchLines, -1
  ;--------------------------------------
		GetBitsFromScreen(x,y,w,h,Scan0,Stride,bits)
  ;--------------------------------------
		sx:=0, sy:=0, sw:=w, sh:=h, arr:=[]
		Loop, 2 {
			Loop, Parse, text, |
			{
				v:=A_LoopField
				IfNotInString, v, $, Continue
					Comment:="", e1:=err1, e0:=err0
    ; You Can Add Comment Text within The <>
				if RegExMatch(v,"<([^>]*)>",r)
					v:=StrReplace(v,r), Comment:=Trim(r1)
    ; You can Add two fault-tolerant in the [], separated by commas
				if RegExMatch(v,"\[([^\]]*)]",r)
				{
					v:=StrReplace(v,r), r1.=","
					StringSplit, r, r1, `,
					e1:=r1, e0:=r2
				}
				StringSplit, r, v, $
				color:=r1, v:=r2
				StringSplit, r, v, .
				w1:=r1, v:=base64tobit(r2), h1:=StrLen(v)//w1
				if (r0<2 or h1<1 or w1>sw or h1>sh or StrLen(v)!=w1*h1)
					Continue
    ;--------------------------------------------
				if InStr(color,"-")
				{
					r:=e1, e1:=e0, e0:=r, v:=StrReplace(v,"1","_")
					v:=StrReplace(StrReplace(v,"0","1"),"_","0")
				}
				mode:=InStr(color,"*") ? 1:0
				color:=RegExReplace(color,"[*\-]") . "@"
				StringSplit, r, color, @
				color:=Round(r1), n:=Round(r2,2)+(!r2)
				n:=Floor(255*3*(1-n)), k:=StrLen(v)*4
				VarSetCapacity(ss, sw*sh, Asc("0"))
				VarSetCapacity(s1, k, 0), VarSetCapacity(s0, k, 0)
				VarSetCapacity(rx, 8, 0), VarSetCapacity(ry, 8, 0)
				len1:=len0:=0, j:=sw-w1+1, i:=-j
				ListLines, Off
				Loop, Parse, v
				{
					i:=Mod(A_Index,w1)=1 ? i+j : i+1
					if A_LoopField
						NumPut(i, s1, 4*len1++, "int")
					else
						NumPut(i, s0, 4*len0++, "int")
				}
				ListLines, On
				e1:=Round(len1*e1), e0:=Round(len0*e0)
    ;--------------------------------------------
				if PicFind(mode,color,n,Scan0,Stride,sx,sy,sw,sh
      ,ss,s1,s0,len1,len0,e1,e0,w1,h1,rx,ry)
				{
					rx+=x, ry+=y
					arr.Push(rx,ry,w1,h1,Comment)
				}
			}
			if (arr.MaxIndex())
				Break
			if (A_Index=1 and err1=0 and err0=0)
				err1:=0.05, err0:=0.05
			else Break
		}
		SetBatchLines, %bch%
		return, arr.MaxIndex() ? arr:0
	}
	
	PicFind(mode, color, n, Scan0, Stride
  , sx, sy, sw, sh, ByRef ss, ByRef s1, ByRef s0
  , len1, len0, err1, err0, w, h, ByRef rx, ByRef ry)
	{
		static MyFunc
		if !MyFunc
		{
			x32:="5589E583EC408B45200FAF45188B551CC1E20201D08945F"
    . "48B5524B80000000029D0C1E00289C28B451801D08945D8C74"
    . "5F000000000837D08000F85F00000008B450CC1E81025FF000"
    . "0008945D48B450CC1E80825FF0000008945D08B450C25FF000"
    . "0008945CCC745F800000000E9AC000000C745FC00000000E98"
    . "A0000008B45F483C00289C28B451401D00FB6000FB6C02B45D"
    . "48945EC8B45F483C00189C28B451401D00FB6000FB6C02B45D"
    . "08945E88B55F48B451401D00FB6000FB6C02B45CC8945E4837"
    . "DEC007903F75DEC837DE8007903F75DE8837DE4007903F75DE"
    . "48B55EC8B45E801C28B45E401D03B45107F0B8B55F08B452C0"
    . "1D0C600318345FC018345F4048345F0018B45FC3B45240F8C6"
    . "AFFFFFF8345F8018B45D80145F48B45F83B45280F8C48FFFFF"
    . "FE9A30000008B450C83C00169C0E803000089450CC745F8000"
    . "00000EB7FC745FC00000000EB648B45F483C00289C28B45140"
    . "1D00FB6000FB6C069D02B0100008B45F483C00189C18B45140"
    . "1C80FB6000FB6C069C04B0200008D0C028B55F48B451401D00"
    . "FB6000FB6C06BC07201C83B450C730B8B55F08B452C01D0C60"
    . "0318345FC018345F4048345F0018B45FC3B45247C948345F80"
    . "18B45D80145F48B45F83B45280F8C75FFFFFF8B45242B45488"
    . "3C0018945488B45282B454C83C00189454C8B453839453C0F4"
    . "D453C8945D8C745F800000000E9E3000000C745FC00000000E"
    . "9C70000008B45F80FAF452489C28B45FC01D08945F48B45408"
    . "945E08B45448945DCC745F000000000EB708B45F03B45387D2"
    . "E8B45F08D1485000000008B453001D08B108B45F401D089C28"
    . "B452C01D00FB6003C31740A836DE001837DE00078638B45F03"
    . "B453C7D2E8B45F08D1485000000008B453401D08B108B45F40"
    . "1D089C28B452C01D00FB6003C30740A836DDC01837DDC00783"
    . "08345F0018B45F03B45D87C888B551C8B45FC01C28B4550891"
    . "08B55208B45F801C28B45548910B801000000EB2990EB01908"
    . "345FC018B45FC3B45480F8C2DFFFFFF8345F8018B45F83B454"
    . "C0F8C11FFFFFFB800000000C9C25000"
			x64:="554889E54883EC40894D10895518448945204C894D288B4"
    . "5400FAF45308B5538C1E20201D08945F48B5548B8000000002"
    . "9D0C1E00289C28B453001D08945D8C745F000000000837D100"
    . "00F85000100008B4518C1E81025FF0000008945D48B4518C1E"
    . "80825FF0000008945D08B451825FF0000008945CCC745F8000"
    . "00000E9BC000000C745FC00000000E99A0000008B45F483C00"
    . "24863D0488B45284801D00FB6000FB6C02B45D48945EC8B45F"
    . "483C0014863D0488B45284801D00FB6000FB6C02B45D08945E"
    . "88B45F44863D0488B45284801D00FB6000FB6C02B45CC8945E"
    . "4837DEC007903F75DEC837DE8007903F75DE8837DE4007903F"
    . "75DE48B55EC8B45E801C28B45E401D03B45207F108B45F0486"
    . "3D0488B45584801D0C600318345FC018345F4048345F0018B4"
    . "5FC3B45480F8C5AFFFFFF8345F8018B45D80145F48B45F83B4"
    . "5500F8C38FFFFFFE9B60000008B451883C00169C0E80300008"
    . "94518C745F800000000E98F000000C745FC00000000EB748B4"
    . "5F483C0024863D0488B45284801D00FB6000FB6C069D02B010"
    . "0008B45F483C0014863C8488B45284801C80FB6000FB6C069C"
    . "04B0200008D0C028B45F44863D0488B45284801D00FB6000FB"
    . "6C06BC07201C83B451873108B45F04863D0488B45584801D0C"
    . "600318345FC018345F4048345F0018B45FC3B45487C848345F"
    . "8018B45D80145F48B45F83B45500F8C65FFFFFF8B45482B859"
    . "000000083C0018985900000008B45502B859800000083C0018"
    . "985980000008B45703945780F4D45788945D8C745F80000000"
    . "0E90B010000C745FC00000000E9EC0000008B45F80FAF45488"
    . "9C28B45FC01D08945F48B85800000008945E08B85880000008"
    . "945DCC745F000000000E9800000008B45F03B45707D368B45F"
    . "04898488D148500000000488B45604801D08B108B45F401D04"
    . "863D0488B45584801D00FB6003C31740A836DE001837DE0007"
    . "8778B45F03B45787D368B45F04898488D148500000000488B4"
    . "5684801D08B108B45F401D04863D0488B45584801D00FB6003"
    . "C30740A836DDC01837DDC00783C8345F0018B45F03B45D80F8"
    . "C74FFFFFF8B55388B45FC01C2488B85A000000089108B55408"
    . "B45F801C2488B85A80000008910B801000000EB2F90EB01908"
    . "345FC018B45FC3B85900000000F8C05FFFFFF8345F8018B45F"
    . "83B85980000000F8CE6FEFFFFB8000000004883C4405DC390"
			MCode(MyFunc, A_PtrSize=8 ? x64:x32)
		}
		return, DllCall(&MyFunc, "int",mode
    , "uint",color, "int",n, "ptr",Scan0, "int",Stride
    , "int",sx, "int",sy, "int",sw, "int",sh
    , "ptr",&ss, "ptr",&s1, "ptr",&s0
    , "int",len1, "int",len0, "int",err1, "int",err0
    , "int",w, "int",h, "int*",rx, "int*",ry)
	}
	
	xywh2xywh(x1,y1,w1,h1,ByRef x,ByRef y,ByRef w,ByRef h)
	{
		SysGet, zx, 76
		SysGet, zy, 77
		SysGet, zw, 78
		SysGet, zh, 79
		left:=x1, right:=x1+w1-1, up:=y1, down:=y1+h1-1
		left:=left<zx ? zx:left, right:=right>zx+zw-1 ? zx+zw-1:right
		up:=up<zy ? zy:up, down:=down>zy+zh-1 ? zy+zh-1:down
		x:=left, y:=up, w:=right-left+1, h:=down-up+1
	}
	
	GetBitsFromScreen(x,y,w,h,ByRef Scan0,ByRef Stride,ByRef bits)
	{
		VarSetCapacity(bits,w*h*4,0), bpp:=32
		Scan0:=&bits, Stride:=((w*bpp+31)//32)*4
		Ptr:=A_PtrSize ? "UPtr" : "UInt", PtrP:=Ptr . "*"
		win:=DllCall("GetDesktopWindow", Ptr)
		hDC:=DllCall("GetWindowDC", Ptr,win, Ptr)
		mDC:=DllCall("CreateCompatibleDC", Ptr,hDC, Ptr)
  ;-------------------------
		VarSetCapacity(bi, 40, 0), NumPut(40, bi, 0, "int")
		NumPut(w, bi, 4, "int"), NumPut(-h, bi, 8, "int")
		NumPut(1, bi, 12, "short"), NumPut(bpp, bi, 14, "short")
  ;-------------------------
		if hBM:=DllCall("CreateDIBSection", Ptr,mDC, Ptr,&bi
    , "int",0, PtrP,ppvBits, Ptr,0, "int",0, Ptr)
		{
			oBM:=DllCall("SelectObject", Ptr,mDC, Ptr,hBM, Ptr)
			DllCall("BitBlt", Ptr,mDC, "int",0, "int",0, "int",w, "int",h
      , Ptr,hDC, "int",x, "int",y, "uint",0x00CC0020|0x40000000)
			DllCall("RtlMoveMemory","ptr",Scan0,"ptr",ppvBits,"ptr",Stride*h)
			DllCall("SelectObject", Ptr,mDC, Ptr,oBM)
			DllCall("DeleteObject", Ptr,hBM)
		}
		DllCall("DeleteDC", Ptr,mDC)
		DllCall("ReleaseDC", Ptr,win, Ptr,hDC)
	}
	
	base64tobit(s)
	{
		ListLines, Off
		Chars:="0123456789+/ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    . "abcdefghijklmnopqrstuvwxyz"
		SetFormat, IntegerFast, d
		StringCaseSense, On
		Loop, Parse, Chars
		{
			i:=A_Index-1, v:=(i>>5&1) . (i>>4&1)
      . (i>>3&1) . (i>>2&1) . (i>>1&1) . (i&1)
			s:=StrReplace(s,A_LoopField,v)
		}
		StringCaseSense, Off
		s:=SubStr(s,1,InStr(s,"1",0,0)-1)
		s:=RegExReplace(s,"[^01]+")
		ListLines, On
		return, s
	}
	
	bit2base64(s)
	{
		ListLines, Off
		s:=RegExReplace(s,"[^01]+")
		s.=SubStr("100000",1,6-Mod(StrLen(s),6))
		s:=RegExReplace(s,".{6}","|$0")
		Chars:="0123456789+/ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    . "abcdefghijklmnopqrstuvwxyz"
		SetFormat, IntegerFast, d
		Loop, Parse, Chars
		{
			i:=A_Index-1, v:="|" . (i>>5&1) . (i>>4&1)
      . (i>>3&1) . (i>>2&1) . (i>>1&1) . (i&1)
			s:=StrReplace(s,v,A_LoopField)
		}
		ListLines, On
		return, s
	}
	
	ASCII(s){
		if RegExMatch(s,"(\d+)\.([\w+/]{3,})",r)
		{
			s:=RegExReplace(base64tobit(r2),".{" r1 "}","$0`n")
			s:=StrReplace(StrReplace(s,"0","_"),"1","0")
		}
		else s=
			return, s
	}
	
	MCode(ByRef code, hex){
		ListLines, Off
		bch:=A_BatchLines
		SetBatchLines, -1
		VarSetCapacity(code, StrLen(hex)//2)
		Loop, % StrLen(hex)//2
			NumPut("0x" . SubStr(hex,2*A_Index-1,2), code, A_Index-1, "char")
		Ptr:=A_PtrSize ? "UPtr" : "UInt"
		DllCall("VirtualProtect", Ptr,&code, Ptr
    ,VarSetCapacity(code), "uint",0x40, Ptr . "*",0)
		SetBatchLines, %bch%
		ListLines, On
	}
	
; You can put the text library at the beginning of the script, and Use Pic(Text,1) to add the text library to Pic()'s Lib,
; Use Pic("comment1|comment2|...") to get text images from Lib
	Pic(comments, add_to_Lib=0) {
		static Lib:=[]
		if (add_to_Lib)
		{
			re:="<([^>]*)>[^$]+\$\d+\.[\w+/]{3,}"
			Loop, Parse, comments, |
				if RegExMatch(A_LoopField,re,r)
					Lib[Trim(r1)]:=r
		}
		else
		{
			text:=""
			Loop, Parse, comments, |
				text.="|" . Lib[Trim(A_LoopField)]
			return, text
		}
	}
	return
	
	Specify_Area:
	run FindText_get_coordinates.ahk
	return
	
	
	
	
