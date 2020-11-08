module scone.output.frame;

import scone.output.buffer : Buffer;
import scone.output.types.cell : Cell;
import scone.output.types.color;
import scone.output.types.coordinate : Coordinate;
import scone.output.types.size : Size;
import scone.output.helpers.arguments_to_cells_converter;
import scone.output.os.standard_output : StandardOutput;
import std.concurrency : receiveTimeout;
import std.conv : to;
import std.datetime : Duration;
import std.traits : isNumeric;

class Frame
{
    this(StandardOutput output)
    {
        output.initialize();

        this.output = output;
        this.output.cursorVisible(false);
        this.buffer = new Buffer(output.size());
    }

    ~this()
    {
        this.output.cursorVisible(true);
        output.deinitialize();
    }

    void write(X, Y, Args...)(X tx, Y ty, Args args)
            if (isNumeric!X && isNumeric!Y && args.length)
    {
        Coordinate origin = Coordinate(to!size_t(tx), to!size_t(ty));

        this.write(origin, args);
    }

    void write(Args...)(Coordinate origin, Args args) if (args.length)
    {
        auto cellConverter = new ArgumentsToCellsConverter!Args(args);
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

            this.buffer.stage(coordinate, cell);

            ++dx;
        }
    }

    void print()
    {
        this.output.renderBuffer(this.buffer);
        this.buffer.commit();
        this.buffer.clear();
    }

    Size size()
    {
        return this.buffer.size;
    }

    void size(in Size size)
    {
        this.buffer = new Buffer(size);
        this.output.size(size);
    }

    void size(in size_t width, in size_t height)
    {
        this.size(Size(width, height));
    }

    void title(in string title)
    {
        output.title(title);
    }

    private StandardOutput output;
    private Buffer buffer;
}

/// basic
unittest
{
    import scone.core.dummy : DummyOutput;

    auto output = new DummyOutput();
    output.size = Size(5, 3);

    auto frame = new Frame(output);
    assert(frame.size == Size(5, 3));

    frame.size(5, 4);
    assert(frame.size == Size(5, 4));

    frame.title("test");
    // todo: assert(frame.title == "test");

    destroy(frame);
}
/// special control characters
unittest
{
    import scone.core.dummy : DummyOutput;
    import scone.output.text_style : TextStyle;

    auto output = new DummyOutput();
    output.size = Size(5, 3);
    auto frame = new Frame(output);

    frame.write(0, 0, "1");
    assert(frame.buffer.get(Coordinate(0, 0)) == Cell('1'));

    frame.print();
    frame.write(0, 0, "\n2");
    assert(frame.buffer.get(Coordinate(0, 1)) == Cell('2'));

    frame.print();
    frame.write(0, 0, "11\r3");
    assert(frame.buffer.get(Coordinate(0, 0)) == Cell('3'));
    assert(frame.buffer.get(Coordinate(1, 0)) == Cell('1'));

    frame.print();
    frame.buffer.commit();
    frame.write(4,2, "11\n1");
    assert(frame.buffer.diffs == [Coordinate(4,2)]);
}
/// tab special character. should be changed in the future?
unittest
{
    import scone.core.dummy : DummyOutput;
    import scone.output.text_style : TextStyle;

    auto output = new DummyOutput();
    output.size = Size(5, 3);
    auto frame = new Frame(output);

    frame.print();
    frame.write(2, 0, TextStyle(Color.green), "X");
    frame.write(0, 0, TextStyle(Color.red), "0\t4");
    assert(frame.buffer.get(Coordinate(0, 0)) == Cell('0', TextStyle(Color.red, Color.initial)));
    assert(frame.buffer.get(Coordinate(1, 0)) == Cell(' ', TextStyle(Color.initial, Color.initial)));
    assert(frame.buffer.get(Coordinate(2, 0)) == Cell('X', TextStyle(Color.green, Color.initial)));
    assert(frame.buffer.get(Coordinate(3, 0)) == Cell(' ', TextStyle(Color.initial, Color.initial)));
    assert(frame.buffer.get(Coordinate(4, 0)) == Cell('4', TextStyle(Color.red, Color.initial)));
}
/// cells use its own style, independen of previous text style
unittest
{
    import scone.core.dummy : DummyOutput;
    import scone.output.text_style : TextStyle;

    auto output = new DummyOutput();
    output.size = Size(5, 3);
    auto frame = new Frame(output);

    frame.print();
    frame.write(0, 0, TextStyle(Color.blue, Color.yellow), Cell('1',
            TextStyle(Color.red, Color.green)), '2');
    assert(frame.buffer.get(Coordinate(0, 0)) == Cell('1', TextStyle(Color.red, Color.green)));
    assert(frame.buffer.get(Coordinate(1, 0)) == Cell('2', TextStyle(Color.blue, Color.yellow)));
}
