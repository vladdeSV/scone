module scone.output.text_style;

import scone.output.types.cell : Cell;
import scone.output.types.color : Color;
import std.conv : to;

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

    auto style3 = TextStyle(Color.red);
    assert(style3.foreground == Color.red);
    assert(style3.background == Color.same);
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

struct StyledText
{
    this(string text, TextStyle style = TextStyle())
    {
        Cell[] ret = new Cell[](text.length);

        foreach (i, c; to!dstring(text))
        {
            ret[i] = Cell(c, style);
        }

        this.cells = ret;
    }

    Cell[] cells;
}

unittest
{
    //dfmt off
    auto st1 = StyledText("foo");
    assert
    (
        st1.cells == [
            Cell('f', TextStyle(Color.same, Color.same)),
            Cell('o', TextStyle(Color.same, Color.same)),
            Cell('o', TextStyle(Color.same, Color.same))
        ]
    );

    auto st2 = StyledText("bar", TextStyle().bg(Color.red));
    assert
    (
        st2.cells == [
            Cell('b', TextStyle(Color.same, Color.red)),
            Cell('a', TextStyle(Color.same, Color.red)),
            Cell('r', TextStyle(Color.same, Color.red)),
        ]
    );
    ///dfmt on
}
