module scone.output.os.windows.windows_output;

version (Windows)
{
    import core.sys.windows.windows;
    import scone.output.buffer : Buffer;
    import scone.output.types.cell : Cell;
    import scone.output.types.color;
    import scone.output.types.coordinate : Coordinate;
    import scone.output.types.size : Size;
    import scone.output.os.standard_output : StandardOutput;
    import scone.output.os.windows.cell_converter : CellConverter;
    import std.conv : ConvOverflowException;
    import std.conv : to;
    import std.experimental.logger;

    pragma(lib, "User32.lib");

    extern (Windows)
    {
        BOOL GetCurrentConsoleFont(HANDLE hConsoleOutput, BOOL bMaximumWindow,
                PCONSOLE_FONT_INFO lpConsoleCurrentFont);
        COORD GetConsoleFontSize(HANDLE hConsoleOutput, DWORD nFont);
    }

    class WindowsOutput : StandardOutput
    {
        void initialize()
        {
            oldConsoleOutputHandle = GetStdHandle(STD_OUTPUT_HANDLE);

            consoleOutputHandle = CreateConsoleScreenBuffer(GENERIC_READ | GENERIC_WRITE,
                    FILE_SHARE_WRITE | FILE_SHARE_READ, null, CONSOLE_TEXTMODE_BUFFER, null);

            if (consoleOutputHandle == INVALID_HANDLE_VALUE)
            {
                throw new Exception("Cannot initialize output. Got INVALID_HANDLE_VALUE.");
            }

            CONSOLE_SCREEN_BUFFER_INFO csbi;
            GetConsoleScreenBufferInfo(consoleOutputHandle, &csbi);
            this.initialAttributes = csbi.wAttributes;

            SetConsoleActiveScreenBuffer(consoleOutputHandle);

            this.lastSize = this.size();
        }

        void deinitialize()
        {
            SetConsoleActiveScreenBuffer(oldConsoleOutputHandle);
        }

        void size(in Size size)
        {
            // todo this was copied from my old codebase. this should really be reworked
            // todo does not work with windows terminal v1.0.1401.0, see https://github.com/microsoft/terminal/issues/5094

            auto width = size.width;
            auto height = size.height;

            // here comes a workaround of windows stange behaviour (in my honest opinion)
            // it sets the WINDOW size to 1x1, then sets the BUFFER size (crashes if window size is larger than buffer size), finally setting the correct window size

            //dfmt off
            CONSOLE_FONT_INFO consoleFontInfo;
            GetCurrentConsoleFont(consoleOutputHandle, FALSE, &consoleFontInfo);
            immutable COORD fontSize = GetConsoleFontSize(consoleOutputHandle, consoleFontInfo.nFont);
            immutable consoleMinimumPixelWidth = GetSystemMetrics(SM_CXMIN);
            immutable consoleMinimumPixelHeight = GetSystemMetrics(SM_CYMIN);

            if (width * fontSize.X < consoleMinimumPixelWidth || height * fontSize.Y < consoleMinimumPixelHeight)
            {
                sharedLog.warning("Tried to set the window size smaller than allowed. Ignored resize.");
                return;
            }

            // set window size to 1x1
            SMALL_RECT onebyone = {0, 0, 1, 1};
            if (!SetConsoleWindowInfo(consoleOutputHandle, 1, &onebyone))
            {
                sharedLog.error("1. Unable to resize window to 1x1: ERROR " ~ to!string(GetLastError()));
                return;
            }

            // set the buffer size to desired size
            COORD bufferSize = {to!short(width), to!short(height)};
            if (!SetConsoleScreenBufferSize(consoleOutputHandle, bufferSize))
            {
                sharedLog.error("2. Unable to resize screen buffer: ERROR " ~ to!string(GetLastError()));
                return;
            }

            // resize back the window to correct size
            SMALL_RECT info = {0, 0, to!short(width - 1), to!short(height - 1)};
            if (!SetConsoleWindowInfo(consoleOutputHandle, 1, &info))
            {
                sharedLog.error("3. Unable to resize window the second time: ERROR " ~ to!string(GetLastError()));
                return;
            }
            //dfmt on
        }

        Size size()
        {
            CONSOLE_SCREEN_BUFFER_INFO csbi;
            GetConsoleScreenBufferInfo(consoleOutputHandle, &csbi);

            return Size(cast(size_t) csbi.srWindow.Right - csbi.srWindow.Left + 1,
                    cast(size_t) csbi.srWindow.Bottom - csbi.srWindow.Top + 1);
        }

        void title(in string title)
        {
            wstring a = to!wstring(title) ~ "\0";
            SetConsoleTitleW(a.ptr);
        }

        void cursorVisible(in bool visible)
        {
            CONSOLE_CURSOR_INFO cci;
            GetConsoleCursorInfo(consoleOutputHandle, &cci);
            cci.bVisible = visible;
            SetConsoleCursorInfo(consoleOutputHandle, &cci);
        }

        void renderBuffer(Buffer buffer)
        {
            auto currentSize = this.size();
            if (currentSize != lastSize)
            {
                buffer.size = currentSize;
                lastSize = currentSize;
            }

            foreach (Coordinate coordinate; buffer.diffs)
            {
                Cell cell = buffer.get(coordinate);
                this.writeCellAt(cell, coordinate);
            }
        }

        private void writeCellAt(Cell cell, Coordinate coordinate)
        {
            CHAR_INFO[] charBuffer = [CellConverter.toCharInfo(cell, this.initialAttributes)];
            COORD bufferSize = {1, 1};
            COORD bufferCoord = {0, 0};
            SMALL_RECT writeRegion = {
                cast(SHORT) coordinate.x, cast(SHORT) coordinate.y,
                    cast(SHORT)(coordinate.x + 1), cast(SHORT)(coordinate.y + 1)
            };

            WriteConsoleOutput(consoleOutputHandle, charBuffer.ptr, bufferSize,
                    bufferCoord, &writeRegion);
        }

        private HANDLE windowHandle;
        private HANDLE oldConsoleOutputHandle;
        private HANDLE consoleOutputHandle;
        private Size lastSize;
        private WORD initialAttributes;
    }
}
