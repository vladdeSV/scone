module scone.utility;

import scone.keyboard;
import scone.core : sconeClose;
import std.format : format;

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
bool hasFlag(Enum)(int check, Enum type) if (is(Enum == enum))
{
    return ((check & type) == type);
}

/**
 * Slot structure
 *
 * Examples:
 * --------------------
 * Slot slot1 = Slot('d', fg.red, bg.white); //'d' character with RED foreground color and WHITE background color
 * Slot slot2 = Slot('g');
 *
 * auto window = new Window();
 * window.write(0,0, slot1);
 * window.write(0,1, slot2);
 * --------------------
 *
 */
struct Slot
{
    char character;
    fg foreground = fg.init;
    bg background = bg.init;
}

package(scone):

auto sconeCrash(Args...)(bool check, string msg, Args args)
{
    if(check)
    {
        sconeCrash(msg, args);
    }
}
auto sconeCrash(Args...)(string msg, Args args)
{
    sconeClose();
    assert(0, format("\n\n" ~ msg ~ '\n', args));
}

bool moduleWindow   = false;
bool moduleKeyboard = false;
bool moduleAudio    = false;
KeyEvent[] keyInputs;
