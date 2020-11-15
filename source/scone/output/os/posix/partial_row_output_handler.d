module scone.output.os.posix.partial_row_output_handler;

version (Posix)
{
    import scone.output.buffer : Buffer;
    import scone.output.types.cell : Cell;
    import scone.output.types.color;
    import scone.output.types.coordinate : Coordinate;
    import std.algorithm.searching : minElement, maxElement;
    import std.conv : text;
    import std.typecons : Tuple;

    alias PartialRowOutput = Tuple!(Coordinate, "coordinate", string, "output");

    struct PartialRowOutputHandler
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
                    Cell currentCell = this.buffer.get(Coordinate(x, y));

                    bool updateColors = false;

                    if (x == row.firstChangedIndex)
                    {
                        updateColors = true;
                    }
                    else
                    {
                        assert(x > 0);
                        immutable Cell previousCell = this.buffer.get(Coordinate(x - 1, y));

                        //todo revisit and see if i though of this correctly
                        bool a = previousCell.style.foreground != currentCell.style.foreground
                            || previousCell.style.background != currentCell.style.background;
                        bool b = currentCell.character == ' '
                            && previousCell.style.background == currentCell.style.background;

                        if (a && !b)
                        {
                            updateColors = true;
                        }
                    }

                    if (updateColors)
                    {
                        auto foregroundNumber = AnsiColorHelper(currentCell.style.foreground)
                            .foregroundNumber;
                        auto backgroundNumber = AnsiColorHelper(currentCell.style.background)
                            .backgroundNumber;
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
            foreach (Coordinate coordinate; buffer.diffs())
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

    private struct AnsiColorHelper
    {
        private AnsiColor ansi;

        this(Color color)
        {
            this.ansi = color.ansi;
        }

        int foregroundNumber()
        {
            return ansiNumberCalculator(this.ansi);
        }

        int backgroundNumber()
        {
            enum backgroundColorOffset = 10;
            return this.ansiNumberCalculator(this.ansi) + backgroundColorOffset;
        }

        private int ansiNumberCalculator(AnsiColor ansi) pure
        {
            if (ansi == AnsiColor.initial)
            {
                return 39;
            }

            if (ansi == AnsiColor.same)
            {
                return cast(AnsiColor)-1;
            }

            assert(ansi < 16);

            enum light = 90;
            enum dark = 30;

            auto startIndex = ansi < 8 ? light : dark;
            auto colorOffset = (cast(ubyte) ansi) % 8;

            return startIndex + colorOffset;
        }
    }
}
