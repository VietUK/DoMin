unit BSODunit;
interface
uses vanhunit_V0_2, sysutils;
const 
    black          = '0';
    blue           = '1';
    green          = '2';
    aqua           = '3';
    red            = '4';
    purple         = '5';
    yellow         = '6';
    white          = '7';
    gray           = '8';
    lightblue      = '9';
    LightGreen     = 'A';
    LightAqua      = 'B';
    LightRed       = 'C';
    LightPurple    = 'D';
    LightYellow    = 'E';
    BrightWhite    = 'F';
procedure BSOD_Generator(BSOD_Face_String, BSOD_Message_String: string);

implementation

procedure BSOD_Generator(BSOD_Face_String, BSOD_Message_String: string);
    begin
        cursoroff;
        SetConFont(32);
        WindowsGenerator(40,10);
        gotoXY(5,3);
        textColor(strToInt(red));
        TVWrite(BSOD_Face_String);
        gotoXY(5,4);
        TVWrite(BSOD_Message_String);
        color(BrightWhite, lightblue);
    end;
end.