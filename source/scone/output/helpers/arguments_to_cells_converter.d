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
            ForegroundColor foreground = Color.initial;
            BackgroundColor background = Color.initial;

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
