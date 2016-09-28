module scone.misc.utility;

import scone.input.keyboard;
import scone.misc.core : sconeClose;
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
        assert(0, "\n\n%s\n".format(msg.format(formatArgs)));
    }
}
