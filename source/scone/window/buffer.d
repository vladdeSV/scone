module scone.window.buffer;

import scone.input.input_event;
import scone.window.types.cell : Cell;
import scone.window.types.color;
import scone.window.types.coordinate : Coordinate;
import scone.window.types.size : Size;

class Buffer
{
    this(Size size, Cell defaultCell)
    {
        this.bufferSize = size;
        this.buffer = new Cell[][](size.height, size.width);
        this.changed = new bool[][](size.height, size.width);

        foreach (ref row; this.buffer)
        {
            foreach (ref cell; row)
            {
                cell = defaultCell;
            }
        }
    }

    Size size()
    {
        return this.bufferSize;
    }

    void setCell(in Coordinate coordinate, Cell cell)
    {
        const Cell bufferCell = this.cellAt(coordinate);

        if (cell.foreground == Color.initial)
        {
            cell.foreground = Color.whiteDark;
        }

        if (cell.foreground == Color.same)
        {
            cell.foreground = bufferCell.foreground;
        }

        if (cell.background == Color.initial)
        {
            cell.background = Color.blackDark;
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
                if (isChanged) {
                    coordinates ~= Coordinate(x, y);
                }
            }
        }

        return coordinates;
    }

    private Size bufferSize;
    private bool[][] changed;
    private Cell[][] buffer;
}
