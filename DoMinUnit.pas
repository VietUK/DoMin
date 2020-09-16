unit DoMinUnit;
interface
uses vanhprocedure, vanhfunction, keyboard, sysutils; 
const 
    C_max          =  60;
    C_maxAm        =  -5;  
type
    T_KindOfBoard     = record
        Value         : char;
        show          : 0..2;
    end;
    T_locate            = record
        max           : 1..C_max;
        locate        : C_maxAm..C_max;
    end;
    T_integer         = C_maxAm..C_max;
    ProgramVariable = record
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

function  DrawBoard        (DrawBoard_ProgramVariable: ProgramVariable): ProgramVariable;
procedure make_Footprint   (make_Footprint_X, make_Footprint_Y: integer;
                            make_Footprint_ProgramVariable: ProgramVariable
                           );
procedure resetFootprint   (resetFootprint_X, resetFootprint_Y: integer; 
                            resetFootprint_ProgramVariable: ProgramVariable
                           );
function  processWayGo     (Location_input, IncOrDec, XOrY,
                            processWayGo_X, processWayGo_Y, 
                            processWayGo_min, processWayGo_max:integer;
                            processWayGo_ProgramVariable: ProgramVariable
                           ): integer;    
function  Menu             (Menu_ProgramVariable: ProgramVariable): ProgramVariable;
function  changeChar       (char_ProgramVariable: ProgramVariable): ProgramVariable;
procedure CWindowsGenerator(CWindowsGenerator_X, CWindowsGenerator_Y: integer;
                            CWindowsGenerator_ProgramVariable: ProgramVariable
                           );
function  changeFontSize   (FontSize_ProgramVariable: ProgramVariable): ProgramVariable;
function  GetXorY          (GetXorY_input: string): integer;
procedure DrawRawBoard     (DrawRawBoard_ProgramVariable: ProgramVariable);
function  MessageToQuit    (MessageToQuit_input: string;
                            MessageToQuit_ProgramVariable: ProgramVariable
                           ): ProgramVariable;

implementation
function resetValue(resetValue_ProgramVariable: ProgramVariable): ProgramVariable;
    begin
        resetValue.X:= resetValue_ProgramVariable.X;
        resetValue.Y:= resetValue_ProgramVariable.Y;
        resetValue.console:= resetValue_ProgramVariable.console;
        resetValue.Boom:= resetValue_ProgramVariable.Boom;
        resetValue.SetBoom:= resetValue_ProgramVariable.SetBoom;
        resetValue.Board:= resetValue_ProgramVariable.Board;
        resetValue.Stop:= resetValue_ProgramVariable.Stop;
    end;
procedure FinalBoard(FinalBoard_ProgramVariable: ProgramVariable);
    var
        FinalBoard_i, FinalBoard_j: integer;
    begin
        for FinalBoard_i:= 1 to FinalBoard_ProgramVariable.X.max
        do begin
            for FinalBoard_j:= 2 to FinalBoard_ProgramVariable.Y.max + 1
            do begin
                gotoXY(FinalBoard_i, FinalBoard_j);
                TVWrite(FinalBoard_ProgramVariable.Board[FinalBoard_i, FinalBoard_j].Value);
            end;
        end;
    end;
procedure DrawRawBoard(DrawRawBoard_ProgramVariable: ProgramVariable);
    var 
        DrawRawBoard_i, DrawRawBoard_j: integer;
    begin
        clrscr;
        gotoXY(1, 1);
        CWindowsGenerator(DrawRawBoard_ProgramVariable.X.max, DrawRawBoard_ProgramVariable.Y.max + 6, DrawRawBoard_ProgramVariable);
        TVWrite  ('[M]: Cài đặt');
        gotoXY(1, DrawRawBoard_ProgramVariable.Y.max + 2);
        TVWriteln('[w,a,s,d]: Di chuyển');
        TVWriteln('[C]: xác nhận vị trí');
        TVWriteln('[Q]: Thoát game');
        TVWriteln('Đã thấy ' + IntToStr(DrawRawBoard_ProgramVariable.Boom.found) + '/' + IntToStr(DrawRawBoard_ProgramVariable.Boom.Number) + '');
        TVWrite  ('TÌM ĐI, CHỜ CHI!!!!!');
        for DrawRawBoard_i:= 1 to DrawRawBoard_ProgramVariable.X.max
        do begin
            for DrawRawBoard_j:= 2 to DrawRawBoard_ProgramVariable.Y.max + 1
            do begin
                gotoXY(DrawRawBoard_i, DrawRawBoard_j);
                if 
                    (DrawRawBoard_ProgramVariable.Board[DrawRawBoard_i, DrawRawBoard_j].show = 0)
                then CharPrint(DrawRawBoard_ProgramVariable.console.char)
                else begin 
                    textcolor(blue);
                    CharPrint(DrawRawBoard_ProgramVariable.Board[DrawRawBoard_i, DrawRawBoard_j].Value);
                end;
            end;
        end;
    end;
