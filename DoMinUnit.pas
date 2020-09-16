unit DoMinUnit;
interface
uses vanhprocedure, vanhfunction, keyboard, sysutils; 
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
    T_integer         = C_maxAm..C_max;
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

implementation
function resetVal(resetVal_ProV: ProV): ProV;
    begin
        resetVal.X:= resetVal_ProV.X;
        resetVal.Y:= resetVal_ProV.Y;
        resetVal.console:= resetVal_ProV.console;
        resetVal.Boom:= resetVal_ProV.Boom;
        resetVal.SetBoom:= resetVal_ProV.SetBoom;
        resetVal.Board:= resetVal_ProV.Board;
        resetVal.Stop:= resetVal_ProV.Stop;
    end;
procedure FinalBoard(FinalBoard_ProV: ProV);
    var
        FinalBoard_i, FinalBoard_j: integer;
    begin
        for FinalBoard_i:= 1 to FinalBoard_ProV.X.max
        do begin
            for FinalBoard_j:= 2 to FinalBoard_ProV.Y.max + 1
            do begin
                gotoXY(FinalBoard_i, FinalBoard_j);
                if 
                 FinalBoard_ProV.board[FinalBoard_i, FinalBoard_j].Val <> 'X'
                then TVWrite(FinalBoard_ProV.Board[FinalBoard_i, FinalBoard_j].Val)
                else 
                 begin
                    textcolor(Red);
                    CharPrint(FinalBoard_ProV.Board[FinalBoard_i, FinalBoard_j].Val);
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
    var 
        DrawRawBoard_i, DrawRawBoard_j: integer;
    begin
        clrscr;
        gotoXY(1, 1);
        CWindowsGenerator(DrawRawBoard_ProV.X.max, DrawRawBoard_ProV.Y.max + 6, DrawRawBoard_ProV);
        TVWrite  ('[M]: Cài đặt');
        gotoXY(1, DrawRawBoard_ProV.Y.max + 2);
        TVWriteln('[w,a,s,d]: Di chuyển');
        TVWriteln('[C]: xác nhận vị trí');
        TVWriteln('[Q]: Thoát game');
        TVWriteln('Đã thấy ' + IntToStr(DrawRawBoard_ProV.Boom.found) + '/' + IntToStr(DrawRawBoard_ProV.Boom.Number) + '');
        TVWrite  ('TÌM ĐI, CHỜ CHI!!!!!');
        for DrawRawBoard_i:= 1 to DrawRawBoard_ProV.X.max
        do begin
            for DrawRawBoard_j:= 2 to DrawRawBoard_ProV.Y.max + 1
            do begin
                gotoXY(DrawRawBoard_i, DrawRawBoard_j);
                if 
                    (DrawRawBoard_ProV.Board[DrawRawBoard_i, DrawRawBoard_j].show = 0)
                then CharPrint(DrawRawBoard_ProV.console.char)
                else begin 
                    textcolor(blue);
                    CharPrint(DrawRawBoard_ProV.Board[DrawRawBoard_i, DrawRawBoard_j].Val);
                end;
            end;
        end;
    end;
function DrawBoard(DrawBoard_ProV: ProV): ProV;
    var 
        DrawBoard_i, DrawBoard_j: integer;
    begin
        DrawBoard:= DrawBoard_ProV;
        for DrawBoard_i:= DrawBoard.X.locate - DrawBoard.Boom.find to DrawBoard.X.locate + DrawBoard.Boom.find
        do begin
            for DrawBoard_j:= DrawBoard.Y.locate - DrawBoard.Boom.find to DrawBoard.Y.locate + DrawBoard.Boom.find
            do begin                
                if 
                    (DrawBoard.Board[DrawBoard_i, DrawBoard_j].show = 1)
                    and
                    (DrawBoard_j > 1)
                    and
                    (DrawBoard_i >= 1)
                then begin
                    gotoXY(DrawBoard_i, DrawBoard_j);
                    textcolor(blue);
                    if 
                        (DrawBoard.Board[DrawBoard_i, DrawBoard_j].Val <> 'X')
                    then CharPrint(DrawBoard.Board[DrawBoard_i, DrawBoard_j].Val)
                    else 
                    if 
                        (DrawBoard.board[DrawBoard_i, DrawBoard_j].show = 1)
                        and 
                        (DrawBoard.board[DrawBoard_i, DrawBoard_j].Val = 'X')
                    then inc(DrawBoard.Boom.found);
                end;
                DrawBoard.Board[DrawBoard_i, DrawBoard_j].show:= 2;
            end;
        end;
        gotoXY(1, DrawBoard.Y.max + 5);
        
        TVWriteln('Đã thấy ' + IntToStr(DrawBoard.Boom.found) + '/' + IntToStr(DrawBoard.Boom.Number) + '');
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
        TVWriteln  ('');            
        TVWriteln  ('[T], [G]: tăng hoặc giảm');
        TVWriteln  ('[H]: qua trang tiếp theo');
        TVWriteln  ('[ENTER]: xác nhận');
        TVWrite    ('[Q]: thoát menu');
        repeat
            gotoXY(1, 1);
            TVWrite    ('FontSize hiện tại: ');clreol;
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
            changeFontSize.console.FontSize:= Set_console_fontsize(changeFontSize.console.FontSize);
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
            TVWrite    ('Char hiện tại: ');
            textcolor  (red);
            StringPrint(Char_CurrentChar);
            TVWriteln  ('');            
            TVWriteln  ('[Bất kì]: thay đổi char');
            TVWriteln  ('[H]: qua trang tiếp theo');
            TVWriteln  ('[ENTER]: xác nhận');
            TVWrite    ('[Q]: thoát menu');
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
        Set_console_fontsize(CWindowsGenerator_ProV.console.FontSize);
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
            gotoXY(1, 2);            
            TVWrite  ('[R]: ngẫu nhiên');
            gotoXY(1, 1);
            TVWrite  ('Nhập số ' + GetXorY_input + ': ');clreol;
            cursoron();
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
        MessageToQuit_i   : integer;
        MessageToQuit_key : char;
    begin        
        MessageToQuit:= MessageToQuit_ProV;
        if MessageToQuit_input = 'thắng'
        then begin
            for MessageToQuit_i:= 1 to 25
            do begin
                color(white, black);
                delay(MessageToQuit_delay);
                color(black, white);
                delay(MessageToQuit_delay);
            end;
        end;        
        color  (white, black);
        clrscr;
        FinalBoard(MessageToQuit_ProV);
        gotoXY(1, MessageToQuit_ProV.Y.max + 3);
        TVWriteln('Bạn đã ' + MessageToQuit_input);
        delay  (3000);
        TVWriteln('[R] Chơi Lại');
        TVWrite  ('[Q] Thoát');
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