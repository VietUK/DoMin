unit DoMinUnit;
interface
uses vanhprocedure, vanhfunction, keyboard, sysutils, dos, windows; 
const 
    C_max          =  60;
    C_maxAm        =  -5;  
type
    T_KindOfBoard     = record
        Val         : char;
        show          : 0..2;
    end;
    T_locate            = record
        max           : 1..C_max;
        locate        : C_maxAm..C_max;
    end;
    ProV = record
        X             : T_locate;
        Y             : T_locate;
        console       : record
            FontSize  : integer;
            char      : char;
        end;
        Boom          : record
            Difficult : record
                Level : 1..C_max;
                Random: 1..C_max;
            end;
            Number    : 0..C_max * C_max;
            find      : 1..C_max;
            found     : 0..C_max;
        end;
        SetBoom       : record
            X         : 1..C_max;
            Y         : 1..C_max;
        end;        
        Board         : array 
                        [C_maxAm..C_max, C_maxAm..C_max] 
                        of T_KindOfBoard;
        Stop          : 0..2;
    end;
var
    CurrentFontSize: integer;

function  DrawBoard        (DrawBoard_ProV: ProV): ProV;
procedure make_Footprint   (make_Footprint_X, make_Footprint_Y: integer;
                            make_Footprint_ProV: ProV
                           );
procedure resetFootprint   (resetFootprint_X, resetFootprint_Y: integer; 
                            resetFootprint_ProV: ProV
                           );
function  processWayGo     (Location_input, IncOrDec, XOrY,
                            processWayGo_X, processWayGo_Y, 
                            processWayGo_min, processWayGo_max:integer;
                            processWayGo_ProV: ProV
                           ): integer;    
function  Menu             (Menu_ProV: ProV): ProV;
function  changeChar       (char_ProV: ProV): ProV;
procedure CWindowsGenerator(CWindowsGenerator_X, CWindowsGenerator_Y: integer;
                            CWindowsGenerator_ProV: ProV
                           );
function  changeFontSize   (FontSize_ProV: ProV): ProV;
function  GetXorY          (GetXorY_input: string): integer;
procedure DrawRawBoard     (DrawRawBoard_ProV: ProV);
function  MessageToQuit    (MessageToQuit_input: string;
                            MessageToQuit_ProV: ProV
                           ): ProV;
function resetVal           :ProV;

