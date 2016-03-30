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
version(OSX)
{
    enum ilcs = 90;
}
else
{
    enum ilcs = 30;
}
///Index Dark Color Start
version(OSX)
{
    enum idcs = 30;
}
else
{
    enum idcs = 90;
}
///Index Light Color End
enum ilce = ilcs + 7;
///Index Dark Color Start
enum idce = idcs + 7;

/**
 * Foreground type
 * Example:
 * --------
 * frame.write(0,0, fg(Color.red), "scone"); //Writes "scone" in red
 * --------
 */
struct fg
{
    this(Color c)
    {
        color = c;
    }
    Color color;
    alias color this;
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
    this(Color c)
    {
        color = c;
    }
    Color color;
    alias color this;
}

/**
 * Get dark color variant from color
 * Returns: Dark variant of `Color`. If not a light color, return input
 */
auto darkColorFromColor(Color c)
{
    return colorIsLight(c) ? cast(Color)(c + 60) : c;
}
unittest
{
    assert(darkColorFromColor(Color.red) == Color.red_dark);
    assert(darkColorFromColor(Color.red_dark) == Color.red_dark);
    assert(darkColorFromColor(cast(Color) 1) == cast(Color) 1);
}

/**
 * Get light color variant from color
 * Returns: Light variant of `Color`. If not a dark color, return input
 */
auto lightColorFromColor(Color c)
{
    return colorIsDark(c) ? cast(Color)(c - 60) : c;
}
unittest
{
    assert(lightColorFromColor(Color.green_dark) == Color.green);
    assert(lightColorFromColor(Color.green) == Color.green);
    assert(lightColorFromColor(cast(Color) 1) == cast(Color) 1);
}

/**
 * Check if a color is dark
 * Returns: true if color is a dark variant
 */
auto colorIsDark(Color c)
{
    return c >= idcs && c <= idce;
}
unittest
{
    assert(colorIsDark(Color.blue_dark) == true);
    assert(colorIsDark(Color.blue) == false);
    assert(colorIsDark(cast(Color) 1) == false);
}

/**
 * Check if a color is light
 * Returns: true if color is a light variant
 */
auto colorIsLight(Color c)
{
    return c >= ilcs && c <= ilce;
}
unittest
{
    assert(colorIsLight(Color.yellow) == true);
    assert(colorIsLight(Color.yellow_dark) == false);
    assert(colorIsLight(cast(Color) 1) == false);
}
