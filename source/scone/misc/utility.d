module scone.misc.utility;

import std.traits : isIntegral;

/// General flag checking
auto hasFlag(T)(T value, T flag) if (isIntegral!(T))
{
    return ((value & flag) == flag);
}
