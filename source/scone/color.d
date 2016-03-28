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
    black   = 30,
    red     = 31,
    green   = 32,
    yellow  = 33,
    blue    = 34,
    magenta = 35,
    cyan    = 36,
    white   = 37,

    black_dark   = 90,
    red_dark     = 91,
    green_dark   = 92,
    yellow_dark  = 93,
    blue_dark    = 94,
    magenta_dark = 95,
    cyan_dark    = 96,
    white_dark   = 97,
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

///Index Light Color Start
enum ilcs = 30;
///Index Light Color End
enum ilce = 37;
///Index Dark Color Start
enum idcs = 90;
///Index Dark Color Start
enum idce = 97;

/**
 * Get dark color variant from color
 * Returns: Dark variant of `Color`. If not a light color, return input
 */
auto darkColorFromColor(Color c)
{
    if(colorIsLight(c))
    {
        if(c == Color.red)
        {
            return Color.red_dark;
        }
        else if(c == Color.green)
        {
            return Color.green_dark;
        }
        else if(c == Color.yellow)
        {
            return Color.yellow_dark;
        }
        else if(c == Color.blue)
        {
            return Color.blue_dark;
        }
        else if(c == Color.magenta)
        {
            return Color.magenta_dark;
        }
        else if(c == Color.cyan)
        {
            return Color.cyan_dark;
        }
        else if(c == Color.white)
        {
            return Color.white_dark;
        }
        else if(c == Color.black)
        {
            return Color.black_dark;
        }
    }

    return c;
}

/**
 * Get light color variant from color
 * Returns: Light variant of `Color`. If not a dark color, return input
 */
auto lightColorFromColor(Color c)
{
    if(colorIsDark(c))
    {
        if(c == Color.red_dark)
        {
            return Color.red;
        }
        else if(c == Color.green_dark)
        {
            return Color.green;
        }
        else if(c == Color.yellow_dark)
        {
            return Color.yellow;
        }
        else if(c == Color.blue_dark)
        {
            return Color.blue;
        }
        else if(c == Color.magenta_dark)
        {
            return Color.magenta;
        }
        else if(c == Color.cyan_dark)
        {
            return Color.cyan;
        }
        else if(c == Color.white_dark)
        {
            return Color.white;
        }
        else if(c == Color.black_dark)
        {
            return Color.black;
        }
    }

    return c;
}

/**
 * Check if a color is dark
 * Returns: true if color is a dark variant
 */
auto colorIsDark(Color c)
{
    return c >= idcs && c <= idce;
}

/**
 * Check if a color is light
 * Returns: true if color is a light variant
 */
auto colorIsLight(Color c)
{
    return c >= ilcs && c <= ilce;
}

