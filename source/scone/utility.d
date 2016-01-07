module scone.utility;

import scone.keyboard;

/**
 * All colors
 * --------------------
 * //Available colors:
 * init
 *
 * black
 * blue
 * blue_dark
 * cyan
 * cyan_dark
 * gray
 * gray_dark
 * green
 * green_dark
 * magenta
 * magenta_dark
 * red
 * red_dark
 * white
 * yellow
 * yellow_dark
 * --------------------
 */
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

///ditto
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
bool moduleWindow   = false;
bool moduleKeyboard = false;
bool moduleAudio    = false;
KeyEvent[] keyInputs;
