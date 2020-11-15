module scone.output.types.color;

import scone.output.text_style : TextStyle;

enum AnsiColor
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

    same,
    initial,
}

struct RGB
{
    int r, g, b;
}

enum ColorState
{
    ansi,
    rgb,
}

struct Color
{
    static typeof(this) rgb(int r, int g, int b)
    {
        auto color = Color.init;
        color.state = ColorState.rgb;
        color.rgbColor = RGB(r, g, b);
        return color;
    }

    // generate creation methods from AnsiColor
    import std.traits : EnumMembers;
    import std.conv : to;
    static foreach (member; EnumMembers!AnsiColor)
    {
        mixin("
        static typeof(this) " ~ to!string(member) ~ "()
        {
            Color c = Color.init;
            c.ansi = AnsiColor." ~ to!string(member) ~ ";
            return c;
        }
        ");
    }

    ColorState state = ColorState.ansi;
    AnsiColor ansi = AnsiColor.initial;
    RGB rgbColor;
}
///
unittest
{
    Color a;
    assert(a.ansi == AnsiColor.initial);
    assert(a.state == ColorState.ansi);
    assert(a.rgbColor == RGB.init);

    Color b = Color.red;
    assert(b.ansi == AnsiColor.red);
    assert(b.state == ColorState.ansi);
    assert(b.rgbColor == RGB.init);

    Color c = Color.rgb(123, 232, 123);
    assert(c.ansi == AnsiColor.initial);
    assert(c.state == ColorState.rgb);
    assert(c.rgbColor == RGB(123, 232, 123));
}

deprecated
{
    ///
    TextStyle foreground(Color color)
    {
        return TextStyle().fg(color);
    }
    ///
    unittest
    {
        assert(TextStyle(Color.red, Color.same) == Color.red.foreground);
        assert(TextStyle().fg(Color.red) == foreground(Color.red));
    }

    ///
    TextStyle background(Color color)
    {
        return TextStyle().bg(color);
    }
    ///
    unittest
    {
        assert(TextStyle(Color.same, Color.green) == Color.green.background);
        assert(TextStyle().bg(Color.green) == background(Color.green));
    }
}
