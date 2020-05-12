module scone.frame.frame;

import scone.core.types.buffer : Buffer;
import scone.core.types.cell : Cell;
import scone.core.types.color;
import scone.core.types.coordinate : Coordinate;
import scone.core.types.size : Size;
import scone.frame.cells_converter;
import scone.os.window : Window;
import std.concurrency : receiveTimeout;
import std.conv : to;
import std.datetime : Duration;
import std.traits : isNumeric;

class Frame
{
    private Buffer buffer;
    private Window window;

    this(Window window)
    {
        //todo get window size
        this.buffer = new Buffer(window.size());
        this.window = window;

        window.initializeOutput();
    }

    ~this()
    {
        window.deinitializeOutput();
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

            if (coordinate.x < 0 || coordinate.x >= buffer.size.width)
            {
                continue;
            }

            if (coordinate.y < 0 || coordinate.y >= buffer.size.height)
            {
                return;
            }

            this.buffer.setCell(coordinate, cell);

            ++dx;
        }
    }

    void print()
    {
        this.window.renderBuffer(this.buffer);
        this.buffer.commit();
    }

    Size size()
    {
        return this.buffer.size;
    }

    void size(in Size size)
    {
        this.buffer = new Buffer(size);
        this.window.size(size);
    }

    void size(in size_t width, in size_t height)
    {
        this.size(Size(width, height));
    }

    void title(in string title)
    {
        window.title(title);
    }

    /+
    void position(X, Y)(in X tx, in Y ty) if (isNumeric!X && isNumeric!Y)
    {

    }

    void position(in Coordinate coordinate)
    {

    }
    +/
}
