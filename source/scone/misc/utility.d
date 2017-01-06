module scone.misc.utility;

///General flag checking
bool hasFlag(Type)(Type check, Type type)
{
    return ((check & type) == type);
}

