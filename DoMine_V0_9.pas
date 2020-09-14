{X la cot, Y la hang}
{$codepage utf8}
program
    DoMin_V0_9;
uses
    vanhprocedure,
    vanhFunction,
    DoMinUnit,
    windows,
    dos,
    keyboard;
var  
    DoMin_V0_9_Variable : ProgramVariable;
    _i, _i1, _j, _j1    : T_integer;
    _key                : char;
procedure
    resetValue();
    begin
        programTitle('DoMin_V0_9');
        SetMultiByteConversionCodePage(CP_UTF8);
        SetMultiByteRTLFileSystemCodePage(CP_UTF8);
        SetConsoleOutputCP(CP_UTF8);
        DoMin_V0_9_Variable.X.max               := 1;
        DoMin_V0_9_Variable.Y.max               := 1;
        DoMin_V0_9_Variable.Boom.find           := 1;
        DoMin_V0_9_Variable.Boom.Difficult.Level:= 1;
        DoMin_V0_9_Variable.Boom.Number         := 0;
        DoMin_V0_9_Variable.Boom.found          := 0;
        DoMin_V0_9_Variable.console.FontSize    := TextNormal;
        DoMin_V0_9_Variable.console.char        := char(254);
        for _i:= C_maxAm to C_max
        do begin
            for _j:= C_maxAm to C_max
            do begin
                DoMin_V0_9_Variable.Board[_i, _j].Value:= '0';
                DoMin_V0_9_Variable.Board[_i, _j].show := 0;
            end;
        end;
        DoMin_V0_9_Variable.Stop:= 0;
    end;
