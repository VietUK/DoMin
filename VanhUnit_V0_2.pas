{$APPTYPE CONSOLE}
{$MODE OBJFPC}
Unit VanhUnit_V0_2;
INTERFACE
uses dos, sysutils, windows, classes;
type
    trealregs = record
        case integer of
            1: { 32-bit } (EDI, ESI, EBP, Res, EBX, EDX, ECX, EAX: longint;
                           Flags, ES, DS, FS, GS, IP, CS, SP, SS: word);
            2: { 16-bit } (DI, DI2, SI, SI2, BP, BP2, R1, R2: word;
                           BX, BX2, DX, DX2, CX, CX2, AX, AX2: word);
            3: { 8-bit }  (stuff: array[1..4] of longint;
                           BL, BH, BL2, BH2, DL, DH, DL2, DH2,
                           CL, CH, CL2, CH2, AL, AH, AL2, AH2: byte);
            4: { Compat } (RealEDI, RealESI, RealEBP, RealRES,
                           RealEBX, RealEDX, RealECX, RealEAX: longint;
                           RealFlags,
                           RealES, RealDS, RealFS, RealGS,
                           RealIP, RealCS, RealSP, RealSS: word);
        end;
    tcrtcoord = 1..255;
Var
    ScreenWidth, ScreenHeight : longint;
    dosmemselector : word;
    WindMin: Word  = $0;  
    WindMax: Word  = $184f;
    TextAttr: Byte = $07;   
    DelayCnt : Longint; 
function  checkNumberInput(checkNumberInput_input: string): boolean;
procedure color(backgroundcolor_input, textcolor_input: char);
function  SoHoa(input_SoHoa: string): integer;
function  Set_console_fontsize(Fontsize: smallint {short}): integer;
procedure delay(delay_input: integer);
procedure clrscr;
procedure programTitle(programTitle_input: Pchar);
function  CharInc(CharInc_input: char):char;
procedure dpmi_dosmemfillword(seg,ofs : word;count : longint;w : word);
procedure seg_fillword(seg : word;ofs : longint;count : longint;w : word);
Procedure ClrEol(X,Y: integer);
procedure GotoXY(GotoXY_x, GotoXY_y: integer);
procedure installSRC;
procedure cursorOff;
procedure cursorOn;
function  ReadKey: Char;
procedure programTitleUnicode(programTitle_input: utf8string);
Procedure TextColor(Color: Byte);
const
    LF_FACESIZE    = 32;
    TextLarge      = 30;
    TextNormal     = 20;
    black          : byte   = 0;
    blue           : byte   = 1;
    green          : byte   = 2;
    aqua           : byte   = 3;
    red            : byte   = 4;
    purple         : byte   = 5;
    yellow         : byte   = 6;
    white          : byte   = 7;
    gray           : byte   = 8;
    lightblue      : byte   = 9;
    dosmemfillword : procedure(seg,ofs : word;count : longint;w : word)=@dpmi_dosmemfillword;
    zeroflag       = $040;
    Blink          = 128;
IMPLEMENTATION
var 
    VidSeg : Word;
    FilePath: string;
type
    CONSOLE_FONT_INFOEX = record
        cbSize      : ULONG;
        nFont       : DWORD;
        dwFontSizeX : SHORT;
        dwFontSizeY : SHORT;
        FontFamily  : UINT;
        FontWeight  : UINT; 
        FaceName    : array [0..LF_FACESIZE-1] of WCHAR;
    end;
procedure installSRC;
    begin
        FilePath := IncludeTrailingBackslash(ExtractFilePath(ParamStr(0)));
        exec('cmd', '/c echo off');
        exec('cmd', '/c mklink "C:\Vanh_Src" "'+ FilePath +'Vanh_Src" /J')
    end;
Function WinMinX: Byte;
    Begin
        WinMinX:=(WindMin and $ff)+1;
    End;
Procedure TextColor(Color: Byte);
    Begin
       TextAttr:=(Color and $8f) or (TextAttr and $70);
    End;
Function WinMinY: Byte;
    Begin
        WinMinY:=(WindMin shr 8)+1;
    End;
Function WinMaxX: Byte;
    Begin
        WinMaxX:=(WindMax and $ff)+1;
    End;
Function WinMaxY: Byte;
    Begin
        WinMaxY:=(WindMax shr 8) + 1;
    End;
Function FullWin:boolean;
    begin
        FullWin:=(WinMinX=1) and (WinMinY=1) and
                 (WinMaxX=ScreenWidth) and (WinMaxY=ScreenHeight);
    end;
