module scone.color;

import std.format : format;

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

/// both `ForegroundColor` and `BackgroundColor` work the same way. this is not not have duplicate code :)
private template ColorTemplate()
{
    this(Color c)
    {
        color = c;
    }

    Color color;
    alias color this;
}

/// Container for foreground colors
struct ForegroundColor
{
    mixin ColorTemplate;
}

/// Container for background colors
struct BackgroundColor
{
    mixin ColorTemplate;
}

/**
 * Example:
 * ---
 * window.write(0,0, Color.red.foreground, "string");
 * ---
 */
ForegroundColor foreground(Color color)
{
    return ForegroundColor(color);
}

/// ditto
deprecated alias fg = foreground;

/**
 * Example:
 * ---
 * window.write(0,0, Color.blue.background, "string");
 * ---
 */
BackgroundColor background(Color color)
{
    return BackgroundColor(color);
}

/// ditto
deprecated alias bg = background;

/**
 * Check if a color is a light color
 * Params:
 *     color = A type of color. Either `Color`, `ForegroundColor`, or `BackgroundColor`
 * Return: bool, true if light color, false otherwise
 */
pure auto isLight(C)(C color) if (is(C : Color))
{
    return color >= Color.black && color <= Color.white;
}
///
@system unittest
{
    assert(Color.red.isLight);
    assert(!Color.redDark.isLight);
    assert(Color.red.foreground.isLight);
    assert(background(Color.red).isLight);
}

/**
 * Check if a color is a dark color
 * Params:
 *     color = A type of color. Either `Color`, `ForegroundColor`, or `BackgroundColor`
 * Return: bool, true if dark color, false otherwise
 */
pure auto isDark(C)(C color) if (is(C : Color))
{
    return color >= Color.blackDark && color <= Color.whiteDark;
}
///
@system unittest
{
    assert(!Color.red.isDark);
    assert(Color.redDark.isDark);
    assert(Color.redDark.foreground.isDark);
    assert(background(Color.redDark).isDark);
}

/**
 * See if color is a proper color
 */
pure auto isActualColor(C)(C color) if (is(C : Color))
{
    return color.isLight || color.isDark;
}
///
@system unittest
{
    assert(Color.red.isActualColor);
    assert(Color.red.foreground.isActualColor);
    assert(Color.blueDark.isActualColor);
    assert(!Color.same.isActualColor);
}

/**
 * Params:
 *     color = A type of color. Either `Color`, `ForegroundColor`, or `BackgroundColor`
 */
pure C light(C)(C color) if (is(C : Color))
{
    if (color.isDark)
    {
        color = cast(Color)(color - 8);
    }

    return color;
}
///
unittest
{
    assert(Color.redDark.light == Color.red);
    assert(Color.red.light == Color.red);
    assert(Color.redDark.foreground.light == Color.red.foreground);
    assert(Color.redDark.background.light == Color.red.background);
    assert(Color.same.light == Color.same);
}

/**
 * Params:
 *     color = A type of color. Either `Color`, `ForegroundColor`, or `BackgroundColor`
 */
pure C dark(C)(C color) if (is(C : Color))
{
    if (color.isLight)
    {
        color = cast(Color)(color + 8);
    }

    return color;
}
///
unittest
{
    assert(Color.redDark.dark == Color.redDark);
    assert(Color.red.dark == Color.redDark);
    assert(Color.redDark.foreground.dark == Color.redDark.foreground);
    assert(Color.redDark.background.dark == Color.redDark.background);
    assert(Color.same.dark == Color.same);
}
