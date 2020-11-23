module scone.output.os.posix.partial_row_output_handler;

version (Posix)
{
    import scone.output.buffer : Buffer;
    import scone.output.os.posix.ansi_color_helper : ansiNumber, AnsiColorType;
    import scone.output.types.cell : Cell;
    import scone.output.types.color;
    import scone.output.types.coordinate : Coordinate;
    import std.algorithm.searching : minElement, maxElement;
    import std.conv : text;

    struct PartialRowOutput
    {
        Coordinate coordinate;
        string output;
    }

    struct PartialRowOutputHandler
    {
        private struct ModifiedRowSection
        {
            size_t row, firstChangedIndex, lastChangedIndex;
        }

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
                        print ~= ansiColorString(currentCell.style.foreground,
                                currentCell.style.background);
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

    string ansiColorString(Color foreground, Color background)
    {
        if (foreground.state == ColorState.ansi && background.state == ColorState.ansi)
        {
            auto foregroundNumber = ansiNumber(foreground.ansi, AnsiColorType.foreground);
            auto backgroundNumber = ansiNumber(background.ansi, AnsiColorType.background);
            return text("\033[0;", foregroundNumber, ";", backgroundNumber, "m",);
        }

        string ret;
        if (foreground.state == ColorState.ansi)
        {
            ret ~= text("\033[", ansiNumber(foreground.ansi, AnsiColorType.foreground), "m");
        }
        else if (foreground.state == ColorState.rgb)
        {
            ret ~= text("\033[38;2;", foreground.rgb.r, ";", foreground.rgb.g, ";", foreground.rgb.b, "m");
        }

        if (background.state == ColorState.ansi)
        {
            ret ~= text("\033[", ansiNumber(background.ansi, AnsiColorType.background), "m");
        }
        else if (background.state == ColorState.rgb)
        {
            ret ~= text("\033[48;2;", background.rgb.r, ";", background.rgb.g, ";", background.rgb.b, "m");
        }

        return ret;
    }
    ///
    unittest
    {
        assert(ansiColorString(Color.red, Color.red) == "\033[0;91;101m");
        assert(ansiColorString(Color.red, Color.green) == "\033[0;91;102m");
        assert(ansiColorString(Color.red, Color.rgb(10, 20, 30)) == "\033[91m\033[48;2;10;20;30m");
        assert(ansiColorString(Color.rgb(10, 20, 30), Color.green) == "\033[38;2;10;20;30m\033[102m");
    }
}