procedure
    play();
    begin
        DoMin_V0_9_Variable.X.locate:= 1;
        DoMin_V0_9_Variable.Y.locate:= 2;
        DrawRawBoard(DoMin_V0_9_Variable);
        for _i:= C_maxAm to C_max
        do begin
            for _j:= C_maxAm to C_max
            do begin
                DoMin_V0_9_Variable.Board[_i, _j].show := 0;
            end;
        end;
        repeat
            DoMin_V0_9_Variable.console.FontSize:= 
                Set_console_fontsize(DoMin_V0_9_Variable.console.FontSize);
            gotoXY(DoMin_V0_9_Variable.X.locate, DoMin_V0_9_Variable.Y.locate);
            make_Footprint(
                DoMin_V0_9_Variable.X.locate, 
                DoMin_V0_9_Variable.Y.locate, 
                DoMin_V0_9_Variable
                );
            if (DoMin_V0_9_Variable.Stop = 1) or (DoMin_V0_9_Variable.Stop = 2)
            then exit
            else begin
                repeat
                    {if keypressed
                    then begin}     
                        _key:= readkey;
                        case _key of 
                            'a', 'A': 
                             DoMin_V0_9_Variable.X.locate:= 
                                processWayGo(
                                    DoMin_V0_9_Variable.X.locate, 1, 0,
                                    DoMin_V0_9_Variable.X.locate + 1, 
                                    DoMin_V0_9_Variable.Y.locate, 0, 
                                    DoMin_V0_9_Variable.X.max,
                                    DoMin_V0_9_Variable
                                );
                            'w', 'W': 
                             DoMin_V0_9_Variable.Y.locate:= 
                                processWayGo(
                                    DoMin_V0_9_Variable.Y.locate, 1, 1,
                                    DoMin_V0_9_Variable.X.locate, 
                                    DoMin_V0_9_Variable.Y.locate + 1, 1, 
                                    DoMin_V0_9_Variable.Y.max + 1,
                                    DoMin_V0_9_Variable
                                );
                            'd', 'D': 
                             DoMin_V0_9_Variable.X.locate:= 
                                processWayGo(
                                    DoMin_V0_9_Variable.X.locate, 0, 0,
                                    DoMin_V0_9_Variable.X.locate - 1, 
                                    DoMin_V0_9_Variable.Y.locate, 0, 
                                    DoMin_V0_9_Variable.X.max,
                                    DoMin_V0_9_Variable
                                );
                            's', 'S': 
                             DoMin_V0_9_Variable.Y.locate:= 
                                processWayGo(
                                    DoMin_V0_9_Variable.Y.locate, 0, 1,
                                    DoMin_V0_9_Variable.X.locate, 
                                    DoMin_V0_9_Variable.Y.locate - 1, 1, 
                                    DoMin_V0_9_Variable.Y.max + 1,
                                    DoMin_V0_9_Variable
                                );
                            'q', 'Q': halt();
                        end;
                    {end;}
                until 
                    (   
                        ((_key = 'c') or (_key = 'C')) 
                        and 
                        (
                            DoMin_V0_9_Variable.Board[  
                                DoMin_V0_9_Variable.X.locate, 
                                DoMin_V0_9_Variable.Y.locate
                            ].show = 0
                        )
                    )
                    or
                    ((_key = 'm') or (_key = 'M'))
                    or
                    (
                        DoMin_V0_9_Variable.Board[
                            DoMin_V0_9_Variable.X.locate, 
                            DoMin_V0_9_Variable.Y.locate
                        ].Value = 'X'
                    )
                    ;
                case _key of
                    'c', 'C': begin
                        if 
                            DoMin_V0_9_Variable.Board[
                                DoMin_V0_9_Variable.X.locate, 
                                DoMin_V0_9_Variable.Y.locate
                            ].Value
                            <>
                            'X'
                        then begin
                            for _i:= 
                              DoMin_V0_9_Variable.X.locate 
                              - 
                              DoMin_V0_9_Variable.Boom.find 
                             to 
                              DoMin_V0_9_Variable.X.locate 
                              + 
                              DoMin_V0_9_Variable.Boom.find
                            do begin
                                for _j:= 
                                  DoMin_V0_9_Variable.Y.locate 
                                  - 
                                  DoMin_V0_9_Variable.Boom.find 
                                 to 
                                  DoMin_V0_9_Variable.Y.locate 
                                  + 
                                  DoMin_V0_9_Variable.Boom.find
                                do begin
                                    if 
                                        (
                                            (
                                                _i 
                                                <= 
                                                DoMin_V0_9_Variable.X.max
                                            ) 
                                            and 
                                            (_i >= 1)
                                        )
                                        and
                                        (
                                            (
                                                _j 
                                                <= 
                                                 DoMin_V0_9_Variable.Y.max 
                                                 + 
                                                 1
                                            ) 
                                            and 
                                            (_j >= 1)
                                        )
                                        and
                                        (DoMin_V0_9_Variable.Board[_i, _j].show = 0)
                                    then begin
                                        DoMin_V0_9_Variable.Board[_i, _j].show:= 1;
                                    end;
                                end;
                            end;
                            DoMin_V0_9_Variable:= DrawBoard(DoMin_V0_9_Variable);
                        end 
                        else begin
                            DoMin_V0_9_Variable:= 
                                MessageToQuit('thua', DoMin_V0_9_Variable);
                            exit;
                        end;
                    end;
                    'm', 'M': begin
                        DoMin_V0_9_Variable:= Menu(DoMin_V0_9_Variable);
                        DrawRawBoard(DoMin_V0_9_Variable);
                    end;
                end;
            end;
        until DoMin_V0_9_Variable.Stop = 1;
    end;
