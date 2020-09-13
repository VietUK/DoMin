unit VanhColor;
interface

{$i VanhConst.inc}

Procedure TextColor(Color: Byte);
Procedure TextBackground(Color: Byte);

implementation

    Procedure TextColor(Color: Byte);
    { Switch foregroundcolor }
    Begin
        TextAttr:=(Color and $8f) or (TextAttr and $70);
    End;

    Procedure TextBackground(Color: Byte);
    { Switch backgroundcolor }
    Begin
        TextAttr:=((Color shl 4) and ($f0 and not Blink)) or (TextAttr and ($0f OR Blink) );
    End;

end.