function DrawBoard(DrawBoard_ProgramVariable: ProgramVariable): ProgramVariable;
    var 
        DrawBoard_i, DrawBoard_j: integer;
    begin
        DrawBoard:= DrawBoard_ProgramVariable;
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
                        (DrawBoard.Board[DrawBoard_i, DrawBoard_j].Value <> 'X')
                    then CharPrint(DrawBoard.Board[DrawBoard_i, DrawBoard_j].Value)
                    else 
                    if 
                        (DrawBoard.board[DrawBoard_i, DrawBoard_j].show = 1)
                        and 
                        (DrawBoard.board[DrawBoard_i, DrawBoard_j].Value = 'X')
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
                         resetFootprint_ProgramVariable: ProgramVariable
                        );
    begin
        gotoXY(resetFootprint_X, resetFootprint_Y);
        if 
            (resetFootprint_ProgramVariable.Board[resetFootprint_X, resetFootprint_Y].show >= 1)
            and
            (resetFootprint_ProgramVariable.Board[resetFootprint_X, resetFootprint_Y].Value <> 'X')
        then begin
            textcolor(blue);
            CharPrint(resetFootprint_ProgramVariable.Board[resetFootprint_X, resetFootprint_Y].Value);            
        end
        else begin
            textcolor(white);
            CharPrint(resetFootprint_ProgramVariable.console.char);
        end;
    end;
procedure make_Footprint(make_Footprint_X, make_Footprint_Y: integer;
                         make_Footprint_ProgramVariable: ProgramVariable
                        );
    begin
        gotoXY(make_Footprint_X, make_Footprint_Y);
        textcolor(red);
        if 
            (make_Footprint_ProgramVariable.Board[make_Footprint_X, make_Footprint_Y].show >= 1)
            and
            (make_Footprint_ProgramVariable.board[make_Footprint_X, make_Footprint_Y].Value <> 'X')
        then CharPrint(make_Footprint_ProgramVariable.board[make_Footprint_X, make_Footprint_Y].Value)
        else CharPrint(make_Footprint_ProgramVariable.console.char);        
    end;
procedure Footprint(Footprint_X, Footprint_Y,
                    XOrY, Footprint_Value0, Footprint_Value1: integer; 
                    Footprint_ProgramVariable: ProgramVariable
                   );
    begin
        case XOrY of 
            0: begin
                make_Footprint(Footprint_Value0,
                               Footprint_Y,
                               Footprint_ProgramVariable
                              );
                resetFootprint(Footprint_Value1, 
                               Footprint_Y, 
                               Footprint_ProgramVariable
                              );
            end;
            1: begin
                make_Footprint(Footprint_X,
                               Footprint_Value0,
                               Footprint_ProgramVariable
                              );
                resetFootprint(Footprint_X, 
                               Footprint_Value1, 
                               Footprint_ProgramVariable
                              );
            end;
        end;
    end;
function processWayGo(Location_input, IncOrDec, XOrY,
                      processWayGo_X, processWayGo_Y, 
                      processWayGo_min, processWayGo_max:integer;
                      processWayGo_ProgramVariable: ProgramVariable
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
                              processWayGo_ProgramVariable
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
                              processWayGo_ProgramVariable
                             );
            end
            else exit;
        end;
    end;
function changeFontSize(FontSize_ProgramVariable: ProgramVariable): ProgramVariable;
    var 
        FontSize_key: char;
    begin
        changeFontSize:= FontSize_ProgramVariable;
        changeFontSize.console.FontSize:= FontSize_ProgramVariable.console.FontSize;
        CWindowsGenerator(25, 6, FontSize_ProgramVariable);
        clrscr;
        repeat
            gotoXY     (1, 1);
            TVWrite    ('FontSize hiện tại: ');clreol;
            textcolor  (red);
            StringPrint(IntToStr(changeFontSize.console.FontSize));
            TVWriteln  ('');            
            TVWriteln  ('[T], [G]: tăng hoặc giảm');
            TVWriteln  ('[H]: qua trang tiếp theo');
            TVWriteln  ('[ENTER]: xác nhận');
            TVWrite    ('[Q]: thoát menu');
            gotoXY(1, 20);
            FontSize_key:= readkey;
            case FontSize_key of 
                'T', 't': inc(changeFontSize.console.FontSize);
                'G', 'g': dec(changeFontSize.console.FontSize);
                'Q', 'q': exit;
                'H', 'h': begin
                    changeFontSize:= changeChar(FontSize_ProgramVariable);
                    exit;
                end;
            end;
            changeFontSize.console.FontSize:= Set_console_fontsize(changeFontSize.console.FontSize);
        until (FontSize_key = #13);
    end;
function changeChar(char_ProgramVariable: ProgramVariable): ProgramVariable;
    var 
        char_key, Char_CurrentChar: char;
    begin
        changeChar:= char_ProgramVariable;
        Char_CurrentChar:= changeChar.console.char;
        CWindowsGenerator(25, 6, char_ProgramVariable);
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
                    changeChar:= changeFontSize(char_ProgramVariable);
                    exit;
                end;
                'Q', 'q': exit;
                #13: break;
                else Char_CurrentChar:= char_key;
            end;
        until (char_key = #13);
        changeChar.console.char := Char_CurrentChar;
    end;
function Menu(Menu_ProgramVariable: ProgramVariable): ProgramVariable;
    begin
        menu:= Menu_ProgramVariable;
        Menu:= changeFontSize(Menu_ProgramVariable);
    end;
procedure CWindowsGenerator(CWindowsGenerator_X, CWindowsGenerator_Y: integer;
                            CWindowsGenerator_ProgramVariable: ProgramVariable
                           );
    begin
        WindowsGenerator(CWindowsGenerator_X, CWindowsGenerator_Y);
        Set_console_fontsize(CWindowsGenerator_ProgramVariable.console.FontSize);
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
                       MessageToQuit_ProgramVariable: ProgramVariable
                      ): ProgramVariable;
    const
        MessageToQuit_delay = 50;
    var 
        MessageToQuit_i   : integer;
        MessageToQuit_key : char;
    begin        
        MessageToQuit:= MessageToQuit_ProgramVariable;
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
        FinalBoard(MessageToQuit_ProgramVariable);
        gotoXY(1, MessageToQuit_ProgramVariable.Y.max + 3);
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