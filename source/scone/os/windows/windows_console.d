module scone.os.windows.windows_console;

version (Windows)
{
    import core.sys.windows.windows;
    import scone.core.types.buffer : Buffer;
    import scone.core.types.cell : Cell;
    import scone.core.types.color;
    import scone.core.types.coordinate : Coordinate;
    import scone.core.types.size : Size;
    import scone.input.input : Input;
    import scone.input.input_event : InputEvent;
    import scone.input.scone_control_key : SCK;
    import scone.input.scone_key : SK;
    import scone.misc.flags : hasFlag, withFlag;
    import scone.os.window : Window;
    import scone.os.windows.cell_converter : CellConverter;
    import scone.os.windows.key_event_record_converter : KeyEventRecordConverter;
    import std.conv : ConvOverflowException;
    import std.conv : to;
    import std.experimental.logger;

    pragma(lib, "User32.lib");

    class WindowsConsole : Window
    {
        void initializeOutput()
        {
            oldConsoleOutputHandle = GetStdHandle(STD_OUTPUT_HANDLE);

            auto consoleOutputHandle = CreateConsoleScreenBuffer(GENERIC_READ | GENERIC_WRITE,
                    FILE_SHARE_WRITE | FILE_SHARE_READ, null, CONSOLE_TEXTMODE_BUFFER, null);

            if (consoleOutputHandle == INVALID_HANDLE_VALUE)
            {
                //todo
            }

            SetConsoleActiveScreenBuffer(consoleOutputHandle);

            this.lastSize = this.size();
        }

        void deinitializeOutput()
        {
            SetConsoleActiveScreenBuffer(oldConsoleOutputHandle);
        }

        void initializeInput()
        {
            consoleInputHandle = GetStdHandle(STD_INPUT_HANDLE);
            if (consoleInputHandle == INVALID_HANDLE_VALUE)
            {
                //todo
            }
        }

        void deinitializeInput()
        {

        }

        Size size()
        {
            CONSOLE_SCREEN_BUFFER_INFO csbi;
            GetConsoleScreenBufferInfo(consoleOutputHandle, &csbi);

            return Size(cast(size_t) csbi.srWindow.Right - csbi.srWindow.Left + 1,
                    cast(size_t) csbi.srWindow.Bottom - csbi.srWindow.Top + 1);
        }

        void size(in Size size)
        {
            // todo
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
                sharedLog.log("wrote at ", coordinate, ", char ", cell.character);
            }
        }

        InputEvent[] latestInputEvents()
        {
            INPUT_RECORD[16] inputRecordBuffer;
            DWORD read = 0;
            ReadConsoleInput(consoleInputHandle, inputRecordBuffer.ptr, 16, &read);

            InputEvent[] inputEvents;

            for (size_t e = 0; e < read; ++e)
            {
                switch (inputRecordBuffer[e].EventType)
                {
                default:
                    break;
                case  /* 0x0002 */ MOUSE_EVENT:
                    // mouse has been clicked/moved
                    break;
                case  /* 0x0004 */ WINDOW_BUFFER_SIZE_EVENT:
                    // console has been resized
                    COORD foo = inputRecordBuffer[e].WindowBufferSizeEvent.dwSize;
                    Size newSize = Size(foo.X, foo.Y);
                    break;
                case  /* 0x0001 */ KEY_EVENT:
                    auto foo = new KeyEventRecordConverter(inputRecordBuffer[e].KeyEvent);
                    inputEvents ~= InputEvent(foo.sconeKey, foo.sconeControlKey,
                            cast(bool) inputRecordBuffer[e].KeyEvent.bKeyDown);
                    break;
                }
            }

            return inputEvents;
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

        //private HANDLE windowHandle;
        private HANDLE oldConsoleOutputHandle;
        private HANDLE consoleOutputHandle;
        private HANDLE consoleInputHandle;
        private Size lastSize;
    }
}
