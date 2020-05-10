module scone.os.posix.foo;

import scone.core.types.buffer : Buffer;
import scone.core.types.cell : Cell;
import scone.core.types.color;
import scone.core.types.coordinate : Coordinate;
import std.algorithm.searching : minElement, maxElement;
import std.conv : text;
import std.typecons : Tuple;

alias PartialRowOutput = Tuple!(Coordinate, "coordinate", string, "output");
private alias DirtyRow = Tuple!(size_t, "row", size_t, "min", size_t, "max");

class Foos
{
    private Buffer buffer;

    this(Buffer buffer)
    {
        this.buffer = buffer;
    }

    PartialRowOutput[] partialRows()
    {
        PartialRowOutput[] foos;

        foreach (DirtyRow row; this.dirtyRows(buffer))
        {
            size_t y = row.row;
            string print;

            Cell[] cells = new Cell[](row.max - row.min + 1);
            foreach (x; row.min .. (row.max + 1))
            {
                Cell currentCell = this.buffer.cellAt(Coordinate(x, y));

                bool updateColors = false;

                if (x == row.min)
                {
                    updateColors = true;
                }
                else
                {
                    assert(x > 0);
                    immutable Cell previousCell = this.buffer.cellAt(Coordinate(x - 1, y));

                    //todo revisit and see if i though of this correctly
                    bool a = previousCell.foreground != currentCell.foreground
                        || previousCell.background != currentCell.background;
                    bool b = currentCell.character == ' '
                        && previousCell.background == currentCell.background;

                    if (a && !b)
                    {
                        updateColors = true;
                    }
                }

                if (updateColors)
                {
                    auto foregroundNumber = new AnsiColor(currentCell.foreground).foregroundNumber;
                    auto backgroundNumber = new AnsiColor(currentCell.background).backgroundNumber;
                    print ~= text("\033[0;", foregroundNumber, ";", backgroundNumber, "m",);
                }

                print ~= currentCell.character;
            }

            PartialRowOutput partialRowOutput;
            partialRowOutput.coordinate = Coordinate(row.min, y);
            partialRowOutput.output = print;

            foos ~= partialRowOutput;
        }

        return foos;
    }

    private DirtyRow[] dirtyRows(Buffer buffer)
    {
        size_t[][size_t] changedCellsMap;
        foreach (Coordinate coordinate; buffer.changedCellCoordinates)
        {
            if ((coordinate.y in changedCellsMap) is null)
            {
                changedCellsMap[coordinate.y] = [];
            }

            changedCellsMap[coordinate.y] ~= coordinate.x;
        }

        DirtyRow[] affectedRows = [];
        foreach (y, size_t[] row; changedCellsMap)
        {
            size_t min = row.minElement;
            size_t max = row.maxElement;

            DirtyRow dirtyRow;
            dirtyRow.row = y;
            dirtyRow.min = min;
            dirtyRow.max = max;

            affectedRows ~= dirtyRow; //todo isn't this inefficient
        }

        return affectedRows;
    }
}

private class AnsiColor
{
    private Color color;

    this(Color color)
    {
        this.color = color;
    }

    int foregroundNumber()
    {
        return ansiNumberCalculator(this.color);
    }

    int backgroundNumber()
    {
        enum backgroundColorOffset = 10;
        return this.ansiNumberCalculator(this.color) + backgroundColorOffset;
    }

    private int ansiNumberCalculator(Color color) pure
    {
        if (color == Color.initial)
        {
            return 39;
        }

        if (color == Color.same)
        {
            return cast(Color)-1;
        }

        assert(color < 16);

        version (OSX)
        {
            // mac
            enum light = 90;
            enum dark = 30;
        }
        else
        {
            // ubuntu
            enum light = 30;
            enum dark = 90;
        }

        auto startIndex = color.isLight ? light : dark;
        auto colorOffset = (cast(ubyte) color) % 8;

        return startIndex + colorOffset;
    }
}
