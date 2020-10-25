module scone.output.os.posix.output.foos;

version (Posix)
{
    import scone.output.types.buffer : Buffer;
    import scone.output.types.cell : Cell;
    import scone.output.types.color;
    import scone.output.types.coordinate : Coordinate;
    import std.algorithm.searching : minElement, maxElement;
    import std.conv : text;
    import std.typecons : Tuple;

    alias PartialRowOutput = Tuple!(Coordinate, "coordinate", string, "output");

    struct Foos
    {
        private alias ModifiedRowSection = Tuple!(size_t, "row", size_t,
                "firstChangedIndex", size_t, "lastChangedIndex");

        this(Buffer buffer)
        {
            this.buffer = buffer;
        }

        PartialRowOutput[] partialRows()
        {
            PartialRowOutput[] foos;

            foreach (ModifiedRowSection row; this.modifiedRowSections(buffer))
            {
                size_t y = row.row;
                string print;

                foreach (x; row.firstChangedIndex .. (row.lastChangedIndex + 1))
                {
                    Cell currentCell = this.buffer.cellAt(Coordinate(x, y));

                    bool updateColors = false;

                    if (x == row.firstChangedIndex)
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
                        auto foregroundNumber = AnsiColor(currentCell.foreground).foregroundNumber;
                        auto backgroundNumber = AnsiColor(currentCell.background).backgroundNumber;
                        print ~= text("\033[0;", foregroundNumber, ";", backgroundNumber, "m",);
                    }

                    print ~= currentCell.character;
                }

                PartialRowOutput partialRowOutput;
                partialRowOutput.coordinate = Coordinate(row.firstChangedIndex, y);
                partialRowOutput.output = print;

                foos ~= partialRowOutput;
            }

            return foos;
        }

        private ModifiedRowSection[] modifiedRowSections(Buffer buffer)
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

            ModifiedRowSection[] affectedRows = [];
            foreach (y, size_t[] row; changedCellsMap)
            {
                size_t firstChangedIndex = row.minElement;
                size_t lastChangedIndex = row.maxElement;

                ModifiedRowSection dirtyRow;
                dirtyRow.row = y;
                dirtyRow.firstChangedIndex = firstChangedIndex;
                dirtyRow.lastChangedIndex = lastChangedIndex;

                affectedRows ~= dirtyRow; //todo isn't this inefficient
            }

            return affectedRows;
        }

        private Buffer buffer;
    }

    private struct AnsiColor
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

            enum light = 90;
            enum dark = 30;

            auto startIndex = color.isLight ? light : dark;
            auto colorOffset = (cast(ubyte) color) % 8;

            return startIndex + colorOffset;
        }
    }
}
