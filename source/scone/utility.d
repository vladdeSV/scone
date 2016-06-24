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

auto sconeAssert(FormatArgs...)(bool check, string msg, FormatArgs formatArgs)
{
    if(!check)
    {
        sconeClose();
        assert(0, format("\n\n" ~ msg ~ '\n', formatArgs));
    }
}
