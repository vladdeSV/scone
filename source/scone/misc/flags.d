module scone.misc.flags;

import std.traits : isIntegral;

bool hasFlag(T)(T value, T flag) if (isIntegral!(T))
{
    return ((value & flag) == flag);
}

T withFlag(T)(T value, T flag) if (isIntegral!(T))
{
    return value | flag;
}

T withoutFlag(T)(T value, T flag) if (isIntegral!(T))
{
    return value & ~flag;
}
