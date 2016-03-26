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
    foreground = 0,
    background = 10,
}

template colorTemplate(ColorType type)
{
    int e = cast(int) type;
    enum Color
    {
        black   = 30 + e,
        red     = 31 + e,
        green   = 32 + e,
        yellow  = 33 + e,
        blue    = 34 + e,
        magenta = 35 + e,
        cyan    = 36 + e,
        white   = 37 + e,

        black_dark   = 90 + e,
        red_dark     = 91 + e,
        green_dark   = 92 + e,
        yellow_dark  = 93 + e,
        blue_dark    = 94 + e,
        magenta_dark = 95 + e,
        cyan_dark    = 96 + e,
        white_dark   = 97 + e
    }
}
