module scone.output.text_style;

import scone.output.types.color : Color;

/// Semi-factory
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

    Color foreground = Color.same;
    Color background = Color.same;
}

unittest
{
    auto style1 = TextStyle();
    assert(style1.foreground == Color.same);
    assert(style1.background == Color.same);

    auto style2 = TextStyle().bg(Color.green);
    assert(style2.foreground == Color.same);
    assert(style2.background == Color.green);
}

unittest
{
    auto style1 = TextStyle().fg(Color.red).bg(Color.green);
    assert(style1.foreground == Color.red);
    assert(style1.background == Color.green);

    auto style2 = TextStyle();
    style2.foreground = Color.red;
    style2.background = Color.green;

    assert(style1 == style2);
}