procedure seg_fillword(seg : word;ofs : longint;count : longint;w : word);
    begin
        asm
            pushl %edi
            movl ofs,%edi
            movl count,%ecx
            movw w,%dx
            { load segment }
            pushw %es
            movw seg,%ax
            movw %ax,%es
            { fill eax }
            movw %dx,%ax
            shll $16,%eax
            movw %dx,%ax
            movl %ecx,%edx
            shrl $1,%ecx
            cld
            rep
            stosl
            movl %edx,%ecx
            andl $1,%ecx
            rep
            stosw
            popw %es
            popl %edi
        end;
    end;
procedure dpmi_dosmemfillword(seg,ofs : word;count : longint;w : word);
    begin
        seg_fillword(dosmemselector,seg*16+ofs,count,w);
    end;
function checkNumberInput(checkNumberInput_input: string): boolean;
    begin
        if 
            ((checkNumberInput_input = IntToStr(SoHoa(checkNumberInput_input))))
        then checkNumberInput:= true
        else checkNumberInput:= false;
    end;
procedure color(backgroundcolor_input, textcolor_input: char);
    var 
        color_string: string;
    begin
        color_string:= textcolor_input + backgroundcolor_input;
        exec('cmd','/c color ' + color_string)
    end;
function SoHoa(input_SoHoa: string): integer;
    begin
        val(input_SoHoa,SoHoa);
    end;    
procedure WindowsGenerator(WindowsGenerator_X, WindowsGenerator_Y:integer);
    begin
        exec('cmd', '/c mode ' + IntToStr(WindowsGenerator_X) + ',' + IntToStr(WindowsGenerator_Y));
    end;
function SetCurrentConsoleFontEx(hConsoleOutput: HANDLE; bMaximumWindow: BOOL; var CONSOLE_FONT_INFOEX): BOOL;
    stdcall; external 'kernel32.dll' name 'SetCurrentConsoleFontEx';
 
    {***************************************************}

function Set_console_fontsize(Fontsize: smallint {short}): integer; 
    const 
        Codepage: int64 = 65001; 
    var
        New_CONSOLE_FONT_INFOEX : CONSOLE_FONT_INFOEX;
        Rslt: boolean;
    begin
        SetConsoleOutputCP(Codepage);
        SetTextCodepage(Output, Codepage);
        FillChar(New_CONSOLE_FONT_INFOEX, SizeOf(CONSOLE_FONT_INFOEX), 0);
 
        with New_CONSOLE_FONT_INFOEX do
        begin
            cbSize := SizeOf(CONSOLE_FONT_INFOEX);
            nFont:= 0; 
            dwFontSizeX:= 0; {Values 0..100 don't seem to have any effect}
            dwFontSizeY:= Fontsize;
            FontFamily := FF_DONTCARE;  
            FaceName := 'Consolas';            
            FontWeight:= 400 
        end;
        Rslt:= SetCurrentConsoleFontEx(StdOutputHandle,false,New_CONSOLE_FONT_INFOEX);
        Set_console_fontsize:= Fontsize;
    end;
procedure delay(delay_input: integer);
    begin
        exec('cmd', '/c @echo off');
        exec('cmd', '/c timeout /T ' + IntToStr(delay_input));
    end;
procedure clrscr;
    begin
        exec('cmd','/c cls');
        GotoXY(1, 1);
    end;
procedure programTitle(programTitle_input: Pchar);
    begin
        SetConsoleOutputCP(CP_UTF8);
        SetConsoleTitle(programTitle_input);
    end;
procedure programTitleUnicode(programTitle_input: utf8string);
    begin
        exec('cmd','/c C:\Vanh_SRC\Tools\Title.exe '+ programTitle_input);
    end;
function CharInc(CharInc_input: char):char;
    begin
        CharInc:= IntToStr(sohoa(CharInc_input) + 1)[1];
    end;
Procedure ClrEol(X, Y: integer);
    var
        fil : word;
    Begin
        fil:=32 or (textattr shl 8);
        if x<=WinMaxX then
         DosmemFillword(VidSeg,((y-1)*ScreenWidth+(x-1))*2,WinMaxX-x+1,fil);
    End;
procedure GotoXY(GotoXY_x, GotoXY_y: integer);
    var 
        Coord: TCoord;
    begin
        Coord.X:= GotoXY_x - 1;
        Coord.Y:= GotoXY_y - 1;
        SetConsoleCursorPosition(GetStdHandle(STD_OUTPUT_HANDLE), Coord);
    end;
procedure cursorOff;
    begin
        exec('cmd','/c C:\Vanh_SRC\Tools\Cursor.exe -h');
    end;
procedure cursorOn;
    begin
        exec('cmd','/c C:\Vanh_SRC\Tools\Cursor.exe -s');
    end;
function ReadKey: Char;
    var
        Mode: DWORD = 0;
    begin
        if GetConsoleMode(TextRec(Input).Handle, Mode) then
         SetConsoleMode(TextRec(Input).Handle, 0);
        Read(Result);
        if Mode <> 0 then
         SetConsoleMode(TextRec(Input).Handle, Mode);
    end;
end.