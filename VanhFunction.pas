{$APPTYPE CONSOLE}
{$MODE OBJFPC}
unit VanhFunction; 
interface

uses dos, sysutils, windows, classes;

var 
    WindMin: Word  = $0;  
    WindMax: Word  = $184f;
{$i VanhConst.inc}
Function WinMinX                                         : Byte;
Function WinMaxX                                         : Byte;
function checkNumberInput(checkNumberInput_input: string): boolean;
function SoHoa           (input_SoHoa: string)           : integer;
function CharInc         (CharInc_input: char)           : char;
function ReadKey                                         : Char;
function ScreenCursorPascal                              : tcoord;
function ScreenCursorSystem                              : tcoord;
function ConsoleSize                                     : tcoord;
function SadEmoji                                        : string;
function TextProperties  (color, background: byte)       : byte;
function VanhRandom      (inp: byte)                     : byte;

implementation

    function VanhRandom(inp: byte): byte;
    var
        VanhRandom_out: byte;
    begin
        VanhRandom_out:= VVanhRandom;
        inc(VanhRandom_out);
        if VanhRandom_out >= inp 
        then 
         begin
            VanhRandom:= 1;
            VVanhRandom:= 1;
         end
        else
         begin 
            VanhRandom:= VanhRandom_out;
            VVanhRandom:= VanhRandom_out;
         end;
    end;

    function TextProperties(color, background: byte): byte;
    begin
        TextProperties:=(Color and $8f) or (TextProperties and $70);
        TextProperties:=((background shl 4) and ($f0 and not Blink)) or (TextProperties and ($0f OR Blink) );
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

    function ScreenCursorSystem: tcoord;
    var
        ConsoleInfo : TConsoleScreenBufferInfo;
    begin
        FillChar(ConsoleInfo, SizeOf(ConsoleInfo), 0);
        GetConsoleScreenBufferInfo(
            GetStdHandle(STD_OUTPUT_HANDLE), 
            ConsoleInfo
        );
        ScreenCursorSystem.X := ConsoleInfo.dwCursorPosition.X;
        ScreenCursorSystem.Y := ConsoleInfo.dwCursorPosition.Y;
    end;

    function ScreenCursorPascal: tcoord;
    var
        ConsoleInfo : TConsoleScreenBufferInfo;
    begin
        FillChar(ConsoleInfo, SizeOf(ConsoleInfo), 0);
        GetConsoleScreenBufferInfo(
            GetStdHandle(STD_OUTPUT_HANDLE), 
            ConsoleInfo
        );
        ScreenCursorPascal.X := ConsoleInfo.dwCursorPosition.X + 1;
        ScreenCursorPascal.Y := ConsoleInfo.dwCursorPosition.Y + 1;
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

    function SadEmoji: string;
    var 
        SadEmoji_arr: array[1..3] of string;
    begin
        randomize;
        SadEmoji_arr[1]:= ':(';
        SadEmoji_arr[2]:= '';
        SadEmoji_arr[3]:= '';
        SadEmoji:= SadEmoji_arr[1];
    end;
Initialization
    VVanhRandom:= 1;
end.