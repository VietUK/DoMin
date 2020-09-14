{$APPTYPE CONSOLE}
{$MODE OBJFPC}
unit VanhFunction; 
interface

uses dos, sysutils, windows, classes;

var 
    WindMin: Word  = $0;  
    WindMax: Word  = $184f;
Function WinMinX: Byte;
Function WinMaxX: Byte;
function checkNumberInput(checkNumberInput_input: string): boolean;
function SoHoa(input_SoHoa: string): integer;
function Set_console_fontsize(Fontsize: smallint {short}): integer;
function CharInc(CharInc_input: char):char;
function ReadKey: Char;
function ScreenCursor: tcoord;
function ConsoleSize: tcoord;

implementation
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

    function ConsoleSize: tcoord;
    var
        ConsoleInfo : TConsoleScreenBufferInfo;
    begin
        FillChar(ConsoleInfo, SizeOf(ConsoleInfo), 0);
        GetConsoleScreenBufferInfo(
            GetStdHandle(STD_OUTPUT_HANDLE), 
            ConsoleInfo
        );
        ConsoleSize.X := ConsoleInfo.dwMaximumWindowSize.X;
        ConsoleSize.Y := ConsoleInfo.dwMaximumWindowSize.Y;
    end;

    function ScreenCursor: tcoord;
    var
        ConsoleInfo : TConsoleScreenBufferInfo;
    begin
        FillChar(ConsoleInfo, SizeOf(ConsoleInfo), 0);
        GetConsoleScreenBufferInfo(
            GetStdHandle(STD_OUTPUT_HANDLE), 
            ConsoleInfo
        );
        ScreenCursor.X := ConsoleInfo.dwCursorPosition.X;
        ScreenCursor.Y := ConsoleInfo.dwCursorPosition.Y;
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
        {SetTextCodepage(Output, Codepage);}
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

    function SoHoa(input_SoHoa: string): integer;
    begin
        val(input_SoHoa,SoHoa);
    end;

    function checkNumberInput(checkNumberInput_input: string): boolean;
    begin
        if 
            ((checkNumberInput_input = IntToStr(SoHoa(checkNumberInput_input))))
        then checkNumberInput:= true
        else checkNumberInput:= false;
    end;

    Function WinMinX: Byte;
    Begin
        WinMinX:=(WindMin and $ff)+1;
    End;

    Function WinMaxX: Byte;
    Begin
        WinMaxX:=(WindMax and $ff)+1;
    End;

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

    function CharInc(CharInc_input: char):char;
    begin
        CharInc:= IntToStr(sohoa(CharInc_input) + 1)[1];
    end;
end.