module scone.output.buffer;

import scone.output.types.cell : Cell;
import scone.output.types.color;
import scone.output.types.coordinate : Coordinate;
import scone.output.types.size : Size;
import std.range : chunks;

class Buffer
{
    deprecated
    {
        alias setCell = stage;
        alias changedCellCoordinates = diffs;
        alias cellAt = get;
    }

    this(Size size)
    {
        this.size = size;
    }

    Size size()
    {
        return this.bufferSize;
    }

    void size(Size size)
    {
        this.buffer = new Cell[](size.width * size.height);
        this.staging = this.buffer.dup;
        this.bufferSize = size;
    }

    void stage(Coordinate coordinate, Cell cell)
    {
        assert(coordinate.x < this.bufferSize.width);
        assert(coordinate.y < this.bufferSize.height);
        assert(coordinate.x >= 0);
        assert(coordinate.y >= 0);

        const Cell bufferCell = this.get(coordinate);

        if (cell.foreground == Color.same)
        {
            cell.foreground = bufferCell.foreground;
        }

        if (cell.background == Color.same)
        {
            cell.background = bufferCell.background;
        }

        auto view = this.staging.chunks(this.bufferSize.width);
        view[coordinate.y][coordinate.x] = cell;
    }

    Coordinate[] diffs()
    {
        Coordinate[] coordinates;
        foreach (i; 0 .. this.buffer.length)
        {
            if (this.buffer[i] == this.staging[i] && !this.willFlush)
            {
                continue;
            }

            size_t y = cast(size_t)(i / this.bufferSize.width);
            size_t x = i % this.bufferSize.width;

            coordinates ~= Coordinate(x, y);
        }

        return coordinates;
    }

    Cell get(Coordinate coordinate)
    {
        assert(coordinate.x < this.bufferSize.width);
        assert(coordinate.y < this.bufferSize.height);
        assert(coordinate.x >= 0);
        assert(coordinate.y >= 0);

        auto view = this.staging.chunks(this.bufferSize.width);
        return view[coordinate.y][coordinate.x];
    }

    void commit()
    {
        this.buffer = this.staging.dup;
        this.willFlush = false;
    }

    void clear()
    {
        this.staging[] = Cell();
    }

    void flush()
    {
        this.willFlush = true;
    }

    private Size bufferSize;
    private Cell[] buffer, staging;

    private bool willFlush = true;

    invariant(buffer.length == staging.length);
}

unittest
{
    auto buffer = new Buffer(Size(4, 2));
    assert(buffer.size == Size(4, 2));
    assert(buffer.diffs.length == 8);

    buffer.commit();
    assert(buffer.diffs.length == 0);

    assert(buffer.get(Coordinate(1, 1)) == Cell());
    buffer.stage(Coordinate(1, 1), Cell('1'));
    assert(buffer.get(Coordinate(1, 1)) == Cell('1'));
    assert(buffer.diffs == [Coordinate(1, 1)]);

    buffer.commit();
    assert(buffer.get(Coordinate(1, 1)) == Cell('1'));
    assert(buffer.diffs.length == 0);

    buffer.flush();
    assert(buffer.diffs.length == 8);
    buffer.commit();
    assert(buffer.diffs.length == 0);

    buffer.clear();
    assert(buffer.diffs == [Coordinate(1, 1)]);
    buffer.commit();

    buffer.stage(Coordinate(0, 0), Cell('2', Color.red.foreground, Color.green.background));
    assert(buffer.diffs.length == 1);
    buffer.commit();
    buffer.stage(Coordinate(0, 0), Cell('2', Color.same.foreground, Color.same.background));
    assert(buffer.diffs.length == 0);
}

/+
class Buffer
{
    this(Size size)
    {
        this.bufferSize = size;
        this.buffer = new Cell[][](size.height, size.width);
        this.changed = new bool[][](size.height, size.width);

        this.redraw();
    }

    Size size()
    {
        return this.bufferSize;
    }

    void setCell(in Coordinate coordinate, Cell cell)
    {
        const Cell bufferCell = this.cellAt(coordinate);

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

    ref Cell cellAt(Coordinate coordinate)
    {
        assert(coordinate.x < this.bufferSize.width);
        assert(coordinate.y < this.bufferSize.height);
        assert(coordinate.x >= 0);
        assert(coordinate.y >= 0);
        assert(buffer[coordinate.y][coordinate.x].foreground != Color.same);
        assert(buffer[coordinate.y][coordinate.x].background != Color.same);

        return buffer[coordinate.y][coordinate.x];
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

    Coordinate[] changedCellCoordinates()
    {
        Coordinate[] coordinates;
        foreach (y, ref bool[] row; changed)
        {
            foreach (x, bool isChanged; row)
            {
                if (isChanged)
                {
                    coordinates ~= Coordinate(x, y);
                }
            }
        }

        return coordinates;
    }

    void redraw()
    {
        foreach (ref row; this.changed)
        {
            foreach (ref changed; row)
            {
                changed = true;
            }
        }
    }

    private Size bufferSize;
    private bool[][] changed;
    private Cell[][] buffer;
}

unittest
{
    auto buffer = new Buffer(Size(4, 2));
    assert(buffer.size == Size(4, 2));

    buffer.redraw();
    assert(buffer.changedCellCoordinates.length == 8);

    buffer.commit();
    assert(buffer.changedCellCoordinates.length == 0);

    buffer.setCell(Coordinate(1, 1), Cell());
    assert(buffer.changedCellCoordinates.length == 0);

    auto cell = Cell('1');
    buffer.setCell(Coordinate(1, 1), cell);
    assert(buffer.changedCellCoordinates.length == 1);
    assert(buffer.changedCellCoordinates[0] == Coordinate(1, 1));

    buffer.commit();
    assert(buffer.changedCellCoordinates.length == 0);

    auto cellFromBuffer = buffer.cellAt(Coordinate(1, 1));
    assert(cellFromBuffer == cell);

    buffer.setCell(Coordinate(2, 1), Cell(' ', Color.green.foreground, Color.red.background));
    assert(buffer.changedCellCoordinates.length == 1);
    buffer.commit();
    assert(buffer.changedCellCoordinates.length == 0);

    buffer.setCell(Coordinate(2, 1), Cell(' ', Color.same.foreground, Color.same.background));
    assert(buffer.changedCellCoordinates.length == 0);
}
+/
