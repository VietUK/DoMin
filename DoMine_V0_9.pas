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
    DoMinVar : ProV;
    _i1, _j1 : integer;
    _key     : char;
procedure
    play();
    begin
        DoMinVar.X.locate:= 1;
        DoMinVar.Y.locate:= 2;
        DrawRawBoard(DoMinVar);
        for _i:= C_maxAm to C_max
        do begin
            for _j:= C_maxAm to C_max
            do begin
                DoMinVar.Board[_i, _j].show := 0;
            end;
        end;
        repeat
            SetConFont(DoMinVar.console.FontSize);
            gotoXY(DoMinVar.X.locate, DoMinVar.Y.locate);
            make_Footprint(
                DoMinVar.X.locate, 
                DoMinVar.Y.locate, 
                DoMinVar
                );
            if (DoMinVar.Stop = 1) or (DoMinVar.Stop = 2)
            then exit
            else begin
                repeat
                    {if keypressed
                    then begin}     
                        _key:= readkey;
                        case _key of 
                            'a', 'A': 
                             DoMinVar.X.locate:= 
                                processWayGo(
                                    DoMinVar.X.locate, 1, 0,
                                    DoMinVar.X.locate + 1, 
                                    DoMinVar.Y.locate, 0, 
                                    DoMinVar.X.max,
                                    DoMinVar
                                );
                            'w', 'W': 
                             DoMinVar.Y.locate:= 
                                processWayGo(
                                    DoMinVar.Y.locate, 1, 1,
                                    DoMinVar.X.locate, 
                                    DoMinVar.Y.locate + 1, 1, 
                                    DoMinVar.Y.max + 1,
                                    DoMinVar
                                );
                            'd', 'D': 
                             DoMinVar.X.locate:= 
                                processWayGo(
                                    DoMinVar.X.locate, 0, 0,
                                    DoMinVar.X.locate - 1, 
                                    DoMinVar.Y.locate, 0, 
                                    DoMinVar.X.max,
                                    DoMinVar
                                );
                            's', 'S': 
                             DoMinVar.Y.locate:= 
                                processWayGo(
                                    DoMinVar.Y.locate, 0, 1,
                                    DoMinVar.X.locate, 
                                    DoMinVar.Y.locate - 1, 1, 
                                    DoMinVar.Y.max + 1,
                                    DoMinVar
                                );
                            'q', 'Q': halt();
                        end;
                    {end;}
                until 
                    (   
                        ((_key = 'c') or (_key = 'C')) 
                        and 
                        (
                            DoMinVar.Board[  
                                DoMinVar.X.locate, 
                                DoMinVar.Y.locate
                            ].show = 0
                        )
                    )
                    or
                    ((_key = 'm') or (_key = 'M'))
                    or
                    (
                        DoMinVar.Board[
                            DoMinVar.X.locate, 
                            DoMinVar.Y.locate
                        ].Val = 'X'
                    )
                    ;
                case _key of
                    'c', 'C': begin
                        if 
                            DoMinVar.Board[
                                DoMinVar.X.locate, 
                                DoMinVar.Y.locate
                            ].Val
                            <>
                            'X'
                        then begin
                            for _i:= 
                              DoMinVar.X.locate 
                              - 
                              DoMinVar.Boom.find 
                             to 
                              DoMinVar.X.locate 
                              + 
                              DoMinVar.Boom.find
                            do begin
                                for _j:= 
                                  DoMinVar.Y.locate 
                                  - 
                                  DoMinVar.Boom.find 
                                 to 
                                  DoMinVar.Y.locate 
                                  + 
                                  DoMinVar.Boom.find
                                do begin
                                    if 
                                        (
                                            (
                                                _i 
                                                <= 
                                                DoMinVar.X.max
                                            ) 
                                            and 
                                            (_i >= 1)
                                        )
                                        and
                                        (
                                            (
                                                _j 
                                                <= 
                                                 DoMinVar.Y.max 
                                                 + 
                                                 1
                                            ) 
                                            and 
                                            (_j >= 1)
                                        )
                                        and
                                        (DoMinVar.Board[_i, _j].show = 0)
                                    then begin
                                        DoMinVar.Board[_i, _j].show:= 1;
                                    end;
                                end;
                            end;
                            DoMinVar:= DrawBoard(DoMinVar);
                        end 
                        else begin
                            DoMinVar:= 
                                MessageToQuit('thua', DoMinVar);
                            exit;
                        end;
                    end;
                    'm', 'M': begin
                        DoMinVar:= Menu(DoMinVar);
                        DrawRawBoard(DoMinVar);
                    end;
                end;
            end;
        until DoMinVar.Stop = 1;
    end;
