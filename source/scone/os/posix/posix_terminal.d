module scone.os.posix.posix_terminal;

version (Posix)
{
    import scone.input.input_event : InputEvent;
    import scone.input.scone_control_key : SCK;
    import scone.input.scone_key : SK;
    import scone.os.os_window : OSWindow;
    import scone.window.buffer : Buffer;
    import scone.window.types.cell : Cell;
    import scone.window.types.coordinate : Coordinate;
    import scone.window.types.size : Size;
    import scone.window.types.color;
    import std.algorithm.searching : minElement, maxElement;
    import std.conv : text;
    import std.stdio : writef, stdout;
    import core.sys.posix.sys.ioctl : ioctl, winsize, TIOCGWINSZ;
    import core.sys.posix.unistd : STDOUT_FILENO;


    class PosixTerminal : OSWindow
    {
        this()
        {
            /+
            termios termInfo;
            tcgetattr(STDOUT_FILENO, &termInfo);
            termInfo.c_lflag &= ~ECHO;
            tcsetattr(STDOUT_FILENO, TCSADRAIN, &termInfo);
            +/
        }

        void renderBuffer(Buffer buffer)
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
                string print;

                Cell[] cells = new Cell[](row.max - row.min + 1);
                foreach (x; row.min .. (row.max + 1))
                {
                    Cell currentCell = buffer.cellAt(Coordinate(x, y));

                    bool updateColors = false;

                    if (x == row.min)
                    {
                        updateColors = true;
                    }
                    else
                    {
                        assert(x > 0);
                        immutable Cell previousCell = buffer.cellAt(Coordinate(x - 1, y));

                        //todo revisit and see if i though of this correctly
                        bool a = previousCell.foreground != currentCell.foreground
                            || previousCell.background != currentCell.background;
                        bool b = previousCell.character == ' '
                            && previousCell.background == currentCell.background;

                        if (a && !b)
                        {
                            updateColors = true;
                        }
                    }

                    if (updateColors)
                    {
                        auto foregroundNumber = new AnsiColor(currentCell.foreground)
                            .foregroundNumber;
                        auto backgroundNumber = new AnsiColor(currentCell.background)
                            .backgroundNumber;
                        print ~= text("\033[", 0, ";", foregroundNumber, ";",
                                backgroundNumber, "m",);
                    }

                    print ~= currentCell.character;
                }

                print ~= text("\033[0m",);

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

        InputEvent[] latestInputEvents()
        {
            return [InputEvent(SK.a, SCK.none, true)];
        }

        void cursorPosition(in Coordinate coordinate)
        {
            writef("\033[%d;%dH", coordinate.y + 1, coordinate.x + 1);
            stdout.flush();
        }

        void clearWindow() {
            writef("\033[2J");
        }

    }

    class AnsiColor
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
}
