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

Procedure TextColor(Color: Byte);
Procedure TextBackground(Color: Byte);
procedure WindowsGenerator(WindowsGenerator_X, WindowsGenerator_Y: integer);
procedure dpmi_dosmemfillword(seg,ofs : word;count : longint;w : word);
procedure seg_fillword(seg : word;ofs : longint;count : longint;w : word);
procedure clrscr;
Procedure GotoXY(GotoXY_X, GotoXY_Y: tcrtcoord);
Procedure ClrEol;
procedure color(textcolor_input, backgroundcolor_input: Byte);
procedure cursoron;
procedure cursoroff;
procedure cursorbig;
procedure Delay(MS: Word);
procedure programTitle(programTitle_input: pchar);
procedure installSRC;
procedure TVWrite(TVWrite_input: string);
procedure TVWriteln(TVWriteln_input: string);
procedure CharPrint(CharPrint_inp: Char);
procedure removeline(y : DWord);
procedure StringPrint(StringPrint_inp: string);
const 
    dosmemfillword : procedure(seg,ofs : word;count : longint;w : word)=@dpmi_dosmemfillword;
    TextLarge      = 30;
    TextNormal     = 20;
implementation
    var
        VidSeg    : word;
        CursorInfo: TConsoleCursorInfo;
        ConsoleInfo : TConsoleScreenBufferinfo;

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
    
    procedure TVWrite(TVWrite_input: string);
    begin
        SetMultiByteConversionCodePage(CP_UTF8);
        SetMultiByteRTLFileSystemCodePage(CP_UTF8);
        SetConsoleOutputCP(CP_UTF8);
        Write(TVWrite_input);
    end;

    procedure TVWriteln(TVWriteln_input: string);
    begin
        SetMultiByteConversionCodePage(CP_UTF8);
        SetMultiByteRTLFileSystemCodePage(CP_UTF8);
        SetConsoleOutputCP(CP_UTF8);
        writeln(TVWriteln_input);
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

    procedure programTitle(programTitle_input: pchar);
    begin
        SetMultiByteConversionCodePage(CP_UTF8);
        SetMultiByteRTLFileSystemCodePage(CP_UTF8);
        SetConsoleOutputCP(CP_UTF8);
        SetConsoleTitle(programTitle_input);
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
        Coord.X:= GotoXY_x - 1;
        Coord.Y:= GotoXY_y - 1;
        SetConsoleCursorPosition(GetStdHandle(STD_OUTPUT_HANDLE), Coord);
    end;

    procedure ClrEol;
    var
        Temp: DWord;
        CharInfo: Char;
        Coord: TCoord;
    begin
        CharInfo := #32;
        Coord:= ScreenCursor;
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

    procedure color(textcolor_input, backgroundcolor_input: Byte);
    begin
        TextColor(textcolor_input);TextBackground(backgroundcolor_input);
    end;

    procedure cursoron;
    var 
        CursorInfo: TConsoleCursorInfo;
    begin
        GetConsoleCursorInfo(GetStdHandle(STD_OUTPUT_HANDLE), CursorInfo);
        CursorInfo.dwSize := SaveCursorSize;
        CursorInfo.bVisible := true;
        SetConsoleCursorInfo(GetStdHandle(STD_OUTPUT_HANDLE), CursorInfo);    
    end;


    procedure cursoroff;
    var 
        CursorInfo: TConsoleCursorInfo;
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
    var 
        write_num: DWord;
    begin
        WriteConsoleOutputCharacter(
            GetStdhandle(STD_OUTPUT_HANDLE), 
            @CharPrint_inp, 
            1, 
            ScreenCursor, 
            write_num
        );
        WriteConsoleOutputAttribute(
            GetStdHandle(STD_OUTPUT_HANDLE),
            @TextAttr,
            1,
            ScreenCursor,
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
            GotoXY(ScreenCursor.X + 2 , ScreenCursor.Y + 1);
            if ScreenCursor.x + 1 >= ConsoleSize.X then
             begin
                GotoXY(WindMinX, ScreenCursor.Y + 2);
                While ScreenCursor.Y > ConsoleSize.Y do
                 begin
                    RemoveLine(1);
                    GotoXY(ScreenCursor.X, ScreenCursor.Y - 1)
                 end;
             end;
        end;
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
    clrscr;
end.