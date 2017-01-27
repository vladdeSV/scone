module scone.os;

struct OS
{
    static:
    
    auto init()
    {
        version(Windows)
        {
            Windows.init();
        }

        version(Posix)
        {
            Posix.init();
        }
    }

    auto deinit()
    {
        cursorVisible = true;
        setCursor(0,0);

        version(Windows)
        {
            Windows.deinit();
        }

        version(Posix)
        {
            Posix.deinit();
        }
    }

    auto size()
    {
        version(Windows)
        {
            return Windows.size();
        }

        version(Posix)
        {
            return Posix.size();
        }
    }

    auto cursorVisible(bool visible) @property
    {
        version(Windows)
        {
            Windows.cursorVisible(visible);
        }

        version(Posix)
        {
            Posix.cursorVisible(visible);
        }
    }

    auto setCursor(uint x, uint y)
    {
        version(Windows)
        {
            return Windows.setCursor(x, y);
        }

        version(Posix)
        {
            return Posix.setCursor(x, y);
        }
    }

    void title(string title) @property
    {
        version(Windows)
        {
            Windows.title(title);
        }

        version(Posix)
        {
            Posix.title(title);
        }
    }

    version(Windows)
    static struct Windows
    {
        import scone.window : Cell;
        import core.sys.windows.windows;
        import scone.misc.utility;
        import scone.color;
        import std.algorithm : max, min;
        import std.conv : to;
        import std.string : toStringz;
        import std.stdio : stdout;

        static:

        auto init()
        {
            _hConsoleOutput = GetStdHandle(STD_OUTPUT_HANDLE);
            _hConsoleError  = GetStdHandle(STD_ERROR_HANDLE);

            if(_hConsoleOutput == INVALID_HANDLE_VALUE)
            {
                assert(0, "_hConsoleOutput == INVALID_HANDLE_VALUE");
            }

            if(_hConsoleError == INVALID_HANDLE_VALUE)
            {
                assert(0, "_hConsoleError == INVALID_HANDLE_VALUE");
            }

            Windows.cursorVisible(false);
            
        }

        auto deinit()
        {
            Windows.cursorVisible(true);
        }

        auto writeCell(size_t x, size_t y, ref Cell cell)
        {
            ushort wx = to!ushort(x), wy = to!ushort(y);
            COORD charBufSize = {1,1};
            COORD characterPos = {0,0};
            SMALL_RECT writeArea = {wx, wy, wx, wy};
            CHAR_INFO character;
            character.AsciiChar = cell.character;
            character.Attributes = attributesFromCell(cell);
            WriteConsoleOutputA(_hConsoleOutput, &character, charBufSize, characterPos, &writeArea);
        }

        /** Set cursor position. */
        auto setCursor(int x, int y)
        {
            GetConsoleScreenBufferInfo(_hConsoleOutput, &_consoleScreenBufferInfo);
            COORD change =
            {
                cast(short) min(_consoleScreenBufferInfo.srWindow.Right -
                _consoleScreenBufferInfo.srWindow.Left + 1, max(0, x)), cast(short)
                max(0, y)
            };

            stdout.flush();
            SetConsoleCursorPosition(_hConsoleOutput, change);
        }

        /** Set window title */
        auto title(string title) @property
        {
            SetConsoleTitleA(title.toStringz);
        }

        /** Set cursor visible. */
        auto cursorVisible(bool visible) @property
        {
            CONSOLE_CURSOR_INFO cci;
            GetConsoleCursorInfo(_hConsoleOutput, &cci);
            cci.bVisible = visible;
            SetConsoleCursorInfo(_hConsoleOutput, &cci);
        }

        /** Set line wrapping. */
        auto lineWrapping(bool lw) @property
        {
            lw ? SetConsoleMode(_hConsoleOutput, 0x0002)
            : SetConsoleMode(_hConsoleOutput, 0x0);
        }

        uint[2] size() @property
        {
            GetConsoleScreenBufferInfo(_hConsoleOutput, &_consoleScreenBufferInfo);

            return
            [
                _consoleScreenBufferInfo.srWindow.Right -
                _consoleScreenBufferInfo.srWindow.Left + 1,
                _consoleScreenBufferInfo.srWindow.Bottom -
                _consoleScreenBufferInfo.srWindow.Top  + 1
            ];
        }

        private HANDLE _hConsoleOutput, _hConsoleError;
        private CONSOLE_SCREEN_BUFFER_INFO _consoleScreenBufferInfo;

