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
    black,
    red,
    green,
    yellow,
    blue,
    magenta,
    cyan,
    white,

    black_dark,
    red_dark,
    green_dark,
    yellow_dark,
    blue_dark,
    magenta_dark,
    cyan_dark,
    white_dark,
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
 * window.write(0,0, bg(Color.whites), "item");
 * ---
 */
struct bg
{
    mixin ColorTemplate;
}

private template ColorTemplate()
{
    this(Color c)
    {
        color = c;
    }

    Color color;
    alias color this;
}