module scone.output.types.color;

import scone.output.text_style : TextStyle;
import std.typecons : Nullable;

enum AnsiColor
{
    initial = 16,

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
}

struct RGB
{
    ubyte r, g, b;
}

enum ColorState
{
    ansi,
    rgb,
    same,
}

struct Color
{
    static Color same()
    {
        Color color = Color();
        color.colorState = ColorState.same;
        color.ansiColor.nullify();
        color.rgbColor.nullify();

        return color;
    }

    // generate creation methods from AnsiColor
    import std.traits : EnumMembers;
    import std.conv : to;

    static foreach (member; EnumMembers!AnsiColor)
    {
        mixin("
        static Color "
                ~ to!string(member) ~ "()
        {
            Color color = Color();
            color.colorState = ColorState.ansi;
            color.ansiColor = AnsiColor."
                ~ to!string(
                    member) ~ ";
            color.rgbColor.nullify();

            return color;
        }
        ");
    }

    version (Posix) static Color rgb(ubyte r, ubyte g, ubyte b)
    {
        Color color = Color();
        color.colorState = ColorState.rgb;
        color.ansiColor.nullify();
        color.rgbColor = RGB(r, g, b);

        return color;
    }

    ColorState state()
    {
        return this.colorState;
    }

    AnsiColor ansi()
    {
        assert(!this.ansiColor.isNull);
        return this.ansiColor.get();
    }

    version (Posix) RGB rgb()
    {
        assert(!this.rgbColor.isNull);
        return this.rgbColor.get();
    }

    private ColorState colorState = ColorState.ansi;
    private Nullable!AnsiColor ansiColor = AnsiColor.initial;
    private Nullable!RGB rgbColor;
}
///
unittest
{
    Color a;
    assert(a.colorState == ColorState.ansi);
    assert(a.ansiColor == AnsiColor.initial);
    assert(a.state() == ColorState.ansi);
    assert(a.ansi() == AnsiColor.initial);
    assert(a.rgbColor.isNull());

    Color b = Color.red;
    assert(b.colorState == ColorState.ansi);
    assert(b.ansiColor == AnsiColor.red);
    assert(b.state() == ColorState.ansi);
    assert(b.ansi() == AnsiColor.red);
    assert(b.rgbColor.isNull());

    version (Posix)
    {
        Color c = Color.rgb(123, 232, 123);
        assert(c.colorState == ColorState.rgb);
        assert(c.state() == ColorState.rgb);
        assert(c.ansiColor.isNull());
        assert(c.rgbColor == RGB(123, 232, 123));
        assert(c.rgb() == RGB(123, 232, 123));
    }

    Color d = Color.same;
    assert(d.colorState == ColorState.same);
    assert(d.state() == ColorState.same);
    assert(d.ansiColor.isNull());
    assert(d.rgbColor.isNull());
}

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