implementation

    function resetVal(): ProV;
    begin
        programTitle('DoMin_V0_9');
        SetMultiByteConversionCodePage(CP_UTF8);
        SetMultiByteRTLFileSystemCodePage(CP_UTF8);
        SetConsoleOutputCP(CP_UTF8);
        resetVal.X.max               := 1;
        resetVal.Y.max               := 1;
        resetVal.Boom.find           := 1;
        resetVal.Boom.Difficult.Level:= 1;
        resetVal.Boom.Number         := 0;
        resetVal.Boom.found          := 0;
        resetVal.console.FontSize    := TextNormal;
        resetVal.console.char        := char(254);
        for _i:= C_maxAm to C_max
        do begin
            for _j:= C_maxAm to C_max
            do begin
                resetVal.Board[_i, _j].Val:= '0';
                resetVal.Board[_i, _j].show := 0;
            end;
        end;
        resetVal.Stop:= 0;
    end;

    procedure FinalBoard(FinalBoard_ProV: ProV);
    begin
        for _i:= 1 to FinalBoard_ProV.X.max
        do begin
            for _j:= 2 to FinalBoard_ProV.Y.max + 1
            do begin
                gotoXY(_i, _j);
                if 
                 FinalBoard_ProV.board[_i, _j].Val <> 'X'
                then TVWrite(FinalBoard_ProV.Board[_i, _j].Val, white, black)
                else 
                 begin
                    textcolor(Red);
                    CharPrint(FinalBoard_ProV.Board[_i, _j].Val);
                    textcolor(white);
                 end;
            end;
        end;
        gotoXY(FinalBoard_ProV.X.locate, FinalBoard_ProV.Y.locate);
        textcolor(green);
        CharPrint(FinalBoard_ProV.Board[FinalBoard_ProV.X.locate, FinalBoard_ProV.Y.locate].Val);
        textcolor(white);
    end;

    procedure DrawRawBoard(DrawRawBoard_ProV: ProV);
    begin
        clrscr;
        gotoXY(1, 1);
        CWindowsGenerator(DrawRawBoard_ProV.X.max, DrawRawBoard_ProV.Y.max + 6, DrawRawBoard_ProV);
        TVWrite  ('[M]: Cài đặt', white, black);
        gotoXY(1, DrawRawBoard_ProV.Y.max + 2);
        TVWriteln('[w,a,s,d]: Di chuyển', white, black);
        TVWriteln('[C]: xác nhận vị trí', white, black);
        TVWriteln('[Q]: Thoát game', white, black);
        TVWriteln('Đã thấy ' + IntToStr(DrawRawBoard_ProV.Boom.found) + '/' + IntToStr(DrawRawBoard_ProV.Boom.Number) + '', white, black);
        TVWrite  ('TÌM ĐI, CHỜ CHI!!!!!', white, black);
        for _i:= 1 to DrawRawBoard_ProV.X.max
        do begin
            for _j:= 2 to DrawRawBoard_ProV.Y.max + 1
            do begin
                gotoXY(_i, _j);
                if 
                    (DrawRawBoard_ProV.Board[_i, _j].show = 0)
                then CharPrint(DrawRawBoard_ProV.console.char)
                else begin 
                    textcolor(blue);
                    CharPrint(DrawRawBoard_ProV.Board[_i, _j].Val);
                end;
            end;
        end;
    end;

    function DrawBoard(DrawBoard_ProV: ProV): ProV;
    var 
        _i, _j: integer;
    begin
        DrawBoard:= DrawBoard_ProV;
        for _i:= DrawBoard.X.locate - DrawBoard.Boom.find to DrawBoard.X.locate + DrawBoard.Boom.find
        do begin
            for _j:= DrawBoard.Y.locate - DrawBoard.Boom.find to DrawBoard.Y.locate + DrawBoard.Boom.find
            do begin                
                if 
                    (DrawBoard.Board[_i, _j].show = 1)
                    and
                    (_j > 1)
                    and
                    (_i >= 1)
                then begin
                    gotoXY(_i, _j);
                    textcolor(blue);
                    if 
                        (DrawBoard.Board[_i, _j].Val <> 'X')
                    then CharPrint(DrawBoard.Board[_i, _j].Val)
                    else 
                    if 
                        (DrawBoard.board[_i, _j].show = 1)
                        and 
                        (DrawBoard.board[_i, _j].Val = 'X')
                    then inc(DrawBoard.Boom.found);
                end;
                DrawBoard.Board[_i, _j].show:= 2;
            end;
        end;
        gotoXY(1, DrawBoard.Y.max + 5);
        
        TVWriteln('Đã thấy ' + IntToStr(DrawBoard.Boom.found) + '/' + IntToStr(DrawBoard.Boom.Number) + '', white, black);
        if 
            (DrawBoard.Boom.found = DrawBoard.Boom.Number)
        then DrawBoard:= MessageToQuit('thắng', DrawBoard);
    end;

    procedure resetFootprint(resetFootprint_X, resetFootprint_Y: integer; 
                             resetFootprint_ProV: ProV
                            );
    begin
        gotoXY(resetFootprint_X, resetFootprint_Y);
        if 
            (resetFootprint_ProV.Board[resetFootprint_X, resetFootprint_Y].show >= 1)
            and
            (resetFootprint_ProV.Board[resetFootprint_X, resetFootprint_Y].Val <> 'X')
        then begin
            textcolor(blue);
            CharPrint(resetFootprint_ProV.Board[resetFootprint_X, resetFootprint_Y].Val);            
        end
        else begin
            textcolor(white);
            CharPrint(resetFootprint_ProV.console.char);
        end;
    end;

    procedure make_Footprint(make_Footprint_X, make_Footprint_Y: integer;
                             make_Footprint_ProV: ProV
                            );
    begin
        gotoXY(make_Footprint_X, make_Footprint_Y);
        textcolor(red);
        if 
            (make_Footprint_ProV.Board[make_Footprint_X, make_Footprint_Y].show >= 1)
            and
            (make_Footprint_ProV.board[make_Footprint_X, make_Footprint_Y].Val <> 'X')
        then CharPrint(make_Footprint_ProV.board[make_Footprint_X, make_Footprint_Y].Val)
        else CharPrint(make_Footprint_ProV.console.char);        
    end;

    procedure Footprint(Footprint_X, Footprint_Y,
                        XOrY, Footprint_Val0, Footprint_Val1: integer; 
                        Footprint_ProV: ProV
                       );
    begin
        case XOrY of 
            0: begin
                make_Footprint(Footprint_Val0,
                               Footprint_Y,
                               Footprint_ProV
                              );
                resetFootprint(Footprint_Val1, 
                               Footprint_Y, 
                               Footprint_ProV
                              );
            end;
            1: begin
                make_Footprint(Footprint_X,
                               Footprint_Val0,
                               Footprint_ProV
                              );
                resetFootprint(Footprint_X, 
                               Footprint_Val1, 
                               Footprint_ProV
                              );
            end;
        end;
    end;

    function processWayGo(Location_input, IncOrDec, XOrY,
                          processWayGo_X, processWayGo_Y, 
                          processWayGo_min, processWayGo_max:integer;
                          processWayGo_ProV: ProV
                         ): integer;    
    begin
        processWayGo:= Location_input;
        case IncOrDec of
            0: begin
                if 
                    ((Location_input + 1) <> processWayGo_max + 1)
                then begin
                    inc(processWayGo);
                    Footprint(processWayGo_X, processWayGo_Y,
                              XOrY, processWayGo, processWayGo - 1,
                              processWayGo_ProV
                             );
                end
                else exit;
            end;    
            1: begin
                if 
                    ((Location_input - 1) <> processWayGo_min)
                then 
                    dec(processWayGo);
                    Footprint(processWayGo_X, processWayGo_Y,
                              XOrY, processWayGo, processWayGo + 1,
                              processWayGo_ProV
                             );
            end
            else exit;
        end;
    end;

    function changeFontSize(FontSize_ProV: ProV): ProV;
    var 
        FontSize_key: char;
    begin
        changeFontSize:= FontSize_ProV;
        changeFontSize.console.FontSize:= FontSize_ProV.console.FontSize;
        CWindowsGenerator(25, 6, FontSize_ProV);
        clrscr;
        gotoXY     (1, 2);
        TVWriteln  ('', white, black);            
        TVWriteln  ('[T], [G]: tăng hoặc giảm', white, black);
        TVWriteln  ('[H]: qua trang tiếp theo', white, black);
        TVWriteln  ('[ENTER]: xác nhận', white, black);
        TVWrite    ('[Q]: thoát menu', white, black);
        repeat
            gotoXY(1, 1);
            TVWrite    ('FontSize hiện tại: ', white, black);clreol;
            textcolor  (red);
            StringPrint(IntToStr(changeFontSize.console.FontSize));
            FontSize_key:= readkey;
            case FontSize_key of 
                'T', 't': inc(changeFontSize.console.FontSize);
                'G', 'g': dec(changeFontSize.console.FontSize);
                'Q', 'q': exit;
                'H', 'h': begin
                    changeFontSize:= changeChar(FontSize_ProV);
                    exit;
                end;
            end;
            SetConFont(changeFontSize.console.FontSize);
        until (FontSize_key = #13);
    end;

    function changeChar(char_ProV: ProV): ProV;
    var 
        char_key, Char_CurrentChar: char;
    begin
        changeChar:= char_ProV;
        Char_CurrentChar:= changeChar.console.char;
        CWindowsGenerator(25, 6, char_ProV);
        clrscr;
        repeat
            gotoXY     (1, 1);            
            TVWrite    ('Char hiện tại: ', white, black);
            textcolor  (red);
            StringPrint(Char_CurrentChar);
            TVWriteln  ('', white, black);            
            TVWriteln  ('[Bất kì]: thay đổi char', white, black);
            TVWriteln  ('[H]: qua trang tiếp theo', white, black);
            TVWriteln  ('[ENTER]: xác nhận', white, black);
            TVWrite    ('[Q]: thoát menu', white, black);
            gotoXY(1, 20);
            char_key:= readkey;
            case char_key of 
                'H', 'h': begin
                    changeChar:= changeFontSize(char_ProV);
                    exit;
                end;
                'Q', 'q': exit;
                #13: break;
                else Char_CurrentChar:= char_key;
            end;
        until (char_key = #13);
        changeChar.console.char := Char_CurrentChar;
    end;

    function Menu(Menu_ProV: ProV): ProV;
    begin
        menu:= Menu_ProV;
        Menu:= changeFontSize(Menu_ProV);
    end;

    procedure CWindowsGenerator(CWindowsGenerator_X, CWindowsGenerator_Y: integer;
                                CWindowsGenerator_ProV: ProV
                               );
    begin
        WindowsGenerator(CWindowsGenerator_X, CWindowsGenerator_Y);
        SetConFont(CWindowsGenerator_ProV.console.FontSize);
    end;

    function GetXorY(GetXorY_input: string): integer;
    var 
        GetXorY_string: string;
    begin
        GetXorY:= 1;
        while 
            (GetXorY < 20)
            or
            (GetXorY > C_max)
        do begin
            clrscr;
            cursoron();
            gotoXY(1, 2);            
            TVWrite  ('[R]: ngẫu nhiên', white, black);
            gotoXY(1, 1);
            TVWrite  ('Nhập số ' + GetXorY_input + ': ', white, black);clreol;
            readln(GetXorY_string);
            if (GetXorY_string = IntToStr(sohoa(GetXorY_string)))
            then begin
                GetXorY:= sohoa(GetXorY_string);
            end
            else 
            if 
                (GetXorY_string = 'r')
                or
                (GetXorY_string = 'R')
            then begin
                GetXorY:= random(C_max - 20) + 21;
            end;
            cursoroff();
        end;
    end;

    function MessageToQuit(MessageToQuit_input: string;
                           MessageToQuit_ProV: ProV
                          ): ProV;
    const
        MessageToQuit_delay = 50;
    var 
        {MessageToQuit_i   : integer;}
        MessageToQuit_key : char;
    begin        
        MessageToQuit:= MessageToQuit_ProV;
        {if MessageToQuit_input = 'thắng'
        then begin
            for MessageToQuit_i:= 1 to 25
            do begin
                color(white, black);
                delay(MessageToQuit_delay);
                color(black, white);
                delay(MessageToQuit_delay);
            end;
        end;     
        color  (white, black);}
        clrscr;
        FinalBoard(MessageToQuit_ProV);
        gotoXY(1, MessageToQuit_ProV.Y.max + 3);
        TVWriteln('Bạn đã ' + MessageToQuit_input, white, randomN);
        delay  (3000);
        TVWriteln('[R] Chơi Lại', white, black);
        TVWrite  ('[Q] Thoát', white, black);
        repeat
            MessageToQuit_key:= readkey;
            if 
                (MessageToQuit_key = 'Q')
                or 
                (MessageToQuit_key = 'q')
            then begin
                MessageToQuit.Stop:= 1;
            end
            else 
            if 
                (MessageToQuit_key = 'R')
                or 
                (MessageToQuit_key = 'r')
            then begin
                MessageToQuit.Stop:= 2;
                exit;
            end;
        until MessageToQuit.Stop = 1;  
    end;
end.