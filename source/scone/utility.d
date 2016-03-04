module scone.utility;

import scone.keyboard;
import scone.core : sconeClose;
import std.format : format;

///General flag checking
bool hasFlag(Type)(Type check, Type type)
{
    return ((check & type) == type);
}

package(scone):
auto sconeCrash(Args...)(string msg, Args args)
{
    sconeClose();
    assert(0, format("\n\n" ~ msg ~ '\n', args));
}

auto sconeCrashIf(Args...)(bool check, string msg, Args args)
{
    if(check)
    {
        sconeCrash(msg, args);
    }
}

enum ColorType
{
    foreground,
    background,
}

template colorTemplate(ColorType type)
{
    enum Color
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
}
