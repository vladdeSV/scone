module scone.output.types.color;

/**
 * All colors
 *
 * Example:
 * --------------------
 * // Available colors:
 * black       // darker grey
 * blackDark   // black
 * blue
 * blueDark
 * cyan
 * cyanDark
 * green
 * greenDark
 * magenta
 * magentaDark
 * red
 * redDark
 * white       // white
 * whiteDark   // lighter grey
 * yellow
 * yellowDark
 * --------------------
 */
enum Color
{
    black = 0,
    red = 1,
    green = 2,
    yellow = 3,
    blue = 4,
    magenta = 5,
    cyan = 6,
    white = 7,

    blackDark = 8,
    redDark = 9,
    greenDark = 10,
    yellowDark = 11,
    blueDark = 12,
    magentaDark = 13,
    cyanDark = 14,
    whiteDark = 15,

    same = 16,
    initial = 17,
}

unittest
{
    // ensure there are 8 colors from Color.white(Dark) to Color.black(Dark)
    assert(Color.white - Color.black == 7);
    assert(Color.whiteDark - Color.blackDark == 7);
}

pure auto isLight(Color color)
{
    return color >= Color.black && color <= Color.white;
}
unittest
{
    assert(Color.red.isLight);
    assert(!Color.redDark.isLight);
}

auto isDark(Color color)
{
    return color >= Color.blackDark && color <= Color.whiteDark;
}
unittest
{
    assert(!Color.red.isDark);
    assert(Color.redDark.isDark);
}

pure auto isActualColor(Color color)
{
    return color.isLight || color.isDark;
}
@system unittest
{
    assert(Color.red.isActualColor);
    assert(Color.blueDark.isActualColor);
    assert(!Color.same.isActualColor);
}

pure Color light(Color color)
{
    if (color.isDark)
    {
        color = cast(Color)(color - 8);
    }

    return color;
}
unittest
{
    assert(Color.redDark.light == Color.red);
    assert(Color.red.light == Color.red);
    assert(Color.same.light == Color.same);
}

pure Color dark(Color color)
{
    if (color.isLight)
    {
        color = cast(Color)(color + 8);
    }

    return color;
}
unittest
{
    assert(Color.redDark.dark == Color.redDark);
    assert(Color.red.dark == Color.redDark);
    assert(Color.same.dark == Color.same);
}
