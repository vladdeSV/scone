module scone.utility;

import scone.keyboard;

//General flag checking
bool hasFlag(Enum)(Enum check, Enum type) if (is(Enum == enum))
{
    return ((check & type) == type);
}

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

package(scone):
__gshared bool moduleWindow   = false;
__gshared bool moduleKeyboard = false;
__gshared bool moduleAudio    = false;
__gshared KeyEvent[] keyInputs;
