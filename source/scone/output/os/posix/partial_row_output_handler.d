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
                        Color fg = currentCell.style.foreground;
                        Color bg = currentCell.style.background;
                        if (fg.state == ColorState.ansi && bg.state == ColorState.ansi)
                        {
                            auto foregroundNumber = ansiNumber(fg.ansi, AnsiColorType.foreground);
                            auto backgroundNumber = ansiNumber(bg.ansi, AnsiColorType.background);
                            print ~= text("\033[0;", foregroundNumber, ";",
                                    backgroundNumber, "m",);
                        }
                        else
                        {
                            // dfmt off
                            if (fg.state == ColorState.ansi)
                            {
                                print ~= text("\033[", ansiNumber(fg.ansi, AnsiColorType.foreground), "m");
                            }
                            else if (fg.state == ColorState.rgb)
                            {
                                print ~= text("\033[38;2;", fg.rgb.r, ";", fg.rgb.g, ";", fg.rgb.b, "m");
                            }

                            if (bg.state == ColorState.ansi)
                            {
                                print ~= text("\033[", ansiNumber(bg.ansi, AnsiColorType.background), "m");
                            }
                            else if (bg.state == ColorState.rgb)
                            {
                                print ~= text("\033[48;2;", bg.rgb.r, ";", bg.rgb.g, ";", bg.rgb.b, "m");
                            }
                            // dfmt on
                        }

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
}
