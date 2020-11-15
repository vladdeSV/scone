module scone.output.os.windows.cell_converter;

version (Windows)
{
    import core.sys.windows.windows;
    import scone.output.types.cell : Cell;
    import scone.output.types.color;
    import std.conv : ConvOverflowException;
    import std.conv : to;

    abstract final class CellConverter
    {
        public static CHAR_INFO toCharInfo(Cell cell, WORD initialAttributes)
        {
            wchar unicodeCharacter;

            try
            {
                unicodeCharacter = to!wchar(cell.character);
            }
            catch (ConvOverflowException e)
            {
                unicodeCharacter = '?';
            }

            CHAR_INFO character;
            character.UnicodeChar = unicodeCharacter;
            character.Attributes = typeof(this).attributesFromCell(cell, initialAttributes);

            return character;
        }

        private static WORD attributesFromCell(Cell cell, WORD initialAttributes)
        {
            WORD attributes;

            switch (cell.style.foreground.ansi)
            {
            case AnsiColor.initial:
                // take the inital colors, and filter out all flags except the foreground ones
                attributes |= (initialAttributes & (FOREGROUND_INTENSITY | FOREGROUND_RED | FOREGROUND_GREEN | FOREGROUND_BLUE));
                break;
            case AnsiColor.blue:
                attributes |= FOREGROUND_INTENSITY | FOREGROUND_BLUE;
                break;
            case AnsiColor.blueDark:
                attributes |= FOREGROUND_BLUE;
                break;
            case AnsiColor.cyan:
                attributes |= FOREGROUND_INTENSITY | FOREGROUND_GREEN | FOREGROUND_BLUE;
                break;
            case AnsiColor.cyanDark:
                attributes |= FOREGROUND_GREEN | FOREGROUND_BLUE;
                break;
            case AnsiColor.white:
                attributes |= FOREGROUND_INTENSITY | FOREGROUND_RED | FOREGROUND_GREEN | FOREGROUND_BLUE;
                break;
            case AnsiColor.whiteDark:
                attributes |= FOREGROUND_RED | FOREGROUND_GREEN | FOREGROUND_BLUE;
                break;
            case AnsiColor.black:
                attributes |= FOREGROUND_INTENSITY;
                break;
            case AnsiColor.blackDark:
                attributes |= 0;
                break;
            case AnsiColor.green:
                attributes |= FOREGROUND_INTENSITY | FOREGROUND_GREEN;
                break;
            case AnsiColor.greenDark:
                attributes |= FOREGROUND_GREEN;
                break;
            case AnsiColor.magenta:
                attributes |= FOREGROUND_INTENSITY | FOREGROUND_RED | FOREGROUND_BLUE;
                break;
            case AnsiColor.magentaDark:
                attributes |= FOREGROUND_RED | FOREGROUND_BLUE;
                break;
            case AnsiColor.red:
                attributes |= FOREGROUND_INTENSITY | FOREGROUND_RED;
                break;
            case AnsiColor.redDark:
                attributes |= FOREGROUND_RED;
                break;
            case AnsiColor.yellow:
                attributes |= FOREGROUND_INTENSITY | FOREGROUND_RED | FOREGROUND_GREEN;
                break;
            case AnsiColor.yellowDark:
                attributes |= FOREGROUND_RED | FOREGROUND_GREEN;
                break;
            default:
                break;
            }

            switch (cell.style.background.ansi)
            {
            case AnsiColor.initial:
                // take the inital colors, and filter out all flags except the background ones
                attributes |= (initialAttributes & (BACKGROUND_INTENSITY | BACKGROUND_RED | BACKGROUND_GREEN | BACKGROUND_BLUE));
                break;
            case AnsiColor.blue:
                attributes |= BACKGROUND_INTENSITY | BACKGROUND_BLUE;
                break;
            case AnsiColor.blueDark:
                attributes |= BACKGROUND_BLUE;
                break;
            case AnsiColor.cyan:
                attributes |= BACKGROUND_INTENSITY | BACKGROUND_GREEN | BACKGROUND_BLUE;
                break;
            case AnsiColor.cyanDark:
                attributes |= BACKGROUND_GREEN | BACKGROUND_BLUE;
                break;
            case AnsiColor.white:
                attributes |= BACKGROUND_INTENSITY | BACKGROUND_RED | BACKGROUND_GREEN | BACKGROUND_BLUE;
                break;
            case AnsiColor.whiteDark:
                attributes |= BACKGROUND_RED | BACKGROUND_GREEN | BACKGROUND_BLUE;
                break;
            case AnsiColor.black:
                attributes |= BACKGROUND_INTENSITY;
                break;
            case AnsiColor.blackDark:
                attributes |= 0;
                break;
            case AnsiColor.green:
                attributes |= BACKGROUND_INTENSITY | BACKGROUND_GREEN;
                break;
            case AnsiColor.greenDark:
                attributes |= BACKGROUND_GREEN;
                break;
            case AnsiColor.magenta:
                attributes |= BACKGROUND_INTENSITY | BACKGROUND_RED | BACKGROUND_BLUE;
                break;
            case AnsiColor.magentaDark:
                attributes |= BACKGROUND_RED | BACKGROUND_BLUE;
                break;
            case AnsiColor.red:
                attributes |= BACKGROUND_INTENSITY | BACKGROUND_RED;
                break;
            case AnsiColor.redDark:
                attributes |= BACKGROUND_RED;
                break;
            case AnsiColor.yellow:
                attributes |= BACKGROUND_INTENSITY | BACKGROUND_RED | BACKGROUND_GREEN;
                break;
            case AnsiColor.yellowDark:
                attributes |= BACKGROUND_RED | BACKGROUND_GREEN;
                break;
            default:
                break;
            }

            return attributes;
        }
    }
}