procedure
    MainProcess();
    begin
        if random(C_max) mod 2 = 0
        then DoMinVar.Boom.Number:= 
                DoMinVar.X.max
        else DoMinVar.Boom.Number:= 
                DoMinVar.Y.max;
        DoMinVar.Boom.Difficult.random:= 
            random(DoMinVar.Boom.Difficult.Level) + 1;
        DoMinVar.Boom.find:= 
            (DoMinVar.Boom.Number div 2) 
            div 
            DoMinVar.Boom.Difficult.Level;
        if 
            (random(C_max * 100000) mod 78936 = 64)
        then DoMinVar.Boom.Number:= 
                DoMinVar.Boom.Number 
                * 
                DoMinVar.Boom.Difficult.Level 
                div 
                DoMinVar.Boom.find
        else DoMinVar.Boom.Number:= 
                DoMinVar.Boom.Number 
                * 
                DoMinVar.Boom.Difficult.Level 
                div 
                DoMinVar.Boom.Difficult.random;
        DoMinVar.Boom.find  := 
            random(DoMinVar.Boom.find) + 1;
        for _i:= 1 to DoMinVar.Boom.Number
        do begin
            repeat
                DoMinVar.SetBoom.X:= random(DoMinVar.X.max) + 1;
                DoMinVar.SetBoom.Y:= random(DoMinVar.Y.max) + 2;
            until 
             DoMinVar.Board[DoMinVar.SetBoom.X, DoMinVar.SetBoom.Y].Val <> 'X';
             DoMinVar.Board[DoMinVar.SetBoom.X, DoMinVar.SetBoom.Y].Val:= 'X';
            for _i1:= DoMinVar.SetBoom.X - 1 
                      to 
                      DoMinVar.SetBoom.X + 1
            do begin
                for _j1:= DoMinVar.SetBoom.Y - 1 
                          to 
                          DoMinVar.SetBoom.Y + 1
                do begin
                    if 
                        (DoMinVar.Board[_i1, _j1].Val <> 'X')
                        and
                        ((_i <> _i1) or (_j <> _j1))
                    then begin
                        DoMinVar.Board[_i1, _j1].Val:= CharInc(DoMinVar.Board[_i1,_j1].Val);
                    end;
                end;
            end;
        end;
        SetConFont(TextNormal);
    end;
procedure
    GetInput();
    begin
        SetConFont(TextLarge);
        WindowsGenerator(18, 2);
        DoMinVar.Y.max:= GetXorY('hàng');
        DoMinVar.X.max:= GetXorY('cột');
        WindowsGenerator(16, 5);
        clrscr;
        repeat
            TVWriteln('Chọn độ khó:    ', black  , white);
            TVWriteln('[1]: Dễ         ', green  , black);
            TVWriteln('[2]: Trung bình ', yellow , black);
            TVWriteln('[3]: Khó        ', red    , black);
            TVWrite  ('[4]: GOD!!!!!!!!', black  , red);
            _key:= readkey;
            case _key of    
                '1': begin 
                    DoMinVar.Boom.Difficult.Level:= 2;
                    programTitle('Game này là dễ!!!')
                end;
                '2': begin 
                    DoMinVar.Boom.Difficult.Level:= 3;
                    programTitle('Hơi khó đấy')
                end;
                '3': begin 
                    DoMinVar.Boom.Difficult.Level:= 4;
                    programTitle('Hổng vui rồi đó')
                end;
                '4': begin 
                    DoMinVar.Boom.Difficult.Level:= 5;
                    programTitle('Hận thằng viết chương trình')
                end;
                else DoMinVar.Boom.Difficult.Level:= random(4) + 2;
            end;
        until 
            (DoMinVar.Boom.Difficult.Level = 2)
            or
            (DoMinVar.Boom.Difficult.Level = 3)
            or
            (DoMinVar.Boom.Difficult.Level = 4)
            or
            (DoMinVar.Boom.Difficult.Level = 5);
    end;
BEGIN
    SetConFont(TextNormal);
    randomize;
    cursoroff;
    repeat
        DoMinVar:= resetVal();
        GetInput();
        MainProcess();
        play();
    until DoMinVar.Stop = 1;
END.