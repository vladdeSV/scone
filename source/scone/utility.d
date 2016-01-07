module scone.utility;

import scone.keyboard;

///All foreground colors
enum fg
{
    init,

    black,
    blue,
    blue_dark,
    cyan,
    cyan_dark,
    gray,
    gray_dark,
    green,
    green_dark,
    magenta,
    magenta_dark,
    red,
    red_dark,
    white,
    yellow,
    yellow_dark
}

///All background colors
enum bg
{
    init,

    black,
    blue,
    blue_dark,
    cyan,
    cyan_dark,
    gray,
    gray_dark,
    green,
    green_dark,
    magenta,
    magenta_dark,
    red,
    red_dark,
    white,
    yellow,
    yellow_dark
}

//General flag checking
bool hasFlag(Enum)(Enum check, Enum type) if (is(Enum == enum))
{
    return ((check & type) == type);
}

package(scone):
__gshared bool moduleWindow   = false;
__gshared bool moduleKeyboard = false;
__gshared bool moduleAudio    = false;
__gshared KeyEvent[] keyInputs;
