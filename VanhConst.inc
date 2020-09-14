Const
{ Foreground and background color constants }
    Black         = 0;
    Blue          = 1;
    Green         = 2;
    Cyan          = 3; 
    Red           = 4;
    Magenta       = 5;
    Brown         = 6;
    LightGray     = 7;

{ Foreground color constants }
    DarkGray      = 8;
    LightBlue     = 9;
    LightGreen    = 10;
    LightCyan     = 11;
    LightRed      = 12;
    LightMagenta  = 13;
    Yellow        = 14;
    White         = 15;

{ Add-in for blinking }
    Blink         = 128;
var 
    TextAttr: Byte = $07; 
    
    { FPC Specific for large screen support }
    WindMinX : DWord;
    WindMaxX : DWord;
    WindMinY : DWord;
    WindMaxY : DWord;
type 
    tcrtcoord = 1..255;