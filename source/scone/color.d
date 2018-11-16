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
 * blackDark //black
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
 * white      //white
 * whiteDark //lighter grey
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
    deprecated("use `Color.blackDark` instead") black_dark = 8,
    redDark = 9,
    deprecated("use `Color.redDark` instead") red_dark = 9,
    greenDark = 10,
    deprecated("use `Color.greenDark` instead") green_dark = 10,
    yellowDark = 11,
    deprecated("use `Color.yellowDark` instead") yellow_dark = 11,
    blueDark = 12,
    deprecated("use `Color.blueDark` instead") blue_dark = 12,
    magentaDark = 13,
    deprecated("use `Color.magentaDark` instead") magenta_dark = 13,
    cyanDark = 14,
    deprecated("use `Color.cyanDark` instead") cyan_dark = 14,
    whiteDark = 15,
    deprecated("use `Color.whiteDark` instead") white_dark = 15,

    same = 16,
    unknown = 17,
}
/// ensures within white and black, there is a total of 8 colors
unittest
{
    assert(Color.white - Color.black == 7);
    assert(Color.whiteDark - Color.blackDark == 7);
}

/**
 * Definition of a foreground color
 * Example:
 * ---
 * window.write(0,0, Color.red.foreground, "item");
 * ---
 */
struct ForegroundColor
{
    mixin ColorTemplate;
}

ForegroundColor foreground(Color color)
{
    return ForegroundColor(color);
}

deprecated alias fg = foreground;

/**
 * Definition of a background color
 * Example:
 * ---
 * window.write(0,0, Color.white.background, "item");
 * ---
 */
struct BackgroundColor
{
    mixin ColorTemplate;
}

BackgroundColor background(Color color)
{
    return BackgroundColor(color);
}

deprecated alias bg = background;

/// both `foreground` and `background` work the same way. this is not not have duplicate code :)
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
 * Check if a color is a light color
 * Params:
 *     color = A type of color. Either `Color`, `foreground`, or `background`
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
 *     color = A type of color. Either `Color`, `foreground`, or `background`
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
    assert(!Color.unknown.isActualColor);
}

/**
 * Convert a color to it's dark counter-part
 * If the color already is dark, the same color is returned
 * If the color doesn't exist (`cast(Color)123`), `Color.unknown` is returned
 * Params:
 *     color = A type of color. Either `Color`, `foreground`, or `background`
 * Return: Light variant of the same type of color passed in
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
    assert(Color.unknown.light == Color.unknown);
    assert(Color.same.light == Color.same);
}

/**
 * Convert a color to it's light counter-part
 * If the color already is light, the same color is returned
 * If the color doesn't exist (`cast(Color)123`), `Color.unknown` is returned
 * Params:
 *     color = A type of color. Either `Color`, `foreground`, or `background`
 * Return: Dark variant of the same type of color passed in. If not a color, return same value
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
    assert(Color.unknown.dark == Color.unknown);
    assert(Color.same.dark == Color.same);
}
