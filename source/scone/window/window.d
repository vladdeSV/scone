module scone.window.window;

import std.conv : to;
import std.traits : isNumeric;

import scone.os.os_window : OSWindow;
import scone.window.buffer : Buffer;
import scone.window.types.cell : Cell;
import scone.window.types.color;
import scone.window.types.coordinate : Coordinate;
import scone.window.types.size : Size;

import std.stdio;

class Window
{

    private Buffer buffer;
    private OSWindow osWindow;

    this(OSWindow osWindow)
    {
        //todo get window size
        this.buffer = new Buffer(osWindow.windowSize(), Cell(' ', Color.red.foreground, Color.white.background));
        this.osWindow = osWindow;
    }

    void write(X, Y, Args...)(X tx, Y ty, Args args)
            if (isNumeric!X && isNumeric!Y && args.length)
    {
        Coordinate origin = Coordinate(to!size_t(tx), to!size_t(ty));

        this.write(origin, args);
    }

    void write(Args...)(Coordinate origin, Args args) if (args.length)
    {
        auto cellConverter = new CellsConverter!Args(args);
        Cell[] cells = cellConverter.cells;

        uint dx, dy;

        foreach (Cell cell; cells)
        {
            if (cell.character == '\n')
            {
                dx = 0;
                ++dy;
                continue;
            }

            if (cell.character == '\r')
            {
                dx = 0;
                continue;
            }

            if (cell.character == '\t')
            {
                //todo does not handle coloring until tabstop
                enum tabWidth = 4;
                dx += tabWidth - ((origin.x + dx) % tabWidth);
                continue;
            }

            Coordinate coordinate = Coordinate(origin.x + dx, origin.y + dy);

            this.buffer.setCell(coordinate, cell);

            ++dx;
        }
    }

    void print()
    {
        this.osWindow.renderBuffer(this.buffer);
        this.buffer.commit();
    }

    /+
    void title(in string title)
    {

    }

    void position(X, Y)(in X tx, in Y ty) if (isNumeric!X && isNumeric!Y)
    {

    }

    void position(in Coordinate coordinate)
    {

    }

    Size size()
    {

    }

    void resize(in Size size)
    {

    }

    void resize(in size_t width, in size_t height)
    {

    }
    +/
}

//todo rename to better reflect arguments -> Cell[]
private template CellsConverter(Args...)
{
    class CellsConverter
    {
        this(Args args)
        {
            this.args = args;
        }

        private Cell[] cells()
        {
            auto cells = new Cell[](this.length());

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
                    foreach (c; to!string(arg))
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

            //return tuple!("cells", "fg", "bg")(cells, foreground, background);

            return cells;
        }

        // Calculate the length of arguments if converted to Cell[]
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
