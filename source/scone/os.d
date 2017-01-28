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

    void size(uint width, uint height)
    {
        version(Windows)
        {
            Windows.size(width, height);
        }

        version(Posix)
        {

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

            if(_hConsoleOutput == INVALID_HANDLE_VALUE)
            {
                assert(0, "_hConsoleOutput == INVALID_HANDLE_VALUE");
            }

            Windows.cursorVisible = false;
            
        }

        auto deinit()
        {
            Windows.cursorVisible(true);
            Windows.setCursor(0,0);
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

        void size(uint width, uint height)
        {
            CONSOLE_SCREEN_BUFFER_INFO bufferInfo;
            if (!GetConsoleScreenBufferInfo(_hConsoleOutput, &bufferInfo))
                assert(0, "Unable to retrieve screen buffer info.");

            SMALL_RECT winInfo = bufferInfo.srWindow;
            COORD windowSize = { to!short(winInfo.Right - winInfo.Left + 1), to!short(winInfo.Bottom - winInfo.Top + 1)};

            if (windowSize.X > width || windowSize.Y > height)
            {
                // window size needs to be adjusted before the buffer size can be reduced.
                SMALL_RECT info = 
                { 
                    0, 
                    0, 
                    width <  windowSize.X ? to!short(width-1)  : to!short(windowSize.X-1), 
                    height < windowSize.Y ? to!short(height-1) : to!short(windowSize.Y-1)
                };

                if (!SetConsoleWindowInfo(_hConsoleOutput, 1, &info))
                {
                    assert(0, "Unable to resize window before resizing buffer.");
                }
            }

            COORD size = { to!short(width), to!short(height) };
            if (!SetConsoleScreenBufferSize(_hConsoleOutput, size))
            {
                assert(0, "Unable to resize screen buffer.");
            }

            SMALL_RECT info = { 0, 0, to!short(width - 1), to!short(height - 1) };
            if (!SetConsoleWindowInfo(_hConsoleOutput, 1, &info))
            {
                assert(0, "Unable to resize window after resizing buffer.");
            }
        }

        uint[2] size()
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

        private HANDLE _hConsoleOutput;
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

        import core.sys.posix.sys.ioctl;
        import core.sys.posix.unistd : STDOUT_FILENO;
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

        auto size()
        {
            winsize w;
            ioctl(STDOUT_FILENO, TIOCGWINSZ, &w);
            return [to!int(w.ws_col), to!int(w.ws_row)];
        }
    }
}