procedure
    MainProcess();
    begin
        if random(C_max) mod 2 = 0
        then DoMin_V0_9_Variable.Boom.Number:= 
                DoMin_V0_9_Variable.X.max
        else DoMin_V0_9_Variable.Boom.Number:= 
                DoMin_V0_9_Variable.Y.max;
        DoMin_V0_9_Variable.Boom.Difficult.random:= 
            random(DoMin_V0_9_Variable.Boom.Difficult.Level) + 1;
        DoMin_V0_9_Variable.Boom.find:= 
            (DoMin_V0_9_Variable.Boom.Number div 2) 
            div 
            DoMin_V0_9_Variable.Boom.Difficult.Level;
        if 
            (random(C_max * 100000) mod 78936 = 64)
        then DoMin_V0_9_Variable.Boom.Number:= 
                DoMin_V0_9_Variable.Boom.Number 
                * 
                DoMin_V0_9_Variable.Boom.Difficult.Level 
                div 
                DoMin_V0_9_Variable.Boom.find
        else DoMin_V0_9_Variable.Boom.Number:= 
                DoMin_V0_9_Variable.Boom.Number 
                * 
                DoMin_V0_9_Variable.Boom.Difficult.Level 
                div 
                DoMin_V0_9_Variable.Boom.Difficult.random;
        DoMin_V0_9_Variable.Boom.find  := 
            random(DoMin_V0_9_Variable.Boom.find) + 1;
        for _i:= 1 to DoMin_V0_9_Variable.Boom.Number
        do begin
            repeat
                DoMin_V0_9_Variable.SetBoom.X:= 
                    random(DoMin_V0_9_Variable.X.max) + 1;
                DoMin_V0_9_Variable.SetBoom.Y:= 
                    random(DoMin_V0_9_Variable.Y.max) + 2;
            until 
             DoMin_V0_9_Variable.Board[
                DoMin_V0_9_Variable.SetBoom.X, 
                DoMin_V0_9_Variable.SetBoom.Y
             ].Value <> 'X';
            DoMin_V0_9_Variable.Board[
                DoMin_V0_9_Variable.SetBoom.X, 
                DoMin_V0_9_Variable.SetBoom.Y
            ].Value:= 'X';
            for _i1:= 
             DoMin_V0_9_Variable.SetBoom.X - 1 
             to 
             DoMin_V0_9_Variable.SetBoom.X + 1
            do begin
                for _j1:= 
                 DoMin_V0_9_Variable.SetBoom.Y - 1 
                 to 
                 DoMin_V0_9_Variable.SetBoom.Y + 1
                do begin
                    if 
                        (DoMin_V0_9_Variable.Board[_i1, _j1].Value <> 'X')
                        and
                        ((_i <> _i1) or (_j <> _j1))
                    then begin
                        DoMin_V0_9_Variable.Board[_i1, _j1].Value
                            := CharInc(DoMin_V0_9_Variable.Board[_i1,_j1].Value);
                    end;
                end;
            end;
        end;
        DoMin_V0_9_Variable.console.FontSize:= Set_console_fontsize(TextNormal);
        play();
    end;
procedure
    GetInput();
    begin
        DoMin_V0_9_Variable.console.FontSize:= Set_console_fontsize(TextLarge);
        WindowsGenerator(18, 2);
        DoMin_V0_9_Variable.Y.max:= GetXorY('hàng');
        DoMin_V0_9_Variable.X.max:= GetXorY('cột');
        WindowsGenerator(18, 5);
        clrscr;
        repeat
            TVWriteln('Chọn độ khó:');
            TVWriteln('[1]: Dễ');
            TVWriteln('[2]: Trung bình');
            TVWriteln('[3]: Khó');
            TVWrite  ('[4]: GOD!!!!!!!!');
            _key:= readkey;
            case _key of    
                '1': begin 
                    DoMin_V0_9_Variable.Boom.Difficult.Level:= 2;
                    programTitle('Game này là dễ!!!')
                end;
                '2': begin 
                    DoMin_V0_9_Variable.Boom.Difficult.Level:= 3;
                    programTitle('Hơi khó đấy')
                end;
                '3': begin 
                    DoMin_V0_9_Variable.Boom.Difficult.Level:= 4;
                    programTitle('Hổng vui rồi đó')
                end;
                '4': begin 
                    DoMin_V0_9_Variable.Boom.Difficult.Level:= 5;
                    programTitle('Hận thằng viết chương trình')
                end;
                else DoMin_V0_9_Variable.Boom.Difficult.Level:= random(4) + 2;
            end;
        until 
            (DoMin_V0_9_Variable.Boom.Difficult.Level = 2)
            or
            (DoMin_V0_9_Variable.Boom.Difficult.Level = 3)
            or
            (DoMin_V0_9_Variable.Boom.Difficult.Level = 4)
            or
            (DoMin_V0_9_Variable.Boom.Difficult.Level = 5);
        MainProcess();
    end;
BEGIN
    DoMin_V0_9_Variable.console.FontSize:= Set_console_fontsize(TextNormal);
    randomize;
    cursoroff;
    repeat
        resetValue();
        GetInput();
    until DoMin_V0_9_Variable.Stop = 1;
END.