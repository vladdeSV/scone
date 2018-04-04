module scone.color;

import std.traits : EnumMembers;
import std.format : format;

/**
 * All colors
 *
 * Example:
 * --------------------
 * //Available colors:
 * black      //darker grey
 * black_dark //black
 * blue
 * blue_dark
 * cyan
 * cyan_dark
 * green
 * green_dark
 * magenta
 * magenta_dark
 * red
 * red_dark
 * white      //white
 * white_dark //lighter grey
 * yellow
 * yellow_dark
 * --------------------
 */
enum Color
{
    black   = 0,
    red     = 1,
    green   = 2,
    yellow  = 3,
    blue    = 4,
    magenta = 5,
    cyan    = 6,
    white   = 7,

    black_dark   = 8,
    red_dark     = 9,
    green_dark   = 10,
    yellow_dark  = 11,
    blue_dark    = 12,
    magenta_dark = 13,
    cyan_dark    = 14,
    white_dark   = 15,

    unknown = 16
}

/**
 * Definition of a foreground color
 * Example:
 * ---
 * window.write(0,0, Color.red.fg, "item");
 * ---
 */
struct fg
{
    mixin ColorTemplate;
}

/**
 * Definition of a background color
 * Example:
 * ---
 * window.write(0,0, Color.white.bg, "item");
 * ---
 */
struct bg
{
    mixin ColorTemplate;
}

/// both `fg` and `bg` work the same way. this is not not have duplicate code :)
private template ColorTemplate()
{
    this(Color c)
    {
        color = c;
    }

    Color color;
    alias color this;
}

/**
 * Convert a color to it's dark counter-part
 * If the color already is dark, the same color is returned
 * If the color doesn't exist (`cast(Color)123`), `Color.unknown` is returned
 * Params:
 *     color = A type of color. Either `Color`, `fg`, or `bg`
 * Return: Light variant of the same type of color passed in
 */
C light(C)(C color) if (is(C : Color))
{
    auto value = cast(byte)(color);

    static if(value >= 0 && value < 8)
    {
        return color;
    }
    else static if(value >= 8 && value < 16)
    {
        color = cast(Color)(value - 8);
        return color;
    }
    else
    {
        color = Color.unknown;
        return color;
    }
}

/**
 * Convert a color to it's light counter-part
 * If the color already is light, the same color is returned
 * If the color doesn't exist (`cast(Color)123`), `Color.unknown` is returned
 * Params:
 *     color = A type of color. Either `Color`, `fg`, or `bg`
 * Return: Dark variant of the same type of color passed in
 */
C dark(C)(C color) if (is(C : Color))
{
    auto value = cast(byte)(color);

    if(value >= 8 && value < 16)
    {
        return color;
    }
    else if(value >= 0 && value < 8)
    {
        color = cast(Color)(value + 8);
        return color;
    }
    else
    {
        color = Color.unknown;
        return color;
    }
}

/**
 * Check if a color is a light color
 * Params:
 *     color = A type of color. Either `Color`, `fg`, or `bg`
 * Return: bool, true if light color, false otherwise
 */
auto isLight(C)(C color) if (is(C : Color))
{
    auto value = cast(byte)color;
    return value >= 0 && value < 8;
}
///
unittest
{
    assert( Color.red.isLight);
    assert(!Color.red_dark.isLight);
    assert( Color.red.fg.isLight);
    assert( bg(Color.red).isLight);
}

/**
 * Check if a color is a dark color
 * Params:
 *     color = A type of color. Either `Color`, `fg`, or `bg`
 * Return: bool, true if dark color, false otherwise
 */
auto isDark(C)(C color) if (is(C : Color))
{
    auto value = cast(byte)color;
    return value >= 8 && value < 16;
}
///
unittest
{
    assert(!Color.red.isDark);
    assert( Color.red_dark.isDark);
    assert( Color.red_dark.fg.isDark);
    assert( bg(Color.red_dark).isDark);
}
