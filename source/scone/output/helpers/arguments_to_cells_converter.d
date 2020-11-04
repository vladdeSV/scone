module scone.output.helpers.arguments_to_cells_converter;

import scone.output.types.cell : Cell;
import scone.output.types.color;
import std.conv : to;

/// convert arguments to Cell[]
template ArgumentsToCellsConverter(Args...)
{
    class ArgumentsToCellsConverter
    {
        this(Args args)
        {
            this.args = args;
        }

        public Cell[] cells()
        {
            auto length = this.length();
            if (length == 0)
            {
                return [];
            }

            auto cells = new Cell[](length);
            ForegroundColor foreground = Color.same;
            BackgroundColor background = Color.same;

            int i = 0;
            foreach (arg; args)
            {
                static if (is(typeof(arg) == ForegroundColor))
                {
                    foreground = arg;
                }
                else static if (is(typeof(arg) == BackgroundColor))
                {
                    background = arg;
                }
                else static if (is(typeof(arg) == Cell))
                {
                    cells[i] = arg;
                    ++i;
                }
                else static if (is(typeof(arg) == Cell[]))
                {
                    foreach (cell; arg)
                    {
                        cells[i] = cell;
                        ++i;
                    }
                }
                else static if (is(typeof(arg) == Color))
                {
                    //logger.warning("`write(x, y, ...)`: Type `Color` passed in, which has no effect");
                }
                else
                {
                    foreach (c; to!dstring(arg))
                    {
                        cells[i] = Cell(c, foreground, background);
                        ++i;
                    }
                }
            }

            // If there are cells to write, and the last argument is a color, warn
            //auto lastArgument = args[$ - 1];
            //if (cells.length && is(typeof(lastArgument) : Color))
            //{
            //    logger.warning("The last argument in %s is a color, which will not be set. ", args);
            //}

            return cells;
        }

        /// calculate the length of arguments if converted to Cell[]
        private size_t length()
        {
            int length = 0;
            foreach (arg; this.args)
            {
                static if (is(typeof(arg) : Color))
                {
                    continue;
                }
                else static if (is(typeof(arg) == Cell))
                {
                    ++length;
                    continue;
                }
                else static if (is(typeof(arg) == Cell[]))
                {
                    length += arg.length;
                    continue;
                }
                else
                {
                    length += to!string(arg).length;
                }
            }

            return length;
        }

        private Args args;
    }
}

unittest
{
    auto converter1 = new ArgumentsToCellsConverter!();
    assert(converter1.cells == []);
    assert(converter1.length == 0);

    auto converter2 = new ArgumentsToCellsConverter!(int, int, int)(0, 0, 0);
    assert(converter2.cells == [Cell('0', Color.same.foreground, Color.same.background), Cell('0', Color.same.foreground, Color.same.background), Cell('0', Color.same.foreground, Color.same.background)]);
    assert(converter2.length == 3);

    auto converter3 = new ArgumentsToCellsConverter!(string)("foo");
    assert(converter3.cells == [Cell('f', Color.same.foreground, Color.same.background), Cell('o', Color.same.foreground, Color.same.background), Cell('o', Color.same.foreground, Color.same.background)]);
    assert(converter3.length == 3);

    auto converter4 = new ArgumentsToCellsConverter!(string, ForegroundColor, string, BackgroundColor, string)("f", Color.red.foreground, "o", Color.green.background, "o");
    assert(converter4.cells == [Cell('f', Color.same.foreground, Color.same.background), Cell('o', Color.red.foreground, Color.same.background), Cell('o', Color.red.foreground, Color.green.background)]);
    assert(converter4.length == 3);

    auto converter5 = new ArgumentsToCellsConverter!(Cell, Cell[])(Cell('1'), [Cell('2'), Cell('3')]);
    assert(converter5.cells == [Cell('1'), Cell('2'), Cell('3')]);
    assert(converter5.length == 3);

    auto converter6 = new ArgumentsToCellsConverter!(ForegroundColor, BackgroundColor)(Color.red.foreground, Color.green.background);
    assert(converter6.cells == []);
    assert(converter6.length == 0);
}