        ushort attributesFromCell(Cell cell)
        {
            ushort attributes;

            switch(cell.foreground)
            {
            case Color.blue:
                attributes |= FOREGROUND_INTENSITY | FOREGROUND_BLUE;
                break;
            case Color.blue_dark:
                attributes |= FOREGROUND_BLUE;
                break;
            case Color.cyan:
                attributes |= FOREGROUND_INTENSITY | FOREGROUND_GREEN | FOREGROUND_BLUE;
                break;
            case Color.cyan_dark:
                attributes |= FOREGROUND_GREEN | FOREGROUND_BLUE;
                break;
            case Color.white:
                attributes |= FOREGROUND_INTENSITY | FOREGROUND_RED | FOREGROUND_GREEN | FOREGROUND_BLUE;
                break;
            case Color.white_dark:
                attributes |= FOREGROUND_RED | FOREGROUND_GREEN | FOREGROUND_BLUE;
                break;
            case Color.black:
                attributes |= FOREGROUND_INTENSITY;
                break;
            case Color.black_dark:
                attributes |= 0;
                break;
            case Color.green:
                attributes |= FOREGROUND_INTENSITY | FOREGROUND_GREEN;
                break;
            case Color.green_dark:
                attributes |= FOREGROUND_GREEN;
                break;
            case Color.magenta:
                attributes |= FOREGROUND_INTENSITY | FOREGROUND_RED | FOREGROUND_BLUE;
                break;
            case Color.magenta_dark:
                attributes |= FOREGROUND_RED | FOREGROUND_BLUE;
                break;
            case Color.red:
                attributes |= FOREGROUND_INTENSITY | FOREGROUND_RED;
                break;
            case Color.red_dark:
                attributes |= FOREGROUND_RED;
                break;
            case Color.yellow:
                attributes |= FOREGROUND_INTENSITY | FOREGROUND_RED | FOREGROUND_GREEN;
                break;
            case Color.yellow_dark:
                attributes |= FOREGROUND_RED | FOREGROUND_GREEN;
                break;
            default:
                break;
            }

            switch(cell.background)
            {
            case Color.blue:
                attributes |= BACKGROUND_INTENSITY | BACKGROUND_BLUE;
                break;
            case Color.blue_dark:
                attributes |= BACKGROUND_BLUE;
                break;
            case Color.cyan:
                attributes |= BACKGROUND_INTENSITY | BACKGROUND_GREEN | BACKGROUND_BLUE;
                break;
            case Color.cyan_dark:
                attributes |= BACKGROUND_GREEN | BACKGROUND_BLUE;
                break;
            case Color.white:
                attributes |= BACKGROUND_INTENSITY | BACKGROUND_RED | BACKGROUND_GREEN | BACKGROUND_BLUE;
                break;
            case Color.white_dark:
                attributes |= BACKGROUND_RED | BACKGROUND_GREEN | BACKGROUND_BLUE;
                break;
            case Color.black:
                attributes |= BACKGROUND_INTENSITY;
                break;
            case Color.black_dark:
                attributes |= 0;
                break;
            case Color.green:
                attributes |= BACKGROUND_INTENSITY | BACKGROUND_GREEN;
                break;
            case Color.green_dark:
                attributes |= BACKGROUND_GREEN;
                break;
            case Color.magenta:
                attributes |= BACKGROUND_INTENSITY | BACKGROUND_RED | BACKGROUND_BLUE;
                break;
            case Color.magenta_dark:
                attributes |= BACKGROUND_RED | BACKGROUND_BLUE;
                break;
            case Color.red:
                attributes |= BACKGROUND_INTENSITY | BACKGROUND_RED;
                break;
            case Color.red_dark:
                attributes |= BACKGROUND_RED;
                break;
            case Color.yellow:
                attributes |= BACKGROUND_INTENSITY | BACKGROUND_RED | BACKGROUND_GREEN;
                break;
            case Color.yellow_dark:
                attributes |= BACKGROUND_RED | BACKGROUND_GREEN;
                break;
            default:
                break;
            }

            return attributes;
        }

    }

    version(Posix)
    static struct Posix
    {
        ///needs to be specifically set, otherwise ioctl crashes ;(
        version (OSX) enum TIOCGWINSZ = 0x40087468;

        import core.sys.Posix.sys.ioctl;
        import core.sys.Posix.unistd : STDOUT_FILENO;
        import std.conv : to, text;
        import std.stdio : write, writef;
        import std.process : execute;

        static:

        //TODO: linewrapping is set via tput, and I'm not sure it works for non-OSX systems

        auto init()
        {
            //turn off linewrapping
            //write("\033[?7l");
            execute(["tput", "rmam"]);
        }

        auto deinit()
        {
            //turn on linewrapping
            //write("\033[?7h");
            execute(["tput", "smam"]);
        }

        auto setCursor(uint x, uint y)
        {
            //stdout.flush();
            writef("\033[%d;%dH", y, x);
        }

        auto cursorVisible(bool vis) @property
        {
            vis ? write("\033[?25h") : write("\033[?25l");
        }

        auto lineWrapping(bool wrap) @property
        {
            wrap ? write("\033[?7h") : write("\033[?7l");
        }

        auto title(string title) @property
        {
            write("\033]0;", title, "\007");
        }

        auto size() @property
        {
            winsize w;
            ioctl(STDOUT_FILENO, TIOCGWINSZ, &w);
            return [to!int(w.ws_col), to!int(w.ws_row)];
        }
    }
}