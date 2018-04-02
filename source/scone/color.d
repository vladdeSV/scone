module scone.color;

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
}

/**
 * Definition of a foreground color.
 * Example:
 * ---
 * window.write(0,0, fg(Color.red), "item");
 * ---
 */
struct fg
{
    mixin ColorTemplate;
}

/**
 * Definition of a background color.
 * Example:
 * ---
 * window.write(0,0, bg(Color.white), "item");
 * ---
 */
struct bg
{
    mixin ColorTemplate;
}

///both `fg` and `bg` work the same way. this is not not have duplicate code :)
private template ColorTemplate()
{
    this(Color c)
    {
        color = c;
    }

    Color color;
    alias color this;
}
