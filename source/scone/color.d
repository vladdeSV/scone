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
    black = colorStartIndex,
    red,
    green,
    yellow,
    blue,
    magenta,
    cyan,
    white,

    black_dark = darkColorStartIndex,
    red_dark,
    green_dark,
    yellow_dark,
    blue_dark,
    magenta_dark,
    cyan_dark,
    white_dark,
}

struct fg
{
    mixin ColorTemplate;
}

struct bg
{
    mixin ColorTemplate;
}

//For POSIX support, these values need to start at 30 and 90 respectively.
//However, OSX reversed the numbers for bright and dark colors.
version(OSX)
{
    private enum colorStartIndex = 90;
    private enum darkColorStartIndex = 30;
}
else
{
    private enum colorStartIndex = 30;
    private enum darkColorStartIndex = 90;
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