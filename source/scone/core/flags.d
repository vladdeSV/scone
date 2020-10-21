module scone.core.flags;

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

unittest
{
    assert(0b1111.hasFlag(0b0001));
    assert(!0b1110.hasFlag(0b0001));

    assert(0b1000.withFlag(0b0001) == 0b1001);
    assert(0b1001.withFlag(0b0001) == 0b1001);

    assert(0b1111.withoutFlag(0b0001) == 0b1110);
    assert(0b1110.withoutFlag(0b0001) == 0b1110);
}
