module scone.os.posix.posix_terminal;

version (Posix)
{
    import std.stdio : writef, stdout;
    import scone.input.input_event : InputEvent;
    import scone.input.scone_key : SK;
    import scone.input.scone_control_key : SCK;
    import scone.os.os_window : OSWindow;
    import scone.window.buffer : Buffer;
    import scone.window.types.size : Size;
    import scone.window.types.cell : Cell;
    import scone.window.types.coordinate : Coordinate;
    import scone.window.types.size : Size;
    import std.algorithm.searching : minElement, maxElement;

    class PosixTerminal : OSWindow
    {
        this()
        {
            writef(/* clear the screen */ "\033[2J");
        }

        public void renderBuffer(Buffer buffer)
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

            import std.typecons : Tuple;
            alias ChangedRowInfo = Tuple!(size_t, "row", size_t, "min", size_t, "max");
            ChangedRowInfo[] affectedRows = [];

            foreach (y, size_t[] row; changedCellsMap)
            {
                size_t min = row.minElement;
                size_t max = row.maxElement;

                ChangedRowInfo c;
                c.row = y;
                c.min = min;
                c.max = max;

                affectedRows ~= c;
            }

            foreach (ChangedRowInfo row; affectedRows)
            {
                size_t y = row.row;

                char[] print = new char[](row.max - row.min + 1);
                foreach (x; row.min .. (row.max + 1))
                {
                    size_t n = x - row.min;
                    Coordinate foo = Coordinate(x, y);
                    print[n] = buffer.cellAt(foo).character;
                }

                this.cursorPosition(Coordinate(row.min, y));
                .writef(print);
            }

            stdout.flush();
        }

        Size windowSize()
        {
            winsize w;
            ioctl(STDOUT_FILENO, TIOCGWINSZ, &w);
            return Size(w.ws_col, w.ws_row);
        }

        public InputEvent[] latestInputEvents()
        {
            return [InputEvent(SK.a, SCK.none, true)];
        }

        private auto cursorPosition(in Coordinate coordinate)
        {
            writef("\033[%d;%dH", coordinate.y + 1, coordinate.x + 1);
            stdout.flush();
        }

        void clearWindow() {
            writef("\033[2J");
        }
    }
}
