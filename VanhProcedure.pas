{$APPTYPE CONSOLE}
{$codepage utf8}
unit VanhProcedure;
interface

uses dos, sysutils, windows, classes, VanhFunction; 

var
    dosmemselector            : word;
    ScreenWidth, ScreenHeight : longint;
    SaveCursorSize            : Longint;
{$i VanhConst.inc}
{$DEFINE FPC_CRT_CTRLC_TREATED_AS_KEY}

Procedure TextColor       (Color: Byte);
Procedure TextBackground  (Color: Byte);
procedure WindowsGenerator(WindowsGenerator_X, WindowsGenerator_Y: integer);
procedure clrscr;
Procedure GotoXY          (GotoXY_X, GotoXY_Y: tcrtcoord);
Procedure ClrEol;
procedure ConsoleColor    (textcolor_inp, backgroundcolor_inp: Byte);
procedure cursoron;
procedure cursoroff;
procedure cursorbig;
procedure Delay           (MS: Word);
procedure programTitle    (programTitle_inp: pchar);
procedure installSRC;
procedure TVWrite         (TVWrite_inp: string; color, background: Byte);
procedure TVWriteln       (TVWriteln_inp: string; color, background: Byte);
procedure CharPrint       (CharPrint_inp: Char);
procedure removeline      (y : DWord);
procedure StringPrint     (StringPrint_inp: string);
procedure NormVideo;
procedure LowVideo;
procedure HighVideo;
Procedure SetConFont      (Fontsize: smallint {short}); 
const 
    TextLarge      = 30;
    TextNormal     = 20;
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

    var
        ConsoleInfo : TConsoleScreenBufferinfo;

    function SetCurrentConsoleFontEx(hConsoleOutput: HANDLE; bMaximumWindow: BOOL; var CONSOLE_FONT_INFOEX): BOOL;
    stdcall; external 'kernel32.dll' name 'SetCurrentConsoleFontEx';
 
    {***************************************************}

    Procedure SetConFont(Fontsize: smallint {short}); 
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
    end;

    procedure removeline(y : DWord);
    var
        ClipRect: TSmallRect;
        SrcRect : TSmallRect;
        DestCoor: TCoord;
        CharInfo: TCharInfo;
    begin
        CharInfo.UnicodeChar := #32;
        CharInfo.Attributes := TextAttr;

        Y := (WindMinY - 1) + (Y - 1) + 1;

        SrcRect.Top    := Y;
        SrcRect.Left   := WindMinX - 1;
        SrcRect.Right  := ConsoleSize.X - 1;
        SrcRect.Bottom := ConsoleSize.Y - 1;

        DestCoor.X := WindMinX - 1;
        DestCoor.Y := Y - 1;

        ClipRect := SrcRect;
        cliprect.top := destcoor.y;

        ScrollConsoleScreenBuffer(
            GetStdHandle(STD_OUTPUT_HANDLE), 
            SrcRect, 
            ClipRect,
            DestCoor, 
            CharInfo
        );
    end;

    procedure colorFiller(X, Y, writebyte: Byte);
    begin
        GotoXY(X, Y);
        WriteConsoleOutputAttribute(
            GetStdHandle(STD_OUTPUT_HANDLE),
            @writebyte,
            1,
            ScreenCursorSystem,
            write_num
        );
    end;
    
    procedure VanhWrite(VanhWrite_inp: string; color, background: Byte);
    type
        tcursor = record
            first: TCoord;
            final: TCoord;
        end;
    var
         VanhWrite_cursor
        : tcursor;
         VanhWrite_i     
        : integer;
         color2,
         background2
        : Byte;
    begin
        VanhWrite_cursor.first:= ScreenCursorPascal;
        SetMultiByteConversionCodePage(CP_UTF8);
        SetMultiByteRTLFileSystemCodePage(CP_UTF8);
        SetConsoleOutputCP(CP_UTF8);
        Write(VanhWrite_inp);
        VanhWrite_cursor.final:= ScreenCursorPascal;
        if CursorInfo.bVisible = false then inc(VanhWrite_cursor.final.X);
        
        for VanhWrite_i:= VanhWrite_cursor.first.X 
                          to 
                           VanhWrite_cursor.final.X - 1
        do begin
            if color = randomN then 
             begin
                color2:= vanhrandom(16);
                While (color2 = 8) or (color2 = 7) or (color2 = background2) do color2:= vanhrandom(16);
             end
            else 
                color2:= color;
            if background = randomN then 
             begin
                background2:= vanhrandom(15);
                While (background2 = 8) or (background2 = 7) or (background2 = color2) do background2:= vanhrandom(15);
             end
            else 
                background2:= background;
            colorFiller(VanhWrite_i, VanhWrite_cursor.first.Y, TextProperties(color2, background2));
        end;

        if CursorInfo.bVisible = true then GotoXY(VanhWrite_cursor.final.X, VanhWrite_cursor.final.Y);
    end;

    procedure TVWriteln(TVWriteln_inp: string; color, background: Byte);
    begin
        if TVWriteln_inp <> '' 
        then VanhWrite(TVWriteln_inp, color, background);
        GotoXY(WindMinX, ScreenCursorPascal.Y + 1);
    end;

    procedure TVWrite(TVWrite_inp: string; color, background: Byte);
    begin
        VanhWrite(TVWrite_inp, color, background);
    end;

    procedure WindowsGenerator(WindowsGenerator_X, WindowsGenerator_Y:integer);
    begin
        exec('cmd', '/c mode ' + IntToStr(WindowsGenerator_X) + ',' + IntToStr(WindowsGenerator_Y));
    end;

    procedure installSRC;
    var 
        FilePath: string;
    begin
        FilePath := IncludeTrailingBackslash(ExtractFilePath(ParamStr(0)));
        exec('cmd', '/c echo off');
        exec('cmd', '/c mklink "C:\Vanh_Src" "'+ FilePath +'Vanh_Src" /J')
    end;

    procedure programTitle(programTitle_inp: pchar);
    begin
        SetMultiByteConversionCodePage(CP_UTF8);
        SetMultiByteRTLFileSystemCodePage(CP_UTF8);
        SetConsoleOutputCP(CP_UTF8);
        SetConsoleTitle(programTitle_inp);
    end;

    Procedure TextColor(Color: Byte);
    Begin
        TextAttr:=(Color and $8f) or (TextAttr and $70);
    End;

    Procedure TextBackground(Color: Byte);
    Begin
        TextAttr:=((Color shl 4) and ($f0 and not Blink)) or (TextAttr and ($0f OR Blink) );
    End;

    procedure GotoXY(GotoXY_x, GotoXY_y: tcrtcoord);
    var 
        Coord: TCoord;
    begin
        if GotoXY_X > ConsoleSize.X 
        then 
         begin
            Coord.X:= WindMinX - 1;
            inc(GotoXY_Y);
         end
        else Coord.X:= GotoXY_x - 1;

        if GotoXY_Y > ConsoleSize.Y
        then 
         begin
            Coord.Y:= WindMaxY - 1;
            RemoveLine(1);
         end
        else Coord.Y:= GotoXY_y - 1;

        SetConsoleCursorPosition(GetStdHandle(STD_OUTPUT_HANDLE), Coord);
    end;

    procedure ClrEol;
    var
        Temp: DWord;
        CharInfo: Char;
        Coord: TCoord;
    begin
        CharInfo := #32;
        Coord:= ScreenCursorSystem;
        FillConsoleOutputCharacter(GetStdHandle(STD_OUTPUT_HANDLE), CharInfo, ConsoleSize.X - Coord.X, Coord, @Temp);
        FillConsoleOutputAttribute(GetStdHandle(STD_OUTPUT_HANDLE), TextAttr, ConsoleSize.X - Coord.X, Coord, @Temp);
    end;

    procedure clrscr;
    begin
        exec('cmd', '/c cls');
        GotoXY(1, 1);
    end;


    procedure Delay(MS: Word);
    begin
        Sleep(ms);
    end;

    procedure ConsoleColor(textcolor_inp, backgroundcolor_inp: Byte);
    begin
        exec('cmd', '/c color '+ IntToStr(textcolor_inp) + IntToStr(backgroundcolor_inp))
    end;

    procedure cursoron;
    begin
        GetConsoleCursorInfo(GetStdHandle(STD_OUTPUT_HANDLE), CursorInfo);
        CursorInfo.dwSize := SaveCursorSize;
        CursorInfo.bVisible := true;
        SetConsoleCursorInfo(GetStdHandle(STD_OUTPUT_HANDLE), CursorInfo);    
    end;


    procedure cursoroff;
    begin
        GetConsoleCursorInfo(GetStdHandle(STD_OUTPUT_HANDLE), CursorInfo);
        CursorInfo.bVisible := false;
        SetConsoleCursorInfo(GetStdHandle(STD_OUTPUT_HANDLE), CursorInfo);
    end;


    procedure cursorbig;
    var 
        CursorInfo: TConsoleCursorInfo;
    begin
        GetConsoleCursorInfo(GetStdHandle(STD_OUTPUT_HANDLE), CursorInfo);
        CursorInfo.dwSize := 93;
        CursorInfo.bVisible := true;
        SetConsoleCursorInfo(GetStdHandle(STD_OUTPUT_HANDLE), CursorInfo);
    end;

    procedure CharPrint(CharPrint_inp: Char);
    begin
        WriteConsoleOutputCharacter(
            GetStdhandle(STD_OUTPUT_HANDLE), 
            @CharPrint_inp, 
            1, 
            ScreenCursorSystem, 
            write_num
        );
        WriteConsoleOutputAttribute(
            GetStdHandle(STD_OUTPUT_HANDLE),
            @TextAttr,
            1,
            ScreenCursorSystem,
            write_num
        );        
    end;

    procedure StringPrint(StringPrint_inp: string);
    var 
        StringPrint_i: integer;
    begin
        for StringPrint_i:= 1 to length(StringPrint_inp)
        do begin
            CharPrint(StringPrint_inp[StringPrint_i]);
            GotoXY(ScreenCursorSystem.X + 2 , ScreenCursorSystem.Y + 1);
            if ScreenCursorSystem.x > ConsoleSize.X - 1 then
             begin
                GotoXY(WindMinX, ScreenCursorSystem.Y + 2);
                While ScreenCursorSystem.Y > ConsoleSize.Y do
                 begin
                    RemoveLine(1);
                    GotoXY(ScreenCursorSystem.X, ScreenCursorSystem.Y - 1)
                 end;
             end;
        end;
    end;

    procedure NormVideo;
    begin
        TextAttr := $7;
    end;


    procedure LowVideo;
    begin
        TextAttr := TextAttr and $F7;
    end;


    procedure HighVideo;
    begin
        TextAttr := TextAttr or $8;
    end;

Initialization
    FillChar(CursorInfo, SizeOf(CursorInfo), 00);
    GetConsoleCursorInfo(GetStdHandle(STD_OUTPUT_HANDLE), CursorInfo);
    SaveCursorSize := CursorInfo.dwSize;
    FillChar(ConsoleInfo, SizeOf(ConsoleInfo), 0);
    WindMinX := (ConsoleInfo.srWindow.Left) + 1;
    WindMinY := (ConsoleInfo.srWindow.Top) + 1;
    WindMaxX := (ConsoleInfo.srWindow.Right) + 1;
    WindMaxY := (ConsoleInfo.srWindow.Bottom) + 1;
    exec('cmd', '/c chcp 65001');
    SetMultiByteConversionCodePage(CP_UTF8);
    SetMultiByteRTLFileSystemCodePage(CP_UTF8);
    SetConsoleOutputCP(CP_UTF8);
    clrscr;
    HighVideo;
    SetConFont(14);
end.