module scone.color;

/**
 * All colors
 *
 * Example:
 * --------------------
 * //Available colors:
 * black
 * black_dark
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
 * white
 * white_dark
 * yellow
 * yellow_dark
 * --------------------
 */
enum Color
{
    black   = ilcs,
    red     = ilcs + 1,
    green   = ilcs + 2,
    yellow  = ilcs + 3,
    blue    = ilcs + 4,
    magenta = ilcs + 5,
    cyan    = ilcs + 6,
    white   = ilce,

    black_dark   = idcs,
    red_dark     = idcs + 1,
    green_dark   = idcs + 2,
    yellow_dark  = idcs + 3,
    blue_dark    = idcs + 4,
    magenta_dark = idcs + 5,
    cyan_dark    = idcs + 6,
    white_dark   = idce,
}

///Index Light Color Start
enum ilcs = 0;
///Index Light Color End
enum ilce = ilcs + 7;
///Index Dark Color Start
enum idcs = ilce + 1;
///Index Dark Color Start
enum idce = idcs + 7;

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
 * Foreground type
 * Example:
 * --------
 * frame.write(0,0, fg(Color.red), "scone"); //Writes "scone" in red
 * --------
 */
struct fg
{
    mixin ColorTemplate;
}

/**
 * Background type
 * Example:
 * --------
 * frame.write(0,0, bg(Color.red), "scone"); //Writes "scone" white with a red background
 * --------
 */
struct bg
{
    mixin ColorTemplate;
}

/**
 * Get dark color variant from color
 * Returns: Dark variant of `Color`. If not a light color, return input
 */
auto darkColor(Color c)
{
    return isLightColor(c) ? cast(Color)(c + idcs) : c;
}
unittest
{
    assert(darkColor(Color.red)      == Color.red_dark);
    assert(darkColor(Color.red_dark) == Color.red_dark);

    auto undefColor = cast(Color) 4242;
    assert(darkColor(undefColor) == undefColor);
}

/**
 * Get light color variant from color
 * Returns: Light variant of `Color`. If not a dark color, return input
 */
auto lightColor(Color c)
{
    return isDarkColor(c) ? cast(Color)(c - idcs) : c;
}
unittest
{
    assert(lightColor(Color.green_dark) == Color.green);
    assert(lightColor(Color.green)      == Color.green);

    auto undefColor = cast(Color) 4242;
    assert(lightColor(undefColor) == undefColor);
}

/**
 * Check if a color is dark
 * Returns: true if color is a dark variant
 */
auto isDarkColor(Color c)
{
    return c >= idcs && c <= idce;
}
unittest
{
    assert(isDarkColor(Color.blue_dark) == true);
    assert(isDarkColor(Color.blue)      == false);

    auto undefColor = cast(Color) 4242;
    assert(isDarkColor(undefColor) == false);
}

/**
 * Check if a color is light
 * Returns: true if color is a light variant
 */
auto isLightColor(Color c)
{
    return c >= ilcs && c <= ilce;
}
unittest
{
    assert(isLightColor(Color.yellow)      == true);
    assert(isLightColor(Color.yellow_dark) == false);

    auto undefColor = cast(Color) 4242;
    assert(isLightColor(undefColor) == false);
}
