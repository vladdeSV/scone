module scone.output.text_style;

import scone.output.types.color : Color;
import std.typecons : Nullable;

struct TextStyle
{
    typeof(this) fg(Color color)
    {
        this.foreground = color;

        return this;
    }

    typeof(this) bg(Color color)
    {
        this.background = color;

        return this;
    }

    Nullable!Color foreground;
    Nullable!Color background;
}

unittest
{
    auto style1 = TextStyle();
    assert(style1.foreground.isNull);
    assert(style1.background.isNull);

    auto style2 = TextStyle().bg(Color.green);
    assert(style2.foreground.isNull);
    assert(style2.background.get == Color.green);

    auto style3 = TextStyle(Color.red);
    assert(style3.foreground.get == Color.red);
    assert(style3.background.isNull);
}

unittest
{
    auto style1 = TextStyle().fg(Color.red).bg(Color.green);
    assert(style1.foreground.get == Color.red);
    assert(style1.background.get == Color.green);

    auto style2 = TextStyle(Color.green, Color.red);
    style2.foreground.get = Color.red;
    style2.background.get = Color.green;

    assert(style1 == style2);
}
