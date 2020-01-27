module scone.window;

import scone.color;
import std.typecons : Tuple;

alias Coordinate = Tuple!(size_t, "x", size_t, "y");
alias Size = Tuple!(size_t, "width", size_t, "height");

class Window
{
    void write(X, Y, Args...)(X tx, Y ty, Args args) if (isNumeric!X && isNumeric!Y)
    {
        auto x = to!size_t(tx);
        auto y = to!size_t(ty);

        this.write(Coordinate(x, y), args);
    }

    void write(Args...)(Coordinate origin, Args args)
    {
        if (args == 0)
        {
            return;
        }

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

            this.bufferHandler.updateCell(coordinate, cell);

            ++dx;
        }
    }

    /+
    void print()
    {

    }

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

struct Cell
{
    char character = ' ';
    ForegroundColor foreground;
    BackgroundColor background;
}

class Buffer
{
    this(Size size, Cell defaultCell)
    {
        this.size = size;
        this.buffer = new Cell[][](size.height, size.width);
        this.changed = new bool[][](size.height, size.width);
    }

    void updateCell(in Coordinate coordinate, Cell cell)
    {
        if (coordinate.x < 0 || coordinate.x >= size.width || coordinate.y < 0
                || coordinate.y >= size.height)
        {
            return;
        }

        const Cell bufferCell = buffer[coordinate.y][coordinate.x];

        if (cell.foreground == Color.same)
        {
            cell.foreground = bufferCell.foreground;
        }

        if (cell.background == Color.same)
        {
            cell.background = bufferCell.background;
        }

        if (cell == bufferCell)
        {
            return;
        }

        changed[coordinate.y][coordinate.x] = true;
        buffer[coordinate.y][coordinate.x] = cell;

    }

    void commit()
    {
        foreach (ref row; changed)
        {
            foreach (ref isChanged; row)
            {
                isChanged = false;
            }
        }
    }
    
    // is changed at

    private Size size;
    private bool[][] changed;
    private Cell[][] buffer;
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

        // Calculate the lenght of arguments if converted to Cell[]
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
