module scone.utility;

import scone.keyboard;
import scone.core : sconeClose;
import std.format : format;

package(scone):

///General flag checking
bool hasFlag(Type)(Type check, Type type)
{
    return ((check & type) == type);
}
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
