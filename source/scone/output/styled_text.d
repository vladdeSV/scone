module scone.output.styled_text;

import scone.output.text_style : TextStyle;
import scone.output.types.cell : Cell;
import scone.output.types.color : Color;
import std.conv : to;

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
