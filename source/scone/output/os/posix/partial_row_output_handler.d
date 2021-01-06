module scone.output.os.posix.partial_row_output_handler;

version (Posix)
{
    import scone.output.buffer : Buffer;
    import scone.output.helpers.ansi_color_helper : ansiColorString, AnsiColorType;
    import scone.output.types.cell : Cell;
    import scone.output.types.color;
    import scone.output.types.coordinate : Coordinate;
    import std.algorithm.searching : minElement, maxElement;
    import std.conv : text;

    string printDataFromPartialRowOutput(PartialRowOutput[] pros)
    {
        import std.array : join;
        import std.algorithm.iteration : map;
        import std.conv : text;

        return pros.map!(pro => text("\033[", pro.coordinate.y + 1, ";",
                pro.coordinate.x + 1, "H", pro.output)).join();
    }
    ///
    unittest
    {
        PartialRowOutput[] pros;

        pros = [PartialRowOutput(Coordinate(0, 2), "foo")];
        assert(pros.printDataFromPartialRowOutput() == "\033[3;1Hfoo");

        pros = [
            PartialRowOutput(Coordinate(0, 0), "foo"),
            PartialRowOutput(Coordinate(2, 3), "bar"),
        ];
        assert(pros.printDataFromPartialRowOutput() == "\033[1;1Hfoo\033[4;3Hbar");
    }

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

    unittest
    {
        import scone.output.buffer : Buffer;
        import scone.output.types.size : Size;
        import scone.output.text_style : TextStyle;

        auto buffer = new Buffer(Size(5, 3));
        auto proh = PartialRowOutputHandler(buffer);

        buffer.commit();
        assert(proh.partialRows.length == 0);
        assert(proh.partialRows == []);

        buffer.stage(Coordinate(1, 1), Cell('A', TextStyle(Color.red, Color.green)));
        assert(proh.partialRows.length == 1);
        assert(proh.partialRows == [PartialRowOutput(Coordinate(1, 1), "\033[0;91;102mA")]);

        buffer.commit();
        assert(proh.partialRows.length == 0);
        assert(proh.partialRows == []);

        buffer.stage(Coordinate(2, 1), Cell('B', TextStyle(Color.green, Color.red)));
        buffer.stage(Coordinate(3, 1), Cell('B', TextStyle(Color.green, Color.red)));
        assert(proh.partialRows.length == 1);
        assert(proh.partialRows == [PartialRowOutput(Coordinate(2, 1), "\033[0;92;101mBB")]);

        buffer.commit();
        buffer.stage(Coordinate(2, 1), Cell('C', TextStyle(Color.green, Color.red)));
        buffer.stage(Coordinate(3, 2), Cell('C', TextStyle(Color.green, Color.red)));
        assert(proh.partialRows.length == 2);
    }
}
