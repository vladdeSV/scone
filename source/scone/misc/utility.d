import std.traits : isImplicitlyConvertible;

///General flag checking
auto hasFlag(A, B)(A check, B type) if (isImplicitlyConvertible!(A, B))
{
    return ((check & type) == type);
}

