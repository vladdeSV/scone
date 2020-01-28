module scone.os.windows.windows_console;

version (Windows)
{

    import core.sys.windows.windows;

    import scone.types;
    import scone.window : Buffer;
    import scone.color;

    class WindowsConsole : Renderer
    {
        public this()
        {
            consoleOutputHandle = GetStdHandle(STD_OUTPUT_HANDLE);
            if (consoleOutputHandle == INVALID_HANDLE_VALUE)
            {
                //todo
            }
        }

        public void renderBuffer(Buffer buffer)
        {
            foreach (Coordinate coordinate; buffer.changedCellCoordinates)
            {
                Cell cell = buffer.cellAt(coordinate);
                this.writeCellAt(cell, coordinate);
            }

            buffer.commit();
        }

        Size size()
        {
            CONSOLE_SCREEN_BUFFER_INFO csbi;
            GetConsoleScreenBufferInfo(consoleOutputHandle, &csbi);

            return Size(cast(size_t) csbi.srWindow.Right - csbi.srWindow.Left + 1,
                    cast(size_t) csbi.srWindow.Bottom - csbi.srWindow.Top + 1);
        }

        private void writeCellAt(Cell cell, Coordinate coordinate)
        {
            CHAR_INFO[] charBuffer = [CellConverter.toCharInfo(cell)];
            COORD bufferSize = {1, 1};
            COORD bufferCoord = {0, 0};

            SMALL_RECT writeRegion = {
                cast(SHORT) coordinate.x, cast(SHORT) coordinate.y,
                    cast(SHORT)(coordinate.x + 2), cast(SHORT)(coordinate.y + 2)
            };

            WriteConsoleOutput(consoleOutputHandle, charBuffer.ptr, bufferSize,
                    bufferCoord, &writeRegion);
        }

        //private HANDLE windowHandle;
        private HANDLE consoleOutputHandle; //, consoleInputHandle;

    }

    abstract final class CellConverter
    {
        public static CHAR_INFO toCharInfo(Cell cell)
        {
            CHAR_INFO character;
            character.AsciiChar = cell.character;
            character.UnicodeChar = cell.character;
            character.Attributes = typeof(this).attributesFromCell(cell);

            return character;
        }

        private static WORD attributesFromCell(Cell cell)
        {
            WORD attributes;

            switch (cell.foreground)
            {
            case Color.initial:
                // take the inital colors, and filter out all flags except the foreground ones
                //attributes |= (initialColors & (FOREGROUND_INTENSITY | FOREGROUND_RED | FOREGROUND_GREEN | FOREGROUND_BLUE));

                //todo
                attributes = FOREGROUND_RED | FOREGROUND_GREEN | FOREGROUND_BLUE;
                break;
            case Color.blue:
                attributes |= FOREGROUND_INTENSITY | FOREGROUND_BLUE;
                break;
            case Color.blueDark:
                attributes |= FOREGROUND_BLUE;
                break;
            case Color.cyan:
                attributes |= FOREGROUND_INTENSITY | FOREGROUND_GREEN | FOREGROUND_BLUE;
                break;
            case Color.cyanDark:
                attributes |= FOREGROUND_GREEN | FOREGROUND_BLUE;
                break;
            case Color.white:
                attributes |= FOREGROUND_INTENSITY | FOREGROUND_RED
                    | FOREGROUND_GREEN | FOREGROUND_BLUE;
                break;
            case Color.whiteDark:
                attributes |= FOREGROUND_RED | FOREGROUND_GREEN | FOREGROUND_BLUE;
                break;
            case Color.black:
                attributes |= FOREGROUND_INTENSITY;
                break;
            case Color.blackDark:
                attributes |= 0;
                break;
            case Color.green:
                attributes |= FOREGROUND_INTENSITY | FOREGROUND_GREEN;
                break;
            case Color.greenDark:
                attributes |= FOREGROUND_GREEN;
                break;
            case Color.magenta:
                attributes |= FOREGROUND_INTENSITY | FOREGROUND_RED | FOREGROUND_BLUE;
                break;
            case Color.magentaDark:
                attributes |= FOREGROUND_RED | FOREGROUND_BLUE;
                break;
            case Color.red:
                attributes |= FOREGROUND_INTENSITY | FOREGROUND_RED;
                break;
            case Color.redDark:
                attributes |= FOREGROUND_RED;
                break;
            case Color.yellow:
                attributes |= FOREGROUND_INTENSITY | FOREGROUND_RED | FOREGROUND_GREEN;
                break;
            case Color.yellowDark:
                attributes |= FOREGROUND_RED | FOREGROUND_GREEN;
                break;
            default:
                break;
            }

            switch (cell.background)
            {
            case Color.initial:
                // take the inital colors, and filter out all flags except the background ones
                //attributes |= (initialColors & (BACKGROUND_INTENSITY | BACKGROUND_RED | BACKGROUND_GREEN | BACKGROUND_BLUE));

                //todo
                attributes = 0;
                break;
            case Color.blue:
                attributes |= BACKGROUND_INTENSITY | BACKGROUND_BLUE;
                break;
            case Color.blueDark:
                attributes |= BACKGROUND_BLUE;
                break;
            case Color.cyan:
                attributes |= BACKGROUND_INTENSITY | BACKGROUND_GREEN | BACKGROUND_BLUE;
                break;
            case Color.cyanDark:
                attributes |= BACKGROUND_GREEN | BACKGROUND_BLUE;
                break;
            case Color.white:
                attributes |= BACKGROUND_INTENSITY | BACKGROUND_RED
                    | BACKGROUND_GREEN | BACKGROUND_BLUE;
                break;
            case Color.whiteDark:
                attributes |= BACKGROUND_RED | BACKGROUND_GREEN | BACKGROUND_BLUE;
                break;
            case Color.black:
                attributes |= BACKGROUND_INTENSITY;
                break;
            case Color.blackDark:
                attributes |= 0;
                break;
            case Color.green:
                attributes |= BACKGROUND_INTENSITY | BACKGROUND_GREEN;
                break;
            case Color.greenDark:
                attributes |= BACKGROUND_GREEN;
                break;
            case Color.magenta:
                attributes |= BACKGROUND_INTENSITY | BACKGROUND_RED | BACKGROUND_BLUE;
                break;
            case Color.magentaDark:
                attributes |= BACKGROUND_RED | BACKGROUND_BLUE;
                break;
            case Color.red:
                attributes |= BACKGROUND_INTENSITY | BACKGROUND_RED;
                break;
            case Color.redDark:
                attributes |= BACKGROUND_RED;
                break;
            case Color.yellow:
                attributes |= BACKGROUND_INTENSITY | BACKGROUND_RED | BACKGROUND_GREEN;
                break;
            case Color.yellowDark:
                attributes |= BACKGROUND_RED | BACKGROUND_GREEN;
                break;
            default:
                break;
            }

            return attributes;
        }
    }
}
