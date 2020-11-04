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

    typeof(this) bold(bool isBold)
    {
        this.isBold = isBold;

        return this;
    }

    Color foreground = Color.same;
    Color background = Color.same;
    bool isBold;
}

unittest
{
    auto a = TextStyle().fg(Color.red).bg(Color.green);
    assert(a.foreground == Color.red);
    assert(a.background == Color.green);
    assert(a.isBold == false);

    auto b = TextStyle();
    b.foreground = Color.red,
    b.background = Color.green;
    assert(a == b);
}