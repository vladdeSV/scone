module scone.os.windows.output.windows_output;

version (Windows)
{
    import core.sys.windows.windows;
    import scone.core.types.buffer : Buffer;
    import scone.core.types.cell : Cell;
    import scone.core.types.color;
    import scone.core.types.coordinate : Coordinate;
    import scone.core.types.size : Size;
    import scone.os.output : Output;
    import scone.os.windows.output.cell_converter : CellConverter;
    import std.conv : ConvOverflowException;
    import std.conv : to;
    import std.experimental.logger;

    pragma(lib, "User32.lib");

    class WindowsOutput : Output
    {
        void initializeOutput()
        {
            oldConsoleOutputHandle = GetStdHandle(STD_OUTPUT_HANDLE);

            consoleOutputHandle = CreateConsoleScreenBuffer(GENERIC_READ | GENERIC_WRITE,
                    FILE_SHARE_WRITE | FILE_SHARE_READ, null, CONSOLE_TEXTMODE_BUFFER, null);

            if (consoleOutputHandle == INVALID_HANDLE_VALUE)
            {
                //todo
                assert(0);
            }

            SetConsoleActiveScreenBuffer(consoleOutputHandle);

            this.lastSize = this.size();
        }

        void deinitializeOutput()
        {
            SetConsoleActiveScreenBuffer(oldConsoleOutputHandle);
        }

        void size(in Size size)
        {
            // todo
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
                buffer.redraw();
                lastSize = currentSize;
            }

            foreach (Coordinate coordinate; buffer.changedCellCoordinates)
            {
                Cell cell = buffer.cellAt(coordinate);
                this.writeCellAt(cell, coordinate);
            }
        }

        private void writeCellAt(Cell cell, Coordinate coordinate)
        {
            CHAR_INFO[] charBuffer = [CellConverter.toCharInfo(cell)];
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
    }
